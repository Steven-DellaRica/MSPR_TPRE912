# MSPR_TPRE912

Ce projet illustre un proof of concept (POC) de déploiement serverless avec OpenFaaS, Kubernetes et PostgreSQL.

## Architecture
- **OpenFaaS** : gateway, fonctions Python déployées en tant que conteneurs.
- **PostgreSQL** : stockage des mots de passe et secrets TOTP.
- **Frontend** : page web simple pour tester les fonctions.
- **Prometheus** (optionnel) : monitoring des métriques OpenFaaS.

## Prérequis
- Docker ou Minikube/K3s
- Helm 3
- kubectl
- Python 3.11 (pour tests locaux)

## Structure
Voir l’arborescence du projet au-dessus.

## Déploiement
1. Démarrer le cluster (Minikube/K3s) : `./cluster-setup/setup.sh`
2. Appliquer les manifests : `kubectl apply -f k8s/`
3. Builder et déployer chaque fonction :
   ```bash
   faas-cli build -f functions/generate-password
   faas-cli push -f functions/generate-password
   faas-cli deploy -f functions/generate-password
   ```
4. Ouvrir le frontend : `open frontend/index.html` (ou via Ingress)

## Tests
- CURL ou la page web pour générer mot de passe, activer 2FA et authentifier.

## Scalabilité & Production
- Ajouter HPA, Ingress TLS, autoscaling.
- Ajuster ressources cluster (CPU/RAM/disque).