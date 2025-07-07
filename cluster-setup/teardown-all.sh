#!/bin/bash

set -e

echo "🛑 1. Suppression des fonctions OpenFaaS..."
faas-cli remove generate-2fa || true
faas-cli remove generate-password || true
faas-cli remove authenticate || true

echo "🗑️ 2. Suppression du StatefulSet PostgreSQL et des secrets..."
kubectl delete statefulset postgres -n openfaas || true
kubectl delete service postgres -n openfaas || true
kubectl delete secret postgres-secret -n openfaas || true

echo "🧼 3. Suppression de la release Helm OpenFaaS..."
helm uninstall openfaas -n openfaas || true

echo "🧹 4. Suppression des namespaces..."
kubectl delete namespace openfaas || true
kubectl delete namespace openfaas-fn || true

echo "🔌 5. Arrêt de tout port-forward (si lancé en arrière-plan)..."
pkill -f "kubectl port-forward" || true

echo "🛑 6. Arrêt et suppression du cluster Minikube..."
minikube delete

echo "🔌 7. Suppression des dossiers build et template"
rm -rf ./build && rm -rf ./template

echo "✅ Teardown complet terminé."