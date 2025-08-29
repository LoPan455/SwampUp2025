
import os
from pathlib import Path
from typing import List, Dict

import torch
import frogml
from frogml import FrogMlModel
from frogml.sdk.model.adapters import DataFrameInputAdapter, JsonOutputAdapter
from frogml.sdk.model.schema import ExplicitFeature, InferenceOutput, ModelSchema
from frogml.core.clients.secret_service import SecretServiceClient

# =============================================================================
# Configuration
# =============================================================================
HF_MODEL_ID = "Helsinki-NLP/opus-mt-tc-bible-big-afa-en"
LOCAL_MODEL_DIR = Path("./hf_models/opus-mt-afa-en")
FROGML_MODEL_ID = "helsinki_nlp"
FROGML_PROJECT = "setup"

HF_ENDPOINT = "https://swampupml.jfrog.io/artifactory/api/huggingfaceml/test-blm-hf-remote/"
HF_SECRET_NAME = "demo-hf-proxy-token"

class HFTranslationModel(FrogMlModel):
    """
    HuggingFace translation model for Afro-Asiatic languages to English.
    
    This model downloads and caches HuggingFace models during build phase,
    then loads them from cache during initialization for fast inference.
    """
    
    def __init__(self):
        """Initialize model attributes."""
        self.translator = None
        self.model = None
        self.tokenizer = None
        
    def build(self):
        """
        Download and cache models during build phase.
        
        This method downloads the HuggingFace models from JFrog proxy and caches
        them locally. The cached models are then baked into the container image
        for fast startup during inference.
        """
        print("Building model - downloading and caching HuggingFace models...")
        
        # Set up JFrog proxy configuration BEFORE importing transformers
        print(f"Setting HF_ENDPOINT to: {HF_ENDPOINT}")
        os.environ["HF_ENDPOINT"] = HF_ENDPOINT
        
        # Get authentication token from secret service
        try:
            secret_service = SecretServiceClient()
            hf_token = secret_service.get_secret(HF_SECRET_NAME)
            if hf_token:
                os.environ["HF_TOKEN"] = hf_token
                print("✅ HF_TOKEN set from secret service: " + hf_token)
            else:
                print("⚠️  HF_TOKEN not found in secret service")
        except Exception as e:
            print(f"⚠️  Warning: Could not initialize secret service: {e}")
        
        # NOW import transformers after env vars are set
        from transformers import pipeline, AutoTokenizer, AutoModelForSeq2SeqLM
        
        # Create local cache directory and download models
        LOCAL_MODEL_DIR.mkdir(parents=True, exist_ok=True)
        print(f"Downloading model {HF_MODEL_ID} to {LOCAL_MODEL_DIR}...")
        
        try:
            # Download and cache tokenizer and model
            print("Downloading tokenizer...")
            AutoTokenizer.from_pretrained(
                HF_MODEL_ID, 
                cache_dir=LOCAL_MODEL_DIR,
                trust_remote_code=True
            )
            print("✅ Tokenizer downloaded successfully")
            
            print("Downloading model...")
            AutoModelForSeq2SeqLM.from_pretrained(
                HF_MODEL_ID,
                cache_dir=LOCAL_MODEL_DIR,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
                device_map="auto"
            )
            print("✅ Model downloaded successfully")
            
            print("Model build completed successfully!")
        except Exception as e:
            print(f"❌ Error during model build: {e}")
            raise RuntimeError(f"Failed to download models: {e}") from e
    
    def initialize_model(self):
        """
        Load cached models and create inference pipeline.
        
        This method loads the previously cached models from local storage and
        creates the translation pipeline. This is a fast operation with no
        network calls, ideal for container startup.
        """
        print("Initializing model from cache...")
        
        if not LOCAL_MODEL_DIR.exists():
            raise RuntimeError("Model cache not found. Run build() first.")
            
        # Import transformers here too (for consistency)
        from transformers import pipeline, AutoTokenizer, AutoModelForSeq2SeqLM
            
        try:
            # Load models from cache using the original model ID
            print("Loading tokenizer from cache...")
            self.tokenizer = AutoTokenizer.from_pretrained(
                HF_MODEL_ID, 
                cache_dir=LOCAL_MODEL_DIR,
                trust_remote_code=True
            )
            print("✅ Tokenizer loaded from cache")
            
            print("Loading model from cache...")
            self.model = AutoModelForSeq2SeqLM.from_pretrained(
                HF_MODEL_ID,
                cache_dir=LOCAL_MODEL_DIR,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
                device_map="auto"
            )
            print("✅ Model loaded from cache")
            
            # Create translation pipeline using loaded models
            print("Creating translation pipeline...")
            self.translator = pipeline(
                "translation", 
                model=self.model, 
                tokenizer=self.tokenizer
            )
            print("✅ Translation pipeline created")
            
            print("Model initialization completed!")
        except Exception as e:
            print(f"❌ Error during model initialization: {e}")
            raise RuntimeError(f"Failed to initialize models: {e}") from e
    
    def schema(self):
        """Define the model's input/output schema."""
        return ModelSchema(
            inputs=[ExplicitFeature(name="input", type=str)],
            outputs=[InferenceOutput(name="translation", type=str)]
        )
    
    @frogml.api(input_adapter=DataFrameInputAdapter(), 
                output_adapter=JsonOutputAdapter())
    def predict(self, df):
        """
        Translate input texts from source language to English.
        
        Args:
            df: DataFrame with an "input" column containing text to translate.
            
        Returns:
            List of dictionaries, each containing a "translation" key with translated text.
        """
        
        if self.translator is None:
            raise RuntimeError("Model not initialized. Call initialize_model() first.")
        
        # Extract input texts from DataFrame column
        input_texts = df["input"].tolist()
        translated_texts = self.translator(input_texts)
        
        # Format output as expected by the API
        output_data = [{"translation": item["translation_text"]} for item in translated_texts]
        
        return [output_data]


