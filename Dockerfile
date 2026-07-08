FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install Python 3.11
RUN apt-get update && apt-get install -y \
    python3.11 python3.11-venv python3.11-dev python3-pip git wget \
    && ln -sf /usr/bin/python3.11 /usr/bin/python \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install PyTorch 2.5.1 (has fixed infer_schema)
RUN pip install --no-cache-dir \
    torch==2.5.1 torchvision==0.20.1 --index-url https://download.pytorch.org/whl/cu124

# diffusers 0.33.0 has WanPipeline + torch 2.5.1 has fixed infer_schema
RUN pip install --no-cache-dir \
    diffusers==0.33.0 \
    transformers==4.47.0 \
    accelerate==0.34.2 \
    safetensors \
    sentencepiece

RUN pip install --no-cache-dir \
    runpod \
    boto3 \
    imageio \
    imageio-ffmpeg \
    opencv-python-headless \
    ftfy

# Copy handler
COPY handler.py /app/handler.py

CMD ["python", "-u", "/app/handler.py"]
