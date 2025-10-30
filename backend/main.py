from __future__ import annotations

import os
import re
import time
import logging
from typing import List, Optional, Dict, Any
from enum import Enum

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Loading environment variables
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    logger.warning("python-dotenv not installed")

# Import Gemini
try:
    import google.generativeai as genai
    HAS_GEMINI = True
except ImportError:
    HAS_GEMINI = False
    logger.error("Google Generative AI not installed. Run: pip install google-generativeai")

APP_NAME = "smart-text-toning-analyzer"

class ToneCategory(Enum):
    FORMAL = "formal"
    CASUAL = "casual"
    PROFESSIONAL = "professional"
    FRIENDLY = "friendly"
    PERSUASIVE = "persuasive"
    INSPIRATIONAL = "inspirational"
    EMPATHETIC = "empathetic"
    AUTHORITATIVE = "authoritative"
    ENTHUSIASTIC = "enthusiastic"
    NEUTRAL = "neutral"

class ToneAnalysisRequest(BaseModel):
    text: str
    context: Optional[str] = None  # e.g., "email", "social media", "business", "casual"

class ToneAnalysisResponse(BaseModel):
    original_text: str
    detected_tone: str
    confidence: float
    tone_category: str
    enhanced_versions: List[Dict[str, str]]
    suggestions: List[str]
    explanation: str

