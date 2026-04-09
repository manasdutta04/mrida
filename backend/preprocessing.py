import base64
import io

from PIL import Image, ImageEnhance


def preprocess_soil_image(image_bytes: bytes) -> str:
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    max_dim = 1024
    w, h = img.size
    scale = min(max_dim / w, max_dim / h)
    if scale < 1:
        img = img.resize((int(w * scale), int(h * scale)), Image.LANCZOS)

    r, g, b = img.split()
    r_mean = r.getextrema()[1]
    b_mean = b.getextrema()[1]
    r = r.point(lambda p: min(255, int(p * (128 / max(r_mean, 1)))))
    b = b.point(lambda p: min(255, int(p * (128 / max(b_mean, 1)))))
    img = Image.merge("RGB", (r, g, b))

    img = ImageEnhance.Contrast(img).enhance(1.15)

    buffer = io.BytesIO()
    img.save(buffer, format="JPEG", quality=90)
    return base64.b64encode(buffer.getvalue()).decode("utf-8")
