# MonAssurance VPN Setup (WireGuard + wg-easy)

## 🔒 Objectif du projet

Ce projet a pour but de déployer automatiquement un service **VPN WireGuard** basé sur **wg-easy**, afin de permettre à des utilisateurs itinérants d'accéder de manière sécurisée au réseau local hébergé derrière un routeur **MikroTik L009**.

L’installation est conçue pour fonctionner sur un **VPS Ubuntu** disposant de **Dokploy**, un orchestrateur Docker qui facilitera la gestion, la surveillance et la mise à jour des services.

---

## 🛠️ Environnement et Architecture

### 💻 VPS (Cloud)

* Fournit l’accès public (IP publique)
* Héberge le conteneur **wg-easy** (interface web de gestion du VPN)
* Expose le port **51820/UDP** pour le trafic VPN
* Expose le port **51821/TCP** pour l’interface d’administration wg-easy
* S’intègre dans **Dokploy** via un *Project Environment* dédié (isolé du reste du système)

### 🛡️ MikroTik L009 (Réseau local)

* Situé derrière un réseau privé sans IP publique
* Établit une connexion **WireGuard client** vers le VPS
* Permet aux utilisateurs connectés au VPN d’accéder à ses sous-réseaux internes (par exemple : 192.168.10.0/24)

### 🛈 Accès utilisateur

* Les utilisateurs itinérants se connectent via un client WireGuard configuré automatiquement par wg-easy
* Ils accèdent au LAN derrière le MikroTik comme s’ils étaient sur place

---

## 🗂️ Structure du projet

```
mon-vpn-setup/
├─ docker-compose.yml       # Conteneur WireGuard + wg-easy
├─ .env                     # Variables d’environnement (à copier depuis .env.template)
├─ setup.sh                 # Script d’installation automatique
└─ README.md                # Documentation du projet
```

---

## 🔑 Variables d’environnement (.env)

```bash
WG_HOST=server.com       # Nom de domaine ou IP publique du VPS
WG_PORT=51820                      # Port WireGuard
PASSWORD=ChangeMe123!              # Mot de passe interface wg-easy
WG_DEFAULT_ADDRESS=10.8.0.x        # Sous-réseau VPN
WG_ALLOWED_IPS=0.0.0.0/0           # Routes accessibles via VPN
```

> **Important :** N’oubliez pas de remplacer `server.com ` par votre propre domaine et d’utiliser un mot de passe fort.

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

### 3. Lancer l’installation

```bash
sudo bash setup.sh
```

Ce script :

1. Crée un projet Dokploy isolé pour le VPN
2. Déploie wg-easy en tant que service Docker
3. Configure automatiquement les ports et variables

---

## 🛠️ Gestion via Dokploy

Dans l’interface web Dokploy :

* Accédez à `http://server.com:3000/`
* Connectez-vous à votre compte admin
* Ajoutez un **nouveau projet** nommé `projet-vpn`
* Liez le dépôt GitHub `mon-vpn-setup`
* Sélectionnez **Project Environment** pour isoler ce service
* Déployez ! ✅

---

## 🌐 Accès à l’interface wg-easy

Une fois le déploiement terminé :

* Accédez à `http://server.com:51821`
* Connectez-vous avec le mot de passe défini dans `.env`
* Ajoutez ou téléchargez les profils WireGuard pour vos utilisateurs

---

## 🔗 Connexion MikroTik

Côté MikroTik (en client VPN) :

```bash
/interface/wireguard/add name=wg-client private-key="<clé privée MikroTik>" listen-port=51820
/interface/wireguard/peers/add interface=wg-client public-key="<clé publique VPS>" endpoint-address=vps.monassurance.net endpoint-port=51820 allowed-address=0.0.0.0/0 persistent-keepalive=25
/ip/address/add address=10.8.0.2/24 interface=wg-client
/ip/route/add dst-address=0.0.0.0/0 gateway=10.8.0.1
```

---

## 🚀 Avantages de cette architecture

* **VPN illimité** (pas de restriction d’utilisateurs)
* **Isolation Dokploy** → Sécurité et facilité de gestion
* **Interface simple wg-easy** pour administrer les clients
* **Connexion fiable** entre le Mikrotik (réseau local) et le VPS
* **Facilement reproductible** sur d’autres serveurs

---

## 📃 Licence

Ce projet est sous licence MIT.

---

## 📑 Auteur

Projet conçu par **Wil Son** pour le déploiement du service **VPN sécurisé MonAssurance**.


## 🚀 Déploiement manuel

```bash
cp .env.example .env
# Modifier les valeurs (nom de domaine, mot de passe, etc.)
bash setup.sh
