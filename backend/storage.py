import os
import uuid
from datetime import datetime, timezone

import firebase_admin
from firebase_admin import credentials, firestore, storage


if not firebase_admin._apps:
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(
        cred,
        {
            "projectId": os.environ.get("FIREBASE_PROJECT_ID"),
            "storageBucket": f"{os.environ.get('FIREBASE_PROJECT_ID')}.appspot.com",
        },
    )


async def store_scan_result(result: dict, image_bytes: bytes, request) -> tuple[str, str]:
    scan_id = str(uuid.uuid4())
    bucket = storage.bucket()
    blob = bucket.blob(f"users/{request.user_id}/scans/{scan_id}.jpg")
    blob.upload_from_string(image_bytes, content_type="image/jpeg")
    blob.make_public()
    image_url = blob.public_url

    db = firestore.client()
    payload = {
        "scan_id": scan_id,
        "field_id": request.field_id,
        "user_id": request.user_id,
        "state": request.state,
        "district": request.district,
        "season": request.season,
        "crop": request.crop,
        "language": request.language,
        "location": {"latitude": request.latitude, "longitude": request.longitude},
        "created_at": datetime.now(timezone.utc).isoformat(),
        **result,
        "image_url": image_url,
    }
    db.collection("users").document(request.user_id).collection("scans").document(scan_id).set(payload)
    return scan_id, image_url
