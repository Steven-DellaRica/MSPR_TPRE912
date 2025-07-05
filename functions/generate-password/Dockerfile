# Image Python légère
FROM python:3.11-slim

# Crée le répertoire de travail
WORKDIR /app

# Copie et installe les dépendances
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copie le code de la fonction
COPY index.py ./

# Installation de fwatchdog
ADD https://github.com/openfaas/classic-watchdog/releases/download/0.3.3/fwatchdog-amd64 /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Définit le port utilisé par OpenFaaS
ENV fprocess="python index.py"

# Expose le port HTTP par défaut
EXPOSE 8080

# Commande de démarrage pour OpenFaaS
CMD ["fwatchdog"]