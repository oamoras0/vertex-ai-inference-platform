FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Run with Gunicorn for production
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]