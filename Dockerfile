# Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY .env app.py create_database.py wsgi.py personal-projects-384213-dd7304a43459.json ./

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]