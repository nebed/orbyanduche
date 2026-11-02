#!/usr/bin/env python3
"""Read one admin password from stdin and store only its hash in SQLite."""

import sys

from werkzeug.security import generate_password_hash

from app import AdminCredential, app, db


password = sys.stdin.readline().rstrip("\r\n")
if len(password) < 32:
    raise SystemExit("Expected a generated password of at least 32 characters.")

with app.app_context():
    credential = AdminCredential.query.filter_by(username="admin").first()
    if credential is None:
        credential = AdminCredential(username="admin", password_hash="")
        db.session.add(credential)
    credential.password_hash = generate_password_hash(password)
    db.session.commit()

print("Admin password hash stored for username 'admin'.")
