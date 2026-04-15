FROM python:3.11-slim
WORKDIR /app

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy only the backend code (not the entire repo's flutter_app etc)
COPY backend/ .

# Copy data and prompts from project root 
COPY data/ ./data/
COPY prompts/ ./prompts/

EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
