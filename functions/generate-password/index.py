from flask import request
import os
import string
import secrets
import psycopg2
import qrcode
import io
import base64
import sys
import json
print("DEBUG: index.py chargé", file=sys.stderr)


# Environnement : variables DB
DB_HOST = os.getenv('POSTGRES_HOST', 'postgres')
DB_NAME = os.getenv('POSTGRES_DB', 'openfaas')
DB_USER = os.getenv('POSTGRES_USER', 'user')
DB_PASS = os.getenv('POSTGRES_PASSWORD', 'password')
DB_PORT = os.getenv('POSTGRES_PORT', '5432')
PASSWORD_LENGTH = int(os.getenv('PASSWORD_LENGTH', '16'))


def generate_strong_password(length: int = PASSWORD_LENGTH) -> str:
    alphabet = string.ascii_letters + string.digits + string.punctuation
    for ch in ['"', "'", '`', '\\', '/', ' ']:
        alphabet = alphabet.replace(ch, '')
    return ''.join(secrets.choice(alphabet) for _ in range(length))


def store_password_to_db(user_id: str, password: str) -> None:
    with psycopg2.connect(
        host=DB_HOST, dbname=DB_NAME,
        user=DB_USER, password=DB_PASS, port=DB_PORT
    ) as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO passwords (user_id, password, created_at) VALUES (%s, %s, NOW())",
                (user_id, password)
            )
            conn.commit()


def generate_qr_code(data: str) -> str:
    img = qrcode.make(data)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode('utf-8')


def handle(event, context):
    print("DEBUG: Fonction handle appelée", file=sys.stderr)
    req = request.get_json()
    user_id = req.get('user_id')
    if not user_id:
        return {"error": "user_id manquant"}

    pwd = generate_strong_password()
    try:
        store_password_to_db(user_id, pwd)
    except Exception as e:
        return {"error": f"Échec stockage: {e}"}

    qr_data = f"otpauth://totp/OpenFaaS:{user_id}?secret={pwd}&issuer=OpenFaaS"
    qr_img = generate_qr_code(qr_data)
        return {
        "statusCode": 200,
        "body": json.dumps({
            "password": pwd,
            "qr_code": qr_img
        })
    }
