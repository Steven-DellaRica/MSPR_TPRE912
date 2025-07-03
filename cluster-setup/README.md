## cluster-setup/README.md
# Cluster Setup
Ce dossier contient le script d’initialisation du cluster et les prérequis.

## Prérequis
- Minikube (>= v1.30) ou K3s
- Au moins 4 CPU et 8 Go de RAM (recommandé)
- 50 Go de disque disponible

## Utilisation
1. Donner les droits d’exécution : `chmod +x setup.sh`
2. Lancer : `./setup.sh`

Le script :
- Démarre Minikube avec ingress
- Installe Helm
- Ajoute le repo OpenFaaS et déploie le chart
- Crée les namespaces `openfaas` et `openfaas-fn`
- Forward le gateway sur le port local 8080

Une fois terminé, OpenFaaS est disponible sur : `http://127.0.0.1:8080`