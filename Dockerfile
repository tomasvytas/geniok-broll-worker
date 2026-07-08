FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install Python
RUN apt-get update && apt-get install -y python3.11 python3.11-venv python3-pip git && \
    ln -sf /usr/bin/python3.11 /usr/bin/python && \
    ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install PyTorch + dependencies (clean environment, no flash_attn)
RUN pip install --no-cache-dir \
    torch==2.4.0 torchvision --index-url https://download.pytorch.org/whl/cu124

RUN pip install --no-cache-dir \
    runpod \
    diffusers \
    transformers \
    accelerate \
    safetensors \
    sentencepiece \
    boto3 \
    imageio \
    imageio-ffmpeg \
    opencv-python-headless \
    ftfy

# Copy handler
COPY handler.py /app/handler.py

CMD ["python", "-u", "/app/handler.py"]
