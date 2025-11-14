# 📘 Traefik Labels README — Configuration HTTPS pour wg-easy

Ce fichier explique comment utiliser les **labels Traefik** pour exposer l’interface web de **wg-easy** (port 51821) en **HTTPS automatique** via Let's Encrypt.

Ces labels sont compatibles avec :

* **Dokploy**
* **docker-compose**
* **Traefik v2+**

---

# 🔐 Objectif

Permettre un accès sécurisé à l’interface web de wg-easy via :

```
https://vpn.monassurance.cm
```

Au lieu de :

```
http://server-ip:51821
```

Cela améliore :

* La sécurité
* L’expérience utilisateur
* L’intégration dans ton infrastructure SaaS

---

# 📄 Contenu du fichier traefik.labels.yml

```yaml
labels:
  - "traefik.enable=true"                                          # Active Traefik pour ce service
  - "traefik.http.routers.wg-easy.rule=Host(`${WG_HOST}`)"         # Nom de domaine géré par ce routeur
  - "traefik.http.routers.wg-easy.entrypoints=websecure"           # Utilise HTTPS (Entrypoint Traefik)
  - "traefik.http.routers.wg-easy.tls=true"                        # Active TLS
  - "traefik.http.routers.wg-easy.tls.certresolver=letsencrypt"    # Génère automatiquement le certificat SSL
  - "traefik.http.services.wg-easy.loadbalancer.server.port=51821" # Port interne exposé à Traefik (UI wg-easy)
```

---

# 🛠️ Méthode 1 — Utilisation dans Dokploy (recommandée)

1. Ouvre Dokploy → *Projects*
2. Va dans ton service **wg-easy**
3. Ouvre l’onglet **Labels**
4. Copie-colle toutes les lignes du fichier
5. Enregistre
6. Redeploie le service

🎉 Ton interface est maintenant disponible en HTTPS.

---

# 🛠️ Méthode 2 — Utilisation dans docker-compose.yml

Tu peux intégrer directement les labels dans ton service :

```yaml
services:
  wg-easy:
    image: weejewel/wg-easy:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wg-easy.rule=Host(`${WG_HOST}`)"
      - "traefik.http.routers.wg-easy.entrypoints=websecure"
      - "traefik.http.routers.wg-easy.tls=true"
      - "traefik.http.routers.wg-easy.tls.certresolver=letsencrypt"
      - "traefik.http.services.wg-easy.loadbalancer.server.port=51821"
```

⚠️ Important :

* `WG_HOST` doit être défini dans ton `.env`
* Le domaine doit pointer vers l’IP du VPS

---

# 🌐 Fonctionnement détaillé

✔️ *Traefik détecte le conteneur via `traefik.enable=true`*

✔️ *HTTPS forcé via `websecure`*

✔️ *Let's Encrypt génère automatiquement le certificat SSL*

✔️ *Traefik route vers le port interne 51821*

---

# 🧪 Test

🔗 Accède à :

```
https://vpn.monassurance.cm
```

Si ça ne marche pas, vérifie :

* DNS
* wg-easy en marche
* Labels bien appliqués
* Traefik en cours d'exécution

---

# 📦 Notes importantes

* Aucun besoin d’ouvrir le port 51821
* Seul **51820/UDP** doit rester ouvert
* L’interface web passe uniquement par Traefik
* Labels versionnables sans risque

---

# 📌 Conclusion

Ce fichier fournit une configuration prête à l’emploi et sécurisée pour bénéficier automatiquement d’un accès :

* **HTTPS**
* **Certificats SSL Let's Encrypt**
* **Redirection propre**
* **Sécurité accrue**

Compatible Dokploy, Docker et Traefik.
