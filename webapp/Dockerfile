FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app.py into the container
COPY app.py .

EXPOSE 80

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
