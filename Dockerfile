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
# ล็อก torch ของก้อนเดิม (CUDA 13.0) ไว้ ห้ามส่วนประกอบอื่นเปลี่ยน · ตรวจซ้ำว่ายังเป็น CUDA 13.0 ไม่ใช่ = สร้างไม่ผ่าน
RUN python3 -m pip install -q --no-cache-dir uv \
 && python3 -c "import importlib.metadata as m; [print(p + '==' + m.version(p)) for p in ('torch', 'torchvision', 'torchaudio')]" > /tmp/keep-torch.txt \
 && cat /tmp/keep-torch.txt \
 && python3 -m uv pip install --python "$(command -v python3)" --system --break-system-packages --no-cache \
      -c /tmp/keep-torch.txt -r /opt/ComfyUI/requirements.txt aiohttp huggingface_hub hf_xet \
 && python3 -c "import torch, comfy_kitchen, av, aiohttp, huggingface_hub; assert torch.version.cuda.startswith('13.0'), torch.version.cuda; print('torch', torch.__version__, 'cuda', torch.version.cuda)"
# บันทึกสิ่งที่ติดตั้ง (อ่านได้จากภายนอกเพื่อตรวจ)
RUN { echo "comfy $(git -C /opt/ComfyUI rev-parse HEAD)"; python3 -c "import torch;print('torch', torch.__version__, torch.version.cuda)"; python3 -m pip freeze; } > /opt/sf69-build.txt
