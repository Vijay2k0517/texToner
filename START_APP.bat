@echo off
echo ================================
echo   Text Toner - Quick Start
echo ================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/
    pause
    exit /b 1
)

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
)

echo [✓] Python found
echo [✓] Flutter found
echo.

REM Check for .env file
if not exist "backend\.env" (
    echo [WARNING] backend\.env file not found!
    echo.
    echo Please create backend\.env file with:
    echo GEMINI_API_KEY=your_api_key_here
    echo.
    echo Get your API key from: https://makersuite.google.com/app/apikey
    echo.
    pause
    exit /b 1
)

echo [✓] Environment file found
echo.
echo Starting services...
echo.

REM Start backend in a new window
echo [1/2] Starting Backend Server...
start "Text Toner Backend" cmd /k "cd backend && python main.py"

REM Wait a few seconds for backend to start
timeout /t 5 /nobreak >nul

REM Start frontend in a new window
echo [2/2] Starting Flutter Frontend...
start "Text Toner Frontend" cmd /k "cd frontend && flutter run -d windows"

echo.
echo ================================
echo   Services Started!
echo ================================
echo.
echo Backend: http://localhost:8000
echo Frontend: Running in separate window
echo.
echo Press any key to close this window...
pause >nul
