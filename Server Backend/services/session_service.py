import uuid
from typing import Dict, Tuple, Any
from fastapi import Request

from services.chat_session import ChatSession

sessions: Dict[str, Any] = {}

def get_session(request: Request) -> Tuple[ChatSession, str]:
    """
    Get or create a session for the current request.
    """
    session_id = request.cookies.get("session_id")
    
    if not session_id or session_id not in sessions:
        session_id = str(uuid.uuid4())
        sessions[session_id] = ChatSession()
    
    return sessions[session_id], session_id