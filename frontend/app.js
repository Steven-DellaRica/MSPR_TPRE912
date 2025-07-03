console.log('JS chargé !');
const gatewayUrl = 'http://127.0.0.1:8080';

async function generatePassword() {
  const userId = document.getElementById('user-id-pwd').value;
    if (!userId) {
    alert('Merci de saisir un User ID avant de générer le mot de passe.');
    return;
  }
  console.log('Tentative de génération pour :', userId);
  
  const res = await fetch(`${gatewayUrl}/function/generate-password`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user_id: userId })
  });
  console.log('Réponse brute :', res);
  const data = await res.json();
  console.log('Données reçues :', data);
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

// Lier les boutons aux fonctions via des event listeners
document.getElementById('btn-gen-pwd').addEventListener('click', generatePassword);
document.getElementById('btn-gen-2fa').addEventListener('click', generate2FA);
document.getElementById('btn-auth').addEventListener('click', authenticate);