class GeminiTextToningAnalyzer:
    def __init__(self):
        self.api_key = None
        self.model = None
        self.initialized = False
        self.last_request_time = 0
        self.request_delay = 2
        
    def initialize(self) -> bool:
        """Initialize Gemini with correct model names."""
        if not HAS_GEMINI:
            logger.error("Gemini library not available")
            return False
            
        try:
            self.api_key = os.environ.get("GEMINI_API_KEY", "").strip()
            if not self.api_key:
                logger.warning("GEMINI_API_KEY not found in environment variables")
                return False
            
            genai.configure(api_key=self.api_key)
            
            # Get available models first
            try:
                available_models = list(genai.list_models())
                model_names = [model.name for model in available_models]
                logger.info(f"Available models: {model_names}")
                
                # Filter for models that support generateContent
                supported_models = []
                for model in available_models:
                    if 'generateContent' in model.supported_generation_methods:
                        supported_models.append(model.name)
                        logger.info(f"Supported model: {model.name}")
                
            except Exception as e:
                logger.warning(f"Could not list models: {e}")
                supported_models = []
            
            # Try known working model names for the current API
            model_names_to_try = [
                "gemini-1.5-flash-001",
                "gemini-1.5-pro-001",
                "gemini-1.0-pro",
                "gemini-pro",
                "gemini-1.5-flash",
                "gemini-1.5-pro",
            ]
            
            # Add supported models from the API to our try list
            if supported_models:
                model_names_to_try = supported_models + model_names_to_try
            
            for model_name in model_names_to_try:
                try:
                    logger.info(f"Trying model: {model_name}")
                    self.model = genai.GenerativeModel(model_name)
                    # Test the model with a simple prompt
                    test_response = self.model.generate_content("Say 'OK'")
                    if test_response and test_response.text:
                        logger.info(f"✅ Gemini model initialized: {model_name}")
                        self.initialized = True
                        return True
                except Exception as e:
                    logger.warning(f"Model {model_name} failed: {str(e)[:100]}...")
                    continue
            
            logger.error("No working Gemini model found")
            return False
            
        except Exception as e:
            logger.error(f"Gemini initialization failed: {e}")
            return False
    
    def wait_for_rate_limit(self):
        """Wait to avoid rate limiting."""
        current_time = time.time()
        time_since_last = current_time - self.last_request_time
        if time_since_last < self.request_delay:
            time.sleep(self.request_delay - time_since_last)
        self.last_request_time = time.time()
    
    def analyze_tone_and_enhance(self, text: str, context: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Analyze text tone and provide enhanced versions."""
        if not self.initialized or not self.model:
            logger.error("Gemini not initialized")
            return None
        
        self.wait_for_rate_limit()
        
        try:
            # Enhanced prompt for tone analysis and text enhancement
            prompt = self._build_analysis_prompt(text, context)
            
            # Generate content
            response = self.model.generate_content(prompt)
            
            if response and response.text:
                logger.info("Gemini tone analysis response received")
                return self.parse_tone_analysis_response(response.text, text)
            else:
                logger.warning("Gemini returned empty response")
                return None
                
        except Exception as e:
            logger.error(f"Gemini tone analysis error: {e}")
            if "429" in str(e) or "quota" in str(e).lower():
                logger.warning("Rate limit hit, increasing delay")
                self.request_delay += 2
            return None
    
    def _build_analysis_prompt(self, text: str, context: Optional[str] = None) -> str:
        """Build the prompt for tone analysis."""
        context_part = f"Context: {context}\n" if context else ""
        
        prompt = f"""
        Analyze the tone of the following text and provide enhanced versions in different tones.
        
        {context_part}
        Text to analyze: "{text}"
        
        Please provide your response in this exact format:
        
        DETECTED_TONE: [primary tone name]
        CONFIDENCE: [0.XX]
        TONE_CATEGORY: [formal/casual/professional/friendly/persuasive/inspirational/empathetic/authoritative/enthusiastic/neutral]
        EXPLANATION: [brief explanation of why this tone was detected]
        
        ENHANCED_VERSIONS:
        1. [Tone Name]: [Enhanced version of the text]
        2. [Tone Name]: [Enhanced version of the text]
        3. [Tone Name]: [Enhanced version of the text]
        
        SUGGESTIONS:
        - [Suggestion 1]
        - [Suggestion 2]
        - [Suggestion 3]
        
        Guidelines for enhancement:
        - Keep the core meaning intact
        - Make enhancements natural and context-appropriate
        - Ensure each enhanced version clearly demonstrates the target tone
        - Provide practical, actionable suggestions
        
        Available tones for enhancement: Formal, Casual, Professional, Friendly, Persuasive, Inspirational, Empathetic, Authoritative, Enthusiastic.
        """
        
        return prompt
    
    def parse_tone_analysis_response(self, response_text: str, original_text: str) -> Dict[str, Any]:
        """Parse Gemini response into structured tone analysis."""
        try:
            lines = [line.strip() for line in response_text.split('\n') if line.strip()]
            
            detected_tone = "neutral"
            confidence = 0.8
            tone_category = "neutral"
            explanation = "The tone appears balanced and neutral."
            enhanced_versions = []
            suggestions = []
            
            current_section = None
            
            for line in lines:
                line_lower = line.lower()
                
                # Parse detected tone
                if line_lower.startswith("detected_tone:"):
                    detected_tone = line.split(":", 1)[1].strip()
                elif line_lower.startswith("confidence:"):
                    try:
                        conf_str = line.split(":", 1)[1].strip()
                        confidence = float(conf_str)
                    except ValueError:
                        confidence = 0.8
                elif line_lower.startswith("tone_category:"):
                    tone_category = line.split(":", 1)[1].strip()
                elif line_lower.startswith("explanation:"):
                    explanation = line.split(":", 1)[1].strip()
                elif line_lower.startswith("enhanced_versions:"):
                    current_section = "enhanced"
                    continue
                elif line_lower.startswith("suggestions:"):
                    current_section = "suggestions"
                    continue
                
                # Parse enhanced versions
                if current_section == "enhanced" and re.match(r'^\d+\.', line):
                    parts = line.split(":", 1)
                    if len(parts) == 2:
                        tone_name = parts[0].split(".", 1)[1].strip()
                        enhanced_text = parts[1].strip()
                        enhanced_versions.append({
                            "tone": tone_name,
                            "text": enhanced_text
                        })
                
                # Parse suggestions
                elif current_section == "suggestions" and line.startswith("-"):
                    suggestion = line[1:].strip()
                    if suggestion:
                        suggestions.append(suggestion)
            
            # Ensure we have at least some enhanced versions
            if not enhanced_versions:
                enhanced_versions = self._generate_fallback_enhancements(original_text)
            
            # Ensure we have suggestions
            if not suggestions:
                suggestions = self._generate_fallback_suggestions(detected_tone)
            
            return {
                "original_text": original_text,
                "detected_tone": detected_tone,
                "confidence": confidence,
                "tone_category": tone_category,
                "enhanced_versions": enhanced_versions,
                "suggestions": suggestions,
                "explanation": explanation
            }
            
        except Exception as e:
            logger.error(f"Error parsing tone analysis response: {e}")
            return self._generate_fallback_analysis(original_text)
    
    def _generate_fallback_enhancements(self, text: str) -> List[Dict[str, str]]:
        """Generate fallback enhanced versions."""
        return [
            {"tone": "Professional", "text": f"We would like to discuss the following matter: {text}"},
            {"tone": "Friendly", "text": f"Hey! Just wanted to share: {text}"},
            {"tone": "Formal", "text": f"It is important to note that: {text}"}
        ]
    
    def _generate_fallback_suggestions(self, detected_tone: str) -> List[str]:
        """Generate fallback suggestions based on detected tone."""
        base_suggestions = [
            "Consider your audience when choosing tone",
            "Ensure your message aligns with your intent",
            "Review for clarity and impact"
        ]
        
        tone_specific_suggestions = {
            "formal": ["Use complete sentences", "Avoid contractions", "Maintain professional vocabulary"],
            "casual": ["Use conversational language", "Feel free to use contractions", "Keep it relaxed and friendly"],
            "professional": ["Be clear and concise", "Focus on key points", "Maintain respectful language"]
        }
        
        return tone_specific_suggestions.get(detected_tone.lower(), base_suggestions)
    
    def _generate_fallback_analysis(self, text: str) -> Dict[str, Any]:
        """Generate complete fallback analysis."""
        return {
            "original_text": text,
            "detected_tone": "neutral",
            "confidence": 0.7,
            "tone_category": "neutral",
            "enhanced_versions": self._generate_fallback_enhancements(text),
            "suggestions": self._generate_fallback_suggestions("neutral"),
            "explanation": "The text appears to have a neutral tone, suitable for general communication."
        }

# Initialize Gemini analyzer
gemini_analyzer = GeminiTextToningAnalyzer()

app = FastAPI(title=APP_NAME)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    """Initialize Gemini on startup."""
    logger.info("Starting Smart Text Toning Analyzer...")
    if gemini_analyzer.initialize():
        logger.info("✅ Gemini Text Toning Analyzer initialized successfully")
    else:
        logger.warning("❌ Gemini initialization failed - using fallback mode")

@app.get("/")
async def root():
    return {
        "message": "Smart Text Toning Analyzer with Gemini",
        "status": "running",
        "gemini_initialized": gemini_analyzer.initialized,
        "service": "text-toning-analyzer"
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "gemini_available": gemini_analyzer.initialized,
        "has_gemini_library": HAS_GEMINI,
        "rate_limit_delay": gemini_analyzer.request_delay
    }

@app.post("/analyze-tone", response_model=ToneAnalysisResponse)
async def analyze_tone(request: ToneAnalysisRequest):
    """Analyze text tone and provide enhanced versions."""
    
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    
    if len(request.text) > 1000:
        raise HTTPException(status_code=400, detail="Text too long. Maximum 1000 characters.")
    
    try:
        # Try Gemini first
        analysis_result = None
        if gemini_analyzer.initialized:
            analysis_result = gemini_analyzer.analyze_tone_and_enhance(
                request.text, 
                request.context
            )
        
        if analysis_result:
            logger.info("Successfully generated tone analysis")
            return JSONResponse(analysis_result)
        
        # Fallback to smart analysis
        logger.info("Using fallback tone analysis")
        fallback_analysis = gemini_analyzer._generate_fallback_analysis(request.text)
        
        return JSONResponse({
            **fallback_analysis,
            "service": "smart-fallback",
            "note": "Gemini unavailable. Using smart fallback analysis."
        })

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error in tone analysis: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during tone analysis")

@app.get("/supported-tones")
async def get_supported_tones():
    """Get list of all supported tone categories."""
    return {
        "supported_tones": [tone.value for tone in ToneCategory],
        "description": "Available tone categories for analysis and enhancement"
    }

@app.post("/quick-analyze")
async def quick_analyze(text: str):
    """Quick tone analysis without enhancements."""
    if not text or not text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    
    # Simple tone detection based on keywords (fallback)
    text_lower = text.lower()
    
    tone_indicators = {
        "formal": ["respectfully", "sincerely", "please be advised", "hereinafter"],
        "casual": ["hey", "hi", "what's up", "lol", "haha", "thanks"],
        "professional": ["team", "meeting", "agenda", "follow up", "action items"],
        "friendly": ["great", "awesome", "wonderful", "happy", "excited"],
        "persuasive": ["should", "must", "highly recommend", "benefit", "advantage"],
        "enthusiastic": ["amazing", "incredible", "fantastic", "wow", "!"]
    }
    
    detected_tone = "neutral"
    max_matches = 0
    
    for tone, indicators in tone_indicators.items():
        matches = sum(1 for indicator in indicators if indicator in text_lower)
        if matches > max_matches:
            max_matches = matches
            detected_tone = tone
    
    return {
        "text": text,
        "detected_tone": detected_tone,
        "confidence": min(0.3 + (max_matches * 0.1), 0.9),
        "method": "keyword-analysis"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")