import base64
import io
from pathlib import Path

from PIL import Image

from preprocessing import preprocess_soil_image


def inspect(path: Path) -> tuple[tuple[int, int], int]:
    raw = path.read_bytes()
    img = Image.open(io.BytesIO(raw))
    return img.size, len(raw)


def main() -> None:
    test_dir = Path(__file__).parent / "test_images"
    images = sorted(test_dir.glob("*"))[:3]
    for path in images:
        before_size, before_bytes = inspect(path)
        processed_b64 = preprocess_soil_image(path.read_bytes())
        after = base64.b64decode(processed_b64)
        after_img = Image.open(io.BytesIO(after))
        print(f"{path.name}: before={before_size}/{before_bytes} bytes after={after_img.size}/{len(after)} bytes")


if __name__ == "__main__":
    main()
