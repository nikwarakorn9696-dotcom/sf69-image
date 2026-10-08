# เครื่องสำเร็จรูปของหนังสั้น 69: ระบบพื้นฐานตัวเดิม (CUDA 13.0) + ComfyUI ฉบับที่โปรแกรมล็อกไว้ + ส่วนประกอบติดตั้งครบ
# โมเดลไม่ได้อยู่ในนี้ (ใหญ่เกิน) ยังโหลดตอนเปิดเครื่องเหมือนเดิม · สคริปต์เปิดเครื่องยังส่งมาจากโปรแกรมที่บ้าน
FROM runpod/pytorch:1.0.7-rc.138-cu1300-torch291-ubuntu2404
ARG COMFY_SHA=5c460d8172fe30761ff67c0df3d5643bb74e0d70
LABEL org.opencontainers.image.source="https://github.com/nikwarakorn9696-dotcom/sf69-image"
LABEL org.opencontainers.image.description="Short Film 69 rented machine: ComfyUI preinstalled (CUDA 13.0)"
RUN (command -v git && command -v ffmpeg) >/dev/null || (apt-get update -qq && apt-get install -y -qq --no-install-recommends git ffmpeg && rm -rf /var/lib/apt/lists/*)
RUN git init -q /opt/ComfyUI \
 && git -C /opt/ComfyUI remote add origin https://github.com/Comfy-Org/ComfyUI \
 && git -C /opt/ComfyUI fetch -q --depth 1 origin "$COMFY_SHA" \
 && git -C /opt/ComfyUI checkout -q -f FETCH_HEAD
# ล็อก torch ของก้อนเดิม (CUDA 13.0) · torchvision/torchaudio ต้องเป็นรุ่น cu130 คู่กับ torch เท่านั้น (รุ่นทั่วไปจาก PyPI ทำ ComfyUI เปิดไม่ขึ้น)
RUN python3 -m pip install -q --no-cache-dir uv \
 && TV=$(python3 -c "import torch; print(torch.__version__)") \
 && echo "base torch $TV" \
 && printf 'torch==%s\ntorchvision==0.24.1+cu130\ntorchaudio==2.9.1+cu130\n' "$TV" > /tmp/keep-torch.txt \
 && cat /tmp/keep-torch.txt \
 && python3 -m uv pip install --python "$(command -v python3)" --system --break-system-packages --no-cache \
      --extra-index-url https://download.pytorch.org/whl/cu130 --index-strategy unsafe-best-match \
      -c /tmp/keep-torch.txt torchvision torchaudio -r /opt/ComfyUI/requirements.txt aiohttp huggingface_hub hf_xet \
 && python3 -c "import torch, torchvision, torchaudio, comfy_kitchen, av, aiohttp, huggingface_hub; assert torch.version.cuda.startswith('13.0'), torch.version.cuda; print('torch', torch.__version__, 'vision', torchvision.__version__, 'audio', torchaudio.__version__, 'cuda', torch.version.cuda)"
# ตรวจว่า ComfyUI เปิดได้จริง (โหลดทุกส่วนแล้วปิด) ไม่ผ่าน = สร้างไม่ผ่าน ไม่ปล่อยก้อนเสียออกไป
RUN bash -c 'set -o pipefail; cd /opt/ComfyUI && python3 main.py --quick-test-for-ci --cpu 2>&1 | tail -15'
# บันทึกสิ่งที่ติดตั้ง (อ่านได้จากภายนอกเพื่อตรวจ)
RUN { echo "comfy $(git -C /opt/ComfyUI rev-parse HEAD)"; python3 -c "import torch, torchvision;print('torch', torch.__version__, torch.version.cuda, 'vision', torchvision.__version__)"; python3 -m pip freeze; } > /opt/sf69-build.txt
