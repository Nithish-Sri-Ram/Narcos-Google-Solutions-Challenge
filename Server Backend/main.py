import asyncio
import uuid
from fastapi import FastAPI, Request, Response, Depends, HTTPException
from starlette.middleware.sessions import SessionMiddleware
import uvicorn

from models.pydantic_models import (
    ChatRequest, 
    ChatResponse, 
    ResetResponse, 
    CreateChatRequest, 
    CreateChatResponse,
    UserChatsResponse
)
from services.chat_session import ChatSession
from services.session_service import sessions, get_session
from services.llm_service import process_message, generate_chat_summary
from services.chat_service import (
    create_chat, 
    get_user_chats, 
    store_message, 
    get_chat_messages,
    chat_exists
)
from utils.session_cleanup import cleanup_old_sessions

app = FastAPI(title="Drug Discovery")
app.add_middleware(SessionMiddleware, secret_key="your_secret_key")

@app.post("/chats", response_model=CreateChatResponse)
async def start_new_chat(request: CreateChatRequest):
    """
    Create a new chat and return its unique ID.
    This should be called before starting a conversation.
    """
    chat_id = await create_chat(request.username, request.title)
    
    sessions[chat_id] = ChatSession()
    
    chat = await get_chat_details(chat_id)
    return CreateChatResponse(
        chat_id=chat_id,
        title=request.title,
        created_at=chat.get("created_at")
    )

@app.get("/users/{username}/chats", response_model=UserChatsResponse)
async def get_user_chat_history(username: str):
    """
    Get all chats for a user.
    This will be used in the navigation bar to show past chats.
    """
    chats = await get_user_chats(username)
    return UserChatsResponse(chats=chats)

async def get_chat_details(chat_id: str):
    """
    Helper function to get chat details.
    """
    from models.database import chats_collection
    
    chat = await chats_collection.find_one({"chat_id": chat_id})
    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")
    
    return chat

@app.post("/chat", response_model=ChatResponse)
async def chat(chat_request: ChatRequest, request: Request, response: Response):
    """
    API endpoint for chat interactions.
    """
    if not await chat_exists(chat_request.chat_id):
        raise HTTPException(status_code=404, detail="Chat not found")
    
    session = sessions.get(chat_request.chat_id)
    if not session:
        session = ChatSession()
        sessions[chat_request.chat_id] = session
    
    await store_message(
        chat_id=chat_request.chat_id,
        role="user",
        content=chat_request.message
    )
    
    response_text, updated_params = await process_message(
        chat_request.message, 
        session, 
        chat_request.ml_activated
    )
    
    await store_message(
        chat_id=chat_request.chat_id,
        role="assistant",
        content=response_text,
        ml_activated=session.ml_activated,
        parameters=updated_params
    )
    
    return ChatResponse(
        response=response_text,
        session_id=chat_request.chat_id,
        chat_id=chat_request.chat_id,
        parameters=updated_params,
        ml_activated=session.ml_activated
    )

@app.get("/chats/{chat_id}/messages")
async def get_chat_message_history(chat_id: str):
    """
    Get all messages for a specific chat.
    """
    if not await chat_exists(chat_id):
        raise HTTPException(status_code=404, detail="Chat not found")
    
    messages = await get_chat_messages(chat_id)
    return {"messages": [message.dict() for message in messages]}

@app.get("/chats/{chat_id}/summary")
async def get_chat_summary(chat_id: str):
    """
    Generate an article summary of a particular chat.
    Returns an article title and content based on the chat history.
    """
    if not await chat_exists(chat_id):
        raise HTTPException(status_code=404, detail="Chat not found")
    
    messages = await get_chat_messages(chat_id)
    
    summary = await generate_chat_summary(messages)
    
    return summary

@app.post("/reset", response_model=ResetResponse)
async def reset_session(request: Request):
    """
    API endpoint to reset a session.
    """
    session_id = request.cookies.get("session_id")
    
    if session_id and session_id in sessions:
        sessions[session_id] = ChatSession()
    
    return ResetResponse(
        status="success",
        message="Session reset successfully."
    )

@app.on_event("startup")
async def startup_event():
    async def periodic_cleanup():
        while True:
            await cleanup_old_sessions()
            await asyncio.sleep(900)
    
    asyncio.create_task(periodic_cleanup())

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)