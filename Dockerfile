FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel

ENV PYTHONUNBUFFERED=1

WORKDIR /app

# diffusers 0.33.0 has WanPipeline
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
