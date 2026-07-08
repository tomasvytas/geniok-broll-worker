FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

WORKDIR /app

# Install compatible versions
RUN pip install --no-cache-dir \
    runpod \
    "diffusers[torch]>=0.33.0" \
    "transformers>=4.45.0" \
    "accelerate>=0.34.0" \
    safetensors \
    sentencepiece \
    boto3 \
    imageio[ffmpeg] \
    imageio \
    opencv-python-headless \
    ftfy

# Upgrade torch to match diffusers requirements
RUN pip install --no-cache-dir --upgrade torch torchvision --index-url https://download.pytorch.org/whl/cu124

# Copy handler
COPY handler.py /app/handler.py

CMD ["python", "-u", "/app/handler.py"]
