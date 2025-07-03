from flask import request
import os
import psycopg2
import pyotp

# Environnement : variables DB
DB_HOST = os.getenv('POSTGRES_HOST', 'postgres')
DB_NAME = os.getenv('POSTGRES_DB', 'openfaas')
DB_USER = os.getenv('POSTGRES_USER', 'user')
DB_PASS = os.getenv('POSTGRES_PASSWORD', 'password')
DB_PORT = os.getenv('POSTGRES_PORT', '5432')


def fetch_secret_from_db(user_id: str) -> str | None:
    with psycopg2.connect(
        host=DB_HOST, dbname=DB_NAME,
        user=DB_USER, password=DB_PASS, port=DB_PORT
    ) as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT secret, created_at FROM totp_secrets WHERE user_id = %s ORDER BY created_at DESC LIMIT 1",
                (user_id,)
            )
            row = cur.fetchone()
            return row[0] if row else None


def handle(event, context):
    req = request.get_json()
    user_id = req.get('user_id')
    token = req.get('token')

    if not user_id or not token:
        return {"error": "user_id et token requis"}

    secret = fetch_secret_from_db(user_id)
    if not secret:
        return {"error": "Aucun secret trouvé"}

    totp = pyotp.TOTP(secret)
    valid = totp.verify(token, valid_window=1)

    return {"authenticated": valid}
