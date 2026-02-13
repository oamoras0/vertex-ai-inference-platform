from fastapi import FastAPI, HTTPException, Request
from google.cloud import aiplatform
import os
import time
import logging

# Initialize App & Logger
app = FastAPI(title="LLM Inference Gateway")
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("llm-logger")

# Config
PROJECT_ID = os.getenv("GCP_PROJECT_ID", "your-project-id")
ENDPOINT_ID = os.getenv("VERTEX_ENDPOINT_ID", "1234567890")
REGION = os.getenv("REGION", "us-central1")

# Initialize Vertex AI
aiplatform.init(project=PROJECT_ID, location=REGION)

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "llm-gateway"}

@app.post("/predict")
async def predict(request: Request):
    """
    Main inference endpoint.
    Handles: Logging, Latency tracking, and Vertex AI calls.
    """
    start_time = time.time()
    body = await request.json()
    prompt = body.get("prompt")
    
    if not prompt:
        raise HTTPException(status_code=400, detail="Prompt is required")

    try:
        # Get Vertex AI Endpoint
        endpoint = aiplatform.Endpoint(endpoint_name=ENDPOINT_ID)
        
        # Send prediction request (Simplified)
        # In prod, you'd format this for specific models (PaLM, Llama 2)
        response = endpoint.predict(instances=[{"prompt": prompt}])
        
        duration = time.time() - start_time
        
        # Log structured data for Observability (Cloud Logging)
        logger.info({
            "event": "inference_success",
            "latency_ms": round(duration - 1000, 2),
            "input_chars": len(prompt),
            "model_version": response.model_version_id
        })
        
        return {
            "prediction": response.predictions[0],
            "meta": {"latency": f"{round(duration, 2)}s"}
        }

    except Exception as e:
        logger.error(f"Inference failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Model Error")