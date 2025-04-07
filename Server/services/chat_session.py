from typing import Dict, List, Optional, Tuple, Any
import time

class ChatSession:
    def __init__(self):
        self.parameters: Dict[str, Any] = {}  # Dynamic parameters storage
        self.ml_activated: bool = False
        self.inference_cache: Dict[Tuple, Any] = {}  # {parameter_hash: inference_result}
        self.parameter_timestamps: Dict[str, float] = {}  # Track when parameters were last updated
        self.chat_history: List[Dict[str, str]] = []  # Store conversation history
    
    def update_parameter(self, param_name: str, value: Any) -> None:
        self.parameters[param_name] = value
        self.parameter_timestamps[param_name] = time.time()
    
    def set_ml_activation(self, activated: bool) -> None:
        self.ml_activated = activated
    
    def can_run_inference(self) -> bool:
        return (self.ml_activated and 
                'A' in self.parameters and self.parameters['A'] is not None and 
                'B' in self.parameters and self.parameters['B'] is not None)
    
    def get_cache_key(self) -> Tuple:
        # Create a hashable representation of all parameters
        param_items = sorted(self.parameters.items())
        return tuple(param_items)
    
    def get_cached_result(self) -> Optional[Any]:
        key = self.get_cache_key()
        return self.inference_cache.get(key)
    
    def cache_result(self, result: Any) -> None:
        key = self.get_cache_key()
        self.inference_cache[key] = result
    
    def get_missing_required_parameters(self) -> List[str]:
        missing = []
        if 'A' not in self.parameters or self.parameters['A'] is None:
            missing.append('A')
        if 'B' not in self.parameters or self.parameters['B'] is None:
            missing.append('B')
        return missing
    
    def add_message(self, message: Dict[str, str]) -> None:
        """Add a message to the chat history."""
        self.chat_history.append(message)
    
    def get_chat_history(self) -> List[Dict[str, str]]:
        """Get the chat history."""
        return self.chat_history