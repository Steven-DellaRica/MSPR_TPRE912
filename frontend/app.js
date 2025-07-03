const gatewayUrl = 'http://127.0.0.1:8080';

async function generatePassword() {
  const userId = document.getElementById('user-id-pwd').value;
  const res = await fetch(`${gatewayUrl}/function/generate-password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user_id: userId })
  });
  const data = await res.json();
  document.getElementById('pwd-output').textContent = data.password || data.error;
  if (data.qr_code) {
    document.getElementById('pwd-qr').src = `data:image/png;base64,${data.qr_code}`;
  }
}

async function generate2FA() {
  const userId = document.getElementById('user-id-2fa').value;
  const res = await fetch(`${gatewayUrl}/function/generate-2fa`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user_id: userId })
  });
  const data = await res.json();
  document.getElementById('2fa-output').textContent = data.secret || data.error;
  if (data.qr_code) {
    document.getElementById('2fa-qr').src = `data:image/png;base64,${data.qr_code}`;
  }
}

async function authenticate() {
  const userId = document.getElementById('user-id-auth').value;
  const token = document.getElementById('token-auth').value;
  const res = await fetch(`${gatewayUrl}/function/authenticate`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user_id: userId, token: token })
  });
  const data = await res.json();
  document.getElementById('auth-output').textContent =
    data.authenticated ? '✅ Authentifié' : '❌ Échec';
}