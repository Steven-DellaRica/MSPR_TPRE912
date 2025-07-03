# Image Python légère
FROM python:3.11-slim

# Crée le répertoire de travail
WORKDIR /app

# Copie et installe les dépendances
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copie le code de la fonction
COPY handler.py ./

# Définit le port utilisé par OpenFaaS
ENV fprocess="python handler.py"

# Expose le port HTTP par défaut
EXPOSE 8080

# Commande de démarrage pour OpenFaaS
CMD ["fwatchdog"]