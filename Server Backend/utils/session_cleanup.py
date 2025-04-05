import time
from services.session_service import sessions

async def cleanup_old_sessions():
    """
    Removes old sessions to free up memory.
    """
    current_time = time.time()
    session_timeout = 3600  # 1 hour
    
    to_remove = []
    for session_id, session_data in sessions.items():
        # Find the most recent parameter update
        last_update = 0
        for timestamp in session_data.parameter_timestamps.values():
            if timestamp and timestamp > last_update:
                last_update = timestamp
        
        # If session is old and inactive, mark for removal
        if last_update > 0 and (current_time - last_update) > session_timeout:
            to_remove.append(session_id)
    
    for session_id in to_remove:
        del sessions[session_id]