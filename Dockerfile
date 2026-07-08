FROM runpod/pytorch:2.5.1-py3.11-cuda12.4.1-devel-ubuntu22.04

WORKDIR /app

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

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

# Disable torch compile to avoid infer_schema issues
ENV TORCH_COMPILE_DISABLE=1
ENV DIFFUSERS_DISABLE_COMPILE=1

CMD ["python", "-u", "/app/handler.py"]
