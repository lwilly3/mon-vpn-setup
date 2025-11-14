# MonAssurance VPN Setup (WireGuard + wg-easy)

## 🔒 Objectif du projet

Ce projet permet de déployer automatiquement un service **VPN WireGuard** basé sur **wg-easy**, pour que des utilisateurs itinérants puissent accéder de manière sécurisée au réseau local hébergé derrière un routeur **MikroTik L009**.

---

## 🛠️ Environnement et Architecture

### 💻 VPS (Cloud)

* Fournit l'accès public via son IP ou domaine
* Héberge le conteneur **wg-easy** (interface web d'administration du VPN)
* Ports exposés :
  * `51820/UDP` → trafic VPN
  * `51821/TCP` → interface web wg-easy

### 🛡️ MikroTik L009 (Réseau local)

* Situé derrière un NAT sans IP publique
* Établit une connexion **WireGuard client** vers le VPS
* Permet aux utilisateurs VPN d'accéder aux sous-réseaux internes (ex. 192.168.10.0/24)

### 🛈 Accès utilisateur

* Clients VPN générés automatiquement par wg-easy
* Connexion sécurisée au LAN derrière MikroTik
* Pas de limitation de nombre d'utilisateurs (illimité)

---

## 🗂️ Structure du projet

```
mon-vpn-setup/
├─ docker-compose.yml       # Configuration Docker simplifiée
├─ Dockerfile               # Image basée sur wg-easy
├─ .env.template            # Template des variables d'environnement
├─ manual-setup.sh          # Script d'installation manuelle (optionnel)
├─ .gitignore               # Fichiers à ne pas versionner
└─ README.md                # Documentation complète
```

---

## ⚠️ Prérequis système

### Installation de WireGuard sur l'hôte VPS

**Avant tout déploiement**, WireGuard doit être installé sur le VPS Ubuntu :

```bash
sudo apt-get update
sudo apt-get install -y wireguard
sudo modprobe wireguard

# Vérifier l'installation
lsmod | grep wireguard
```

> 💡 Cette étape est **obligatoire** car le conteneur Docker a besoin du module kernel WireGuard de l'hôte.

---

## 🚀 Déploiement recommandé : Docker Compose

**Note:** En raison de limitations de Docker Swarm avec les modules kernel, le déploiement manuel via Docker Compose est recommandé.

### 1. Installer WireGuard sur le VPS

```bash
ssh ubuntu@votre-vps
sudo apt-get update && sudo apt-get install -y wireguard docker.io docker-compose
sudo modprobe wireguard
lsmod | grep wireguard  # Vérifier l'installation
```

### 2. Cloner et configurer le projet

```bash
cd ~
git clone https://github.com/lwilly3/mon-vpn-setup.git
cd mon-vpn-setup

# Copier et configurer les variables
cp .env.template .env
nano .env
```

**Variables à configurer dans `.env` :**

```env
WG_HOST=vpn.monassurance.ovh              # Votre domaine ou IP publique
PASSWORD=UnMotDePasseTresFort123!         # Mot de passe interface web
WG_PORT=51820                             # Port VPN (UDP)
WG_DEFAULT_ADDRESS=10.13.13.x             # Plage IP clients VPN
WG_ALLOWED_IPS=0.0.0.0/0                  # Routes autorisées
WG_DEFAULT_DNS=1.1.1.1                    # DNS pour les clients
TZ=Africa/Douala                          # Fuseau horaire
WG_VOLUME_PATH=./wg-data                  # Dossier configs
```

### 3. Lancer le VPN

```bash
# Créer le dossier de données
mkdir -p wg-data

# Lancer le conteneur
sudo docker compose up -d

# Vérifier que ça fonctionne
sudo docker ps | grep wg-easy
sudo docker logs wg-easy
```

### 4. Accéder à l'interface

- **Interface web** : `http://IP_VPS:51821`
- Connectez-vous avec le mot de passe défini dans `PASSWORD`
- Créez et téléchargez vos profils clients VPN

### 5. Gestion quotidienne

```bash
sudo docker compose down        # Arrêter
sudo docker compose up -d       # Démarrer
sudo docker compose restart     # Redémarrer
sudo docker compose logs -f     # Voir les logs en temps réel
```

---

## 🔧 Configuration du pare-feu

Si vous avez un firewall actif (UFW), autorisez les ports :

```bash
sudo ufw allow 51820/udp  # Port VPN WireGuard
sudo ufw allow 51821/tcp  # Interface web
sudo ufw reload
```

---

## 🔗 Connexion MikroTik

Configuration côté MikroTik (en tant que client VPN) :

```bash
/interface/wireguard/add name=wg-client private-key="<clé privée MikroTik>" listen-port=51820
/interface/wireguard/peers/add interface=wg-client public-key="<clé publique VPS>" endpoint-address=vpn.monassurance.ovh endpoint-port=51820 allowed-address=0.0.0.0/0 persistent-keepalive=25
/ip/address/add address=10.13.13.2/24 interface=wg-client
/ip/route/add dst-address=0.0.0.0/0 gateway=10.13.13.1
```

---

## 🚀 Avantages de cette architecture

* **VPN illimité** (pas de restriction d'utilisateurs)
* **Interface simple wg-easy** pour administrer les clients
* **Connexion fiable** entre le Mikrotik (réseau local) et le VPS
* **Facilement reproductible** sur d'autres serveurs
* **Pas de dépendance à un orchestrateur** (fonctionne avec Docker standard)

---

## 🐛 Dépannage

### Le conteneur ne démarre pas

```bash
# Vérifier les logs
sudo docker logs wg-easy

# Vérifier que WireGuard est chargé
lsmod | grep wireguard

# Recharger le module si nécessaire
sudo modprobe wireguard
```

### Impossible d'accéder à l'interface web

```bash
# Vérifier que le port est ouvert
sudo netstat -tulpn | grep 51821

# Vérifier le firewall
sudo ufw status

# Tester en local sur le VPS
curl http://localhost:51821
```

### Les clients ne peuvent pas se connecter

- Vérifiez que le port 51820/UDP est ouvert sur votre VPS
- Vérifiez que `WG_HOST` correspond à votre IP/domaine public
- Vérifiez les logs : `sudo docker logs wg-easy`

---

## 📃 Licence

Ce projet est sous licence MIT.

---

## 📑 Auteur

Projet conçu par **Wil Son** pour le déploiement du service **VPN sécurisé MonAssurance**.
