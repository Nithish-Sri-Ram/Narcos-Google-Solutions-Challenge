from pydantic import BaseModel, Field
from typing import Dict, Any, List, Optional
from datetime import datetime
import uuid

class ChatRequest(BaseModel):
    message: str
    ml_activated: bool = False
    chat_id: str

class ChatResponse(BaseModel):
    response: str
    session_id: str
    chat_id: str
    parameters: Dict[str, Any]
    ml_activated: bool

class ResetResponse(BaseModel):
    status: str
    message: str

class CreateChatRequest(BaseModel):
    username: str
    title: Optional[str] = "New Chat"

class CreateChatResponse(BaseModel):
    chat_id: str
    title: str
    created_at: datetime

class ChatHistoryItem(BaseModel):
    chat_id: str
    title: str
    username: str
    created_at: datetime
    last_message_at: Optional[datetime] = None
    last_message_preview: Optional[str] = None

class UserChatsResponse(BaseModel):
    chats: List[ChatHistoryItem]

class MessageModel(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    chat_id: str
    role: str  # "user" or "assistant"
    content: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    ml_activated: bool = False
    parameters: Optional[Dict[str, Any]] = None