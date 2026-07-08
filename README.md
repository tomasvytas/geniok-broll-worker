# RunPod Worker — Wan 2.1 Text-to-Video (B-Roll Generator)

## Deploy to RunPod Serverless

### Option A: Deploy from GitHub
1. Push this folder to a separate GitHub repo (e.g. `geniok-broll-worker`)
2. In RunPod Serverless → "Deploy from a GitHub repository"
3. Point to the repo, select Dockerfile
4. Set environment variables (see below)
5. Configure: GPU Type = H100/L40S, Max Workers = 3

### Option B: Build & Push Docker Image
```bash
cd runpod-worker
docker build -t your-registry/geniok-broll:latest .
docker push your-registry/geniok-broll:latest
```
Then in RunPod → "Deploy from a Docker Image" → paste the image URL.

## Environment Variables (set in RunPod endpoint config)
```
R2_ACCOUNT_ID=your-cloudflare-account-id
R2_ACCESS_KEY_ID=your-r2-access-key
R2_SECRET_ACCESS_KEY=your-r2-secret-key
R2_BUCKET=geniok
R2_PUBLIC_URL=https://pub-your-id.r2.dev
```

## API Usage
Once deployed, the endpoint accepts:
```json
POST https://api.runpod.ai/v2/{endpoint_id}/run
{
  "input": {
    "prompt": "Woman walking in a sunny park, smiling, cinematic",
    "aspect_ratio": "9:16",
    "num_frames": 81,
    "num_inference_steps": 30
  }
}
```

Returns:
```json
{
  "video_url": "https://pub-xxx.r2.dev/broll/abc123.mp4",
  "prompt": "..."
}
```

## Notes
- Model: Wan-AI/Wan2.1-T2V-14B (14B parameter text-to-video)
- Output: 5 seconds at 16fps (81 frames) at 480p
- VRAM: ~40GB (needs H100 80GB or L40S 48GB)
- Cold start: ~60s (model loading), warm: ~45-60s per video
