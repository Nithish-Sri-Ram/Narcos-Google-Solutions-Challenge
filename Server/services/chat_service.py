from typing import List, Dict, Any, Optional
import uuid
from datetime import datetime

from models.database import chats_collection, messages_collection
from models.pydantic_models import ChatHistoryItem, MessageModel

async def create_chat(username: str, title: str = "New Chat") -> str:
    """
    Create a new chat and return its ID.
    """
    chat_id = str(uuid.uuid4())
    now = datetime.utcnow()
    
    await chats_collection.insert_one({
        "chat_id": chat_id,
        "username": username,
        "title": title,
        "created_at": now,
        "last_message_at": None,
        "last_message_preview": None
    })
    
    return chat_id

async def get_user_chats(username: str) -> List[ChatHistoryItem]:
    """
    Get all chats for a user.
    """
    chats = []
    cursor = chats_collection.find({"username": username}).sort("last_message_at", -1)
    
    async for chat in cursor:
        chats.append(ChatHistoryItem(
            chat_id=chat["chat_id"],
            title=chat["title"],
            username=chat["username"],
            created_at=chat["created_at"],
            last_message_at=chat.get("last_message_at"),
            last_message_preview=chat.get("last_message_preview")
        ))
    
    return chats

async def store_message(
    chat_id: str,
    role: str,
    content: str,
    ml_activated: bool = False,
    parameters: Optional[Dict[str, Any]] = None
) -> str:
    """
    Store a message in the database and update chat metadata.
    """
    now = datetime.utcnow()
    message = MessageModel(
        chat_id=chat_id,
        role=role,
        content=content,
        created_at=now,
        ml_activated=ml_activated,
        parameters=parameters or {}
    )
    
    await messages_collection.insert_one(message.dict())
    
    preview = content[:50] + "..." if len(content) > 50 else content
    await chats_collection.update_one(
        {"chat_id": chat_id},
        {"$set": {
            "last_message_at": now,
            "last_message_preview": preview
        }}
    )
    
    return message.id

async def get_chat_messages(chat_id: str) -> List[MessageModel]:
    """
    Get all messages for a chat.
    """
    messages = []
    cursor = messages_collection.find({"chat_id": chat_id}).sort("created_at", 1)
    
    async for msg in cursor:
        messages.append(MessageModel(**msg))
    
    return messages

async def chat_exists(chat_id: str) -> bool:
    """
    Check if a chat exists.
    """
    count = await chats_collection.count_documents({"chat_id": chat_id})
    return count > 0