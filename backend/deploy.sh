#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${1:-$FIREBASE_PROJECT_ID}"
if [ -z "${PROJECT_ID:-}" ]; then
  echo "Usage: ./deploy.sh <gcp-project-id>"
  exit 1
fi

gcloud builds submit --tag "gcr.io/${PROJECT_ID}/mrida-backend"
gcloud run deploy mrida-backend \
  --image "gcr.io/${PROJECT_ID}/mrida-backend" \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-secrets GEMINI_API_KEY=gemini-api-key:latest \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10
