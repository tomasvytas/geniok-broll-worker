FROM pytorch/pytorch:2.6.0-cuda12.6-cudnn9-devel

ENV PYTHONUNBUFFERED=1
ENV HF_HOME=/tmp/hf_cache
ENV TRANSFORMERS_CACHE=/tmp/hf_cache

WORKDIR /app

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

COPY handler.py /app/handler.py

CMD ["python", "-u", "/app/handler.py"]
