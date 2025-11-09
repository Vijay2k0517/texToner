"""Quick script to view SQLite database contents"""
import sqlite3
from datetime import datetime

def view_database():
    conn = sqlite3.connect('text_toner.db')
    cursor = conn.cursor()
    
    print("\n" + "="*80)
    print("👥 USERS TABLE")
    print("="*80)
    cursor.execute('SELECT id, email, full_name, created_at FROM users')
    users = cursor.fetchall()
    
    if users:
        print(f"{'ID':<5} {'Email':<30} {'Full Name':<20} {'Created At':<20}")
        print("-" * 80)
        for row in users:
            print(f"{row[0]:<5} {row[1]:<30} {row[2] or 'N/A':<20} {row[3]:<20}")
        print(f"\nTotal Users: {len(users)}")
    else:
        print("No users found")
    
    print("\n" + "="*80)
    print("💬 CONVERSATIONS TABLE")
    print("="*80)
    cursor.execute('''
        SELECT c.id, c.user_id, u.email, c.original_text, c.detected_tone, 
               c.tone_category, c.confidence, c.created_at
        FROM conversations c
        LEFT JOIN users u ON c.user_id = u.id
        ORDER BY c.created_at DESC
    ''')
    conversations = cursor.fetchall()
    
    if conversations:
        print(f"{'ID':<5} {'User':<25} {'Text Preview':<30} {'Tone':<15} {'Confidence':<12} {'Created':<20}")
        print("-" * 120)
        for row in conversations:
            text_preview = (row[3][:27] + '...') if len(row[3]) > 30 else row[3]
            confidence = f"{row[6]:.2f}" if row[6] else "N/A"
            print(f"{row[0]:<5} {row[2]:<25} {text_preview:<30} {row[4] or 'N/A':<15} {confidence:<12} {row[7]:<20}")
        print(f"\nTotal Conversations: {len(conversations)}")
    else:
        print("No conversations found")
    
    # Show detailed view of latest conversation
    if conversations:
        print("\n" + "="*80)
        print("📝 LATEST CONVERSATION DETAILS")
        print("="*80)
        latest = conversations[0]
        cursor.execute('SELECT analysis_json FROM conversations WHERE id = ?', (latest[0],))
        analysis = cursor.fetchone()[0]
        
        print(f"ID: {latest[0]}")
        print(f"User: {latest[2]}")
        print(f"Original Text: {latest[3]}")
        print(f"Detected Tone: {latest[4]}")
        print(f"Tone Category: {latest[5]}")
        print(f"Confidence: {latest[6]}")
        print(f"Created At: {latest[7]}")
        print(f"\nFull Analysis JSON:")
        print(analysis)
    
    conn.close()
    print("\n" + "="*80)

if __name__ == "__main__":
    view_database()
