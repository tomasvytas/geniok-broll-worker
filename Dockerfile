FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir \
    runpod \
    diffusers>=0.32.0 \
    transformers \
    accelerate \
    safetensors \
    sentencepiece \
    boto3 \
    imageio[ffmpeg] \
    opencv-python-headless \
    torch torchvision

# Copy handler
COPY handler.py /app/handler.py

CMD ["python", "-u", "/app/handler.py"]
