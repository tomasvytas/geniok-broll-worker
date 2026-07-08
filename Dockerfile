FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

WORKDIR /app

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Remove flash_attn that comes with base image — it conflicts with diffusers Wan pipeline
RUN pip uninstall -y flash_attn flash-attn || true

RUN pip install --no-cache-dir \
    runpod \
    boto3 \
    imageio \
    imageio-ffmpeg \
    opencv-python-headless \
    safetensors \
    sentencepiece \
    ftfy

RUN pip install --no-cache-dir \
    diffusers \
    transformers \
    accelerate

# Copy handler
COPY handler.py /app/handler.py

CMD ["python", "-u", "/app/handler.py"]
