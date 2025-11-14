#!/bin/bash
set -e

echo "🔧 Installation du service VPN WireGuard (wg-easy)..."

# Vérifie et installe le module WireGuard sur l'hôte
echo "📦 Vérification du module WireGuard..."
if ! lsmod | grep -q wireguard; then
  echo "⚙️  Installation de WireGuard sur l'hôte..."
  apt-get update -qq
  apt-get install -y wireguard
  modprobe wireguard
  echo "✅ Module WireGuard chargé"
else
  echo "✅ Module WireGuard déjà présent"
fi

# Vérifie que Docker est installé
if ! command -v docker &> /dev/null; then
  echo "Docker non installé. Installation..."
  curl -fsSL https://get.docker.com | sh
fi

# Vérifie Docker Compose
if ! command -v docker compose &> /dev/null; then
  echo "Docker Compose non installé. Installation..."
  apt-get update && apt-get install -y docker-compose-plugin
fi

# Charge les variables d'environnement
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "⚠️  Fichier .env non trouvé. Copiez .env.example vers .env et modifiez-le."
  exit 1
fi

# Crée le dossier pour les données persistantes
mkdir -p ${WG_VOLUME_PATH}

# Démarre le conteneur
echo "🚀 Démarrage du conteneur wg-easy..."
docker compose up -d

# Vérifie l’état du service
sleep 5
docker ps | grep wg-easy && echo "✅ VPN WireGuard opérationnel !" || echo "❌ Erreur : wg-easy ne s'est pas lancé."
