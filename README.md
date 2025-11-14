# MonAssurance VPN Setup (WireGuard + wg-easy)

## 🔒 Objectif du projet

Ce projet permet de déployer automatiquement un service **VPN WireGuard** basé sur **wg-easy**, pour que des utilisateurs itinérants puissent accéder de manière sécurisée au réseau local hébergé derrière un routeur **MikroTik L009**.

L’installation fonctionne sur un **VPS Ubuntu** avec **Dokploy**, un orchestrateur Docker qui gère le déploiement, la surveillance et la mise à jour des services.

---

## 🛠️ Environnement et Architecture

### 💻 VPS (Cloud)

* Fournit l’accès public via son IP ou domaine
* Héberge le conteneur **wg-easy** (interface web d’administration du VPN)
* Ports exposés :

  * `51820/UDP` → trafic VPN
  * `51821/TCP` → interface web wg-easy
* Intégration **Dokploy** :

  * Chaque projet est isolé via **Project Environment**
  * Permet un déploiement propre et sécurisé
  * Variables d’environnement sensibles définies via Dokploy

### 🛡️ MikroTik L009 (Réseau local)

* Situé derrière un NAT sans IP publique
* Établit une connexion **WireGuard client** vers le VPS
* Permet aux utilisateurs VPN d’accéder aux sous-réseaux internes (ex. 192.168.10.0/24)

### 🛈 Accès utilisateur

* Clients VPN générés automatiquement par wg-easy
* Connexion sécurisée au LAN derrière MikroTik
* Pas de limitation de nombre d’utilisateurs (illimité)

---

## 🗂️ Structure du projet

```
mon-vpn-setup/
├─ docker-compose.yml       # Conteneur WireGuard + wg-easy
├─ .env.template            # Variables sensibles à copier
├─ setup.sh                 # Script d’installation automatique
└─ README.md                # Documentation complète
```

---

## 🔑 Variables d’environnement (.env)

À définir via **Dokploy Project Environment** ou dans `.env` local :

```bash
WG_HOST=vps.monassurance.net       # Domaine/IP publique du VPS
WG_PORT=51820                      # Port UDP pour WireGuard
PASSWORD=SuperMotDePasse123!       # Mot de passe interface wg-easy
WG_ADMIN_PASSWORD=SuperMotDePasse123!
WG_DEFAULT_ADDRESS=10.8.0.1/24     # Sous-réseau VPN pour les clients
WG_ALLOWED_IPS=0.0.0.0/0           # Routes autorisées pour les clients
WG_DEFAULT_DNS=1.1.1.1             # DNS pour clients VPN
TZ=Europe/Paris                     # Fuseau horaire
WG_VOLUME_PATH=/home/ubuntu/wg-config # Répertoire persistant pour configs WireGuard
```

> ⚠️ **Sécurité :** utiliser des mots de passe forts et ne jamais versionner `.env` dans Git.

---

## 🔧 Installation automatique

### 1. Cloner le dépôt

```bash
git clone https://github.com/votre-compte/mon-vpn-setup.git
cd mon-vpn-setup
```

### 2. Configurer les variables

```bash
cp .env.template .env
nano .env
```

Ou via **Dokploy Project Environment**, pour plus de sécurité.

### 3. Lancer l’installation

```bash
sudo bash setup.sh
```

Le script :

* Vérifie Docker et Docker Compose
* Crée les volumes nécessaires
* Déploie wg-easy via Docker Compose
* Configure les ports et variables automatiquement
* Vérifie le bon démarrage du VPN

---

## 🛠️ Gestion via Dokploy

* Accéder à `http://vps.monassurance.net:3000/`
* Créer un **nouveau projet** nommé `projet-vpn`
* Lier le dépôt GitHub `mon-vpn-setup`
* Définir un **Project Environment** pour isoler le service
* Déployer → Dokploy gère le conteneur et le monitoring

---

## 🌐 Interface wg-easy

* URL : `http://vps.monassurance.net:51821`
* Authentification avec `WG_ADMIN_PASSWORD`
* Ajouter, modifier ou télécharger des profils WireGuard pour les utilisateurs

---

## 🔗 Connexion MikroTik

```bash
/interface/wireguard/add name=wg-client private-key="<clé privée MikroTik>" listen-port=51820
/interface/wireguard/peers/add interface=wg-client public-key="<clé publique VPS>" endpoint-address=vps.monassurance.net endpoint-port=51820 allowed-address=0.0.0.0/0 persistent-keepalive=25
/ip/address/add address=10.8.0.2/24 interface=wg-client
/ip/route/add dst-address=0.0.0.0/0 gateway=10.8.0.1
```

> Cette configuration permet au MikroTik de joindre le VPS et d’acheminer le trafic VPN vers le LAN.

---

## 🚀 Avantages de l’architecture

* VPN illimité côté utilisateurs
* Isolation Dokploy → sécurité et facilité de gestion
* Interface wg-easy simple pour administrer les clients
* Déploiement reproductible sur d’autres VPS
* Réseau sécurisé derrière MikroTik sans IP publique

---

## 🔐 Bonnes pratiques et sécurité

* Ne jamais versionner `.env`
* Utiliser des mots de passe forts
* Mettre le VPS derrière un firewall ou un reverse proxy si l’interface web est exposée
* Surveiller les logs wg-easy et Docker
* Sauvegarder régulièrement le volume contenant les configs WireGuard

---

## 📃 Licence

MIT

---

## 📑 Auteur

**Wil Son** – Déploiement VPN sécurisé pour MonAssurance

---

## 🚀 Déploiement manuel

```bash
cp .env.example .env
# Modifier les valeurs (nom de domaine, mot de passe, etc.)
bash setup.sh
```



## 📌 Notes sur Traefik

Pour activer HTTPS via Traefik, ajouter les labels Docker suivants dans docker-compose.yml :

```bash
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.wg-easy.rule=Host(`${WG_HOST}`)"
  - "traefik.http.routers.wg-easy.entrypoints=websecure"
  - "traefik.http.routers.wg-easy.tls=true"
  - "traefik.http.routers.wg-easy.tls.certresolver=letsencrypt"
  - "traefik.http.services.wg-easy.loadbalancer.server.port=51821"
```

Traefik récupère automatiquement un certificat SSL via Let's Encrypt pour le domaine WG_HOST.

L’interface Web devient accessible en HTTPS, sécurisé et sans exposer directement le port 51821.