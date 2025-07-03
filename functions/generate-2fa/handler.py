from flask import request
import os
import psycopg2
import pyotp
import qrcode
import io
import base64

# Environnement : variables DB
DB_HOST = os.getenv('POSTGRES_HOST', 'postgres')
DB_NAME = os.getenv('POSTGRES_DB', 'openfaas')
DB_USER = os.getenv('POSTGRES_USER', 'user')
DB_PASS = os.getenv('POSTGRES_PASSWORD', 'password')
DB_PORT = os.getenv('POSTGRES_PORT', '5432')


def store_secret_to_db(user_id: str, secret: str) -> None:
    with psycopg2.connect(
        host=DB_HOST, dbname=DB_NAME,
        user=DB_USER, password=DB_PASS, port=DB_PORT
    ) as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO totp_secrets (user_id, secret, created_at) VALUES (%s, %s, NOW())",
                (user_id, secret)
            )
            conn.commit()


def generate_qr_code(data: str) -> str:
    img = qrcode.make(data)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode('utf-8')


def handle(event, context):
    req = request.get_json()
    user_id = req.get('user_id')
    if not user_id:
        return {"error": "user_id manquant"}

    # Génération secret TOTP
    secret = pyotp.random_base32()
    try:
        store_secret_to_db(user_id, secret)
    except Exception as e:
        return {"error": f"Échec stockage secret: {e}"}

    # Génération URI et QR code
    otp_uri = pyotp.totp.TOTP(secret).provisioning_uri(name=user_id, issuer_name="OpenFaaS")
    qr_img = generate_qr_code(otp_uri)
    return {"secret": secret, "qr_code": qr_img}
