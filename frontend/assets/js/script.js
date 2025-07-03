// Simule des appels backend OpenFaaS (POC)
document.getElementById("createForm").addEventListener("submit", function (e) {
  e.preventDefault();
  const username = document.getElementById("newUsername").value;
  document.getElementById("createResult").innerHTML = `
    <p>Utilisateur <strong>${username}</strong> créé.</p>
    <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=MockPasswordFor:${username}" alt="QR Code Password"/>
  `;
});

document.getElementById("authForm").addEventListener("submit", function (e) {
  e.preventDefault();
  const username = document.getElementById("authUsername").value;
  const password = document.getElementById("authPassword").value;
  const code2FA = document.getElementById("auth2FA").value;

  if (username === "expired.user") {
    document.getElementById("authResult").innerHTML = `<p>Mot de passe expiré, veuillez réinitialiser.</p>`;
  } else {
    document.getElementById("authResult").innerHTML = `<p>Authentification réussie.</p>`;
  }
});

document.getElementById("resetForm").addEventListener("submit", function (e) {
  e.preventDefault();
  const username = document.getElementById("resetUsername").value;
  document.getElementById("resetResult").innerHTML = `
    <p>Nouveau mot de passe + 2FA pour <strong>${username}</strong></p>
    <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=NewPassword:${username}" alt="QR Code"/>
  `;
});
