# Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .
RUN python create_database.py

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]