#!/bin/bash

set -e

echo "▶️ 1. Démarrage du cluster Minikube..."
minikube start --cpus=2 --memory=4096mb --disk-size=20g

echo "▶️ 2. Activation des addons (ingress)..."
minikube addons enable ingress

echo "▶️ 3. Création du namespace openfaas..."
kubectl create namespace openfaas || true
kubectl create namespace openfaas-fn || true

echo "▶️ 4. Installation de Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f get_helm.sh

if ! command -v helm &> /dev/null; then
  echo "❌ Échec de l'installation de Helm. Vérifiez votre connexion et réessayez."
  exit 1
fi

echo "▶️ 5. Ajout du repo Helm OpenFaaS..."
helm repo add openfaas https://openfaas.github.io/faas-netes/ || true
helm repo update

echo "▶️ 6. Installation de l'addon metrics-server et d’OpenFaaS avec Helm..."
minikube addons enable metrics-server
helm upgrade openfaas openfaas/openfaas \
  --install \
  --namespace openfaas \
  --set basic_auth=false \
  --values ../k8s/openfaas-helm-values.yaml 

echo "⌛ Attente du déploiement de metrics-server..."
kubectl rollout status deployment/metrics-server -n kube-system

echo "⌛ Attente du déploiement de la gateway OpenFaaS..."
kubectl rollout status -n openfaas deploy/gateway

echo "▶️ 7. Déploiement de PostgreSQL..."
kubectl apply -f ../k8s/secrets.yaml
kubectl apply -f ../k8s/postgres-statefulset.yaml

echo "⌛ Attente de PostgreSQL..."
kubectl rollout status -n openfaas statefulset/postgres

echo "▶️ Initialisation de la base PostgreSQL via Job Kubernetes..."
kubectl apply -f ../k8s/init-db-job.yaml

echo "⏳ Attente de la fin de l'initialisation de la base..."
kubectl wait --for=condition=complete --timeout=90s job/init-db -n openfaas

echo "✅ PostgreSQL prêt et base initialisée."

echo "▶️ 8. Exposition de la gateway OpenFaaS..."

GATEWAY_POD=""
for i in {1..30}; do
  GATEWAY_POD=$(kubectl get pods -n openfaas -l app=gateway -o jsonpath='{.items[0].metadata.name}')
  READY=$(kubectl get pod -n openfaas "$GATEWAY_POD" -o jsonpath="{.status.containerStatuses[0].ready}")
  if [ "$READY" == "true" ]; then
    echo "✅ Le pod $GATEWAY_POD est prêt."
    break
  fi
  echo "⏳ Le pod $GATEWAY_POD n'est pas encore prêt... ($i/15)"
  sleep 2
done

if [ "$READY" != "true" ]; then
  echo "❌ Le pod gateway n'est pas prêt après attente, abandon."
  exit 1
fi

echo "🚪 Port-forward en cours..."
kubectl port-forward -n openfaas pod/$GATEWAY_POD 8080:8080 > /tmp/gateway-port-forward.log 2>&1 &
PORT_FORWARD_PID=$!

for i in {1..15}; do
  if curl -s http://127.0.0.1:8080 > /dev/null; then
    echo "✅ Gateway OpenFaaS est accessible depuis localhost."
    break
  fi
  if ! ps -p $PORT_FORWARD_PID > /dev/null; then
    echo "❌ Le processus de port-forward s'est terminé prématurément. Log :"
    cat /tmp/gateway-port-forward.log
    exit 1
  fi
  echo "⏳ Attente de l’accessibilité de la gateway depuis localhost... ($i/15)"
  sleep 2
done

if ! curl -s http://127.0.0.1:8080 > /dev/null; then
  echo "❌ Échec : gateway non accessible après attente. Logs :"
  cat /tmp/gateway-port-forward.log
  kill $PORT_FORWARD_PID 2>/dev/null
  exit 1
fi

echo "▶️ 9. Installation de faas-cli..."
curl -sSL https://cli.openfaas.com | sudo sh
if ! command -v faas-cli &> /dev/null; then
  echo "❌ faas-cli non installé, vérifiez votre connexion Internet."
  exit 1
fi

echo "▶️ 10. Construction et déploiement des fonctions..."
if [ ! -d "template/python3-http" ]; then
  faas-cli template store pull python3-http
fi

echo "⏳ Vérification de la présence du template..."
TEMPLATE_DIR="./template/python3-http"
for i in {1..10}; do
  if [ -d "$TEMPLATE_DIR" ]; then
    echo "✅ Template python3 prêt."
    break
  fi
  sleep 1
done

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "❌ Le template python3 n'a pas été téléchargé correctement."
  exit 1
fi

echo "📂 Contenu du dossier template :"
ls -l template/

echo "🚀 Build des fonctions"
faas-cli build -f functions.yml

echo "📤 Déploiement..."
faas-cli deploy -f functions.yml

# (Optionnel) Nettoyage du Job pour garder le cluster propre
kubectl delete job init-db -n openfaas --ignore-not-found

echo "✅ Initialisation terminée. Utilisateur 'testuser' prêt pour les tests."

echo "➡️ Accède à la gateway OpenFaaS : http://127.0.0.1:8080"
echo "➡️ Lancer le frontend depuis 'frontend/' en faisant :"
echo "cd frontend"
echo "npm install"
echo "npm run dev"
echo "➡️ Puis accéder à : http://127.0.0.1:3000"
