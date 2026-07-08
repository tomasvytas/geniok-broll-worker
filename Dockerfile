FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv git wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install PyTorch 2.5.1 with CUDA 12.4
RUN pip3 install --no-cache-dir \
    torch==2.5.1 torchvision==0.20.1 \
    --index-url https://download.pytorch.org/whl/cu124

# diffusers 0.33.0 has WanPipeline
RUN pip3 install --no-cache-dir \
    diffusers==0.33.0 \
    transformers==4.47.0 \
    accelerate==0.34.2 \
    safetensors \
    sentencepiece

RUN pip3 install --no-cache-dir \
    runpod \
    boto3 \
    imageio \
    imageio-ffmpeg \
    opencv-python-headless \
    ftfy

COPY handler.py /app/handler.py

CMD ["python3", "-u", "/app/handler.py"]
