
# ===========================
# Dockerfile minimal pour wg-easy
# ===========================
# Objectif :
# Ce Dockerfile est utilisé par Dokploy pour construire le conteneur Docker
# du service VPN wg-easy. Il est minimal car nous utilisons directement l'image
# officielle "weejewel/wg-easy:latest", donc aucun code supplémentaire n'est nécessaire.

# ---------------------------
# Ligne 1 : Choisir l'image de base
# ---------------------------
FROM weejewel/wg-easy:latest
# "FROM" indique l'image Docker de base à utiliser.
# Ici, nous prenons l'image officielle wg-easy, qui contient :
# - WireGuard
# - Interface web pour administrer les clients VPN
# - Scripts d'initialisation pour configurer automatiquement les utilisateurs

# ===========================
# Notes
# ===========================
# 1. Ce Dockerfile ne fait qu'utiliser l'image officielle.
#    Si vous voulez personnaliser wg-easy (ex: ajouter des scripts ou configs),
#    vous pouvez ajouter des instructions comme COPY, RUN, ENV etc.
#
# 2. Dokploy a besoin de ce fichier pour savoir quoi "build" même si aucune modification
#    n'est faite à l'image originale.
#
# 3. La configuration du VPN (ports, volumes, variables d'environnement) 
#    sera gérée par le docker-compose.yml et Dokploy Project Environment.









