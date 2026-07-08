"""
RunPod Serverless Handler — Wan 2.1 Text-to-Video (14B)
Generates B-roll clips from text prompts.
Model cached on network volume for fast warm starts.
"""

# MUST be before any other imports — patch flash_attn to prevent infer_schema crash
import sys
import types

# Create a fake flash_attn module so diffusers doesn't try to import the real one
fake_flash = types.ModuleType("flash_attn")
fake_flash.flash_attn_func = None
fake_flash.flash_attn_varlen_func = None
sys.modules["flash_attn"] = fake_flash
sys.modules["flash_attn.flash_attn_interface"] = fake_flash
sys.modules["flash_attn.bert_padding"] = fake_flash

import runpod
import torch
import os
import uuid
import tempfile
import boto3
from pathlib import Path

# Model will be downloaded to network volume (persists between cold starts)
MODEL_ID = "Wan-AI/Wan2.1-T2V-14B"
CACHE_DIR = "/runpod-volume/models" if os.path.exists("/runpod-volume") else "/tmp/models"
pipe = None


def load_model():
    global pipe
    if pipe is not None:
        return pipe

    # Disable torch compile to avoid infer_schema conflicts
    torch._dynamo.config.suppress_errors = True
    
    from diffusers import WanPipeline

    print(f"Loading Wan 2.1 14B from {CACHE_DIR}...")
    os.makedirs(CACHE_DIR, exist_ok=True)

    pipe = WanPipeline.from_pretrained(
        MODEL_ID,
        torch_dtype=torch.float16,
        cache_dir=CACHE_DIR,
    )
    pipe.enable_model_cpu_offload()
    print("Model loaded and ready!")
    return pipe


def upload_to_r2(video_path: str) -> str:
    """Upload video to Cloudflare R2 and return public URL."""
    r2_account = os.environ.get("R2_ACCOUNT_ID", "")
    r2_key = os.environ.get("R2_ACCESS_KEY_ID", "")
    r2_secret = os.environ.get("R2_SECRET_ACCESS_KEY", "")
    r2_bucket = os.environ.get("R2_BUCKET", "geniok")
    r2_public = os.environ.get("R2_PUBLIC_URL", "")

    if not all([r2_account, r2_key, r2_secret, r2_public]):
        raise ValueError("R2 credentials not configured")

    s3 = boto3.client(
        "s3",
        endpoint_url=f"https://{r2_account}.r2.cloudflarestorage.com",
        aws_access_key_id=r2_key,
        aws_secret_access_key=r2_secret,
    )

    key = f"broll/{uuid.uuid4().hex}.mp4"
    s3.upload_file(
        video_path, r2_bucket, key,
        ExtraArgs={"ContentType": "video/mp4"}
    )

    return f"{r2_public}/{key}"


def handler(job):
    """Process a single B-roll generation request."""
    job_input = job["input"]

    prompt = job_input.get("prompt", "")
    if not prompt:
        return {"error": "prompt is required"}

    # Parameters
    aspect_ratio = job_input.get("aspect_ratio", "9:16")
    num_inference_steps = job_input.get("num_inference_steps", 30)
    guidance_scale = job_input.get("guidance_scale", 5.0)
    
    # 81 frames = ~5 seconds at 16fps
    num_frames = job_input.get("num_frames", 81)

    # Resolution based on aspect ratio (480p base for speed)
    if aspect_ratio == "9:16":
        height, width = 832, 480
    elif aspect_ratio == "16:9":
        height, width = 480, 832
    elif aspect_ratio == "1:1":
        height, width = 640, 640
    else:
        height, width = 832, 480

    try:
        model = load_model()

        print(f"Generating: '{prompt[:80]}...' ({width}x{height}, {num_frames} frames)")

        # Generate video
        output = model(
            prompt=prompt,
            negative_prompt="ugly, blurry, text, watermark, logo, low quality, distorted, static, frozen",
            num_frames=num_frames,
            height=height,
            width=width,
            guidance_scale=guidance_scale,
            num_inference_steps=num_inference_steps,
        )

        # Export to file
        from diffusers.utils import export_to_video
        video_path = os.path.join(tempfile.gettempdir(), f"{uuid.uuid4().hex}.mp4")
        export_to_video(output.frames[0], video_path, fps=16)

        # Upload to R2
        video_url = upload_to_r2(video_path)

        # Cleanup
        os.remove(video_path)

        print(f"Done: {video_url}")
        return {"video_url": video_url, "prompt": prompt}

    except Exception as e:
        print(f"Error: {e}")
        return {"error": str(e)}


# Start the serverless handler
runpod.serverless.start({"handler": handler})
