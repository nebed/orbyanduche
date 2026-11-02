FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1

COPY requirements.txt ./
RUN pip install --no-cache-dir --no-compile -r requirements.txt

COPY app.py create_database.py set_admin_password.py wsgi.py logo.jpg ./

RUN groupadd --gid 10001 app \
	&& useradd --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app \
	&& mkdir -p /app/instance /app/qrcodes \
	&& chown -R app:app /app

USER 10001:10001
EXPOSE 5000

CMD ["gunicorn", "--workers", "1", "--bind", "0.0.0.0:5000", "--access-logfile", "-", "--error-logfile", "-", "--timeout", "120", "wsgi:app"]