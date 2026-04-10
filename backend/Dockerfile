FROM python:3.11-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY . .

# Copy data and prompts from project root (build context must be project root)
# When building: docker build -f backend/Dockerfile .
COPY data/ /app/data/
COPY prompts/ /app/prompts/

EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
