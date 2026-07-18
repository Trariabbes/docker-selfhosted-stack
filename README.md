# Docker Self-Hosted Stack

Plateforme self-hosted déployée avec Docker et Docker Compose, hébergeant plusieurs services derrière un reverse proxy avec HTTPS automatique.

## Services en ligne

| Service | URL | Rôle |
|---------|-----|------|
| Nginx Proxy Manager | https://admin.traricloud.de | Administration reverse proxy (accès privé) |
| Uptime Kuma | https://status.traricloud.de | Supervision et monitoring |
| Gitea | https://git.traricloud.de | Hébergement Git privé |
| Vaultwarden | https://vault.traricloud.de | Gestionnaire de mots de passe |

## Architecture
Internet

│

▼

Gestionnaire de proxy Nginx (HTTPS / Let's Encrypt)

│

├── Uptime Kuma (supervision)

├── Gitea (Git privé)

└── Vaultwarden (mots de pass)
## Stack technique

- **OS** : Ubuntu 26.04 LTS (VPS Hetzner dédié)
- **Conteneurisation** : Docker + Docker Compose
- **Reverse proxy** : Nginx Proxy Manager
- **SSL** : Let's Encrypt (renouvellement automatique)
- **Monitoring** : Uptime Kuma
- **Git** : Gitea (SQLite)
- **Coffre-fort** : Vaultwarden (implémentation Bitwarden)

## Fonctionnalités mises en place

### Infrastructure
- VPS dédié séparé de l'environnement de production (isolation des risques)
- Docker et Docker Compose installés et configurés
- Réseau Docker géré automatiquement (résolution de noms entre conteneurs)
- 4 services conteneurisés gérés via un seul `docker-compose.yml`

### Reverse Proxy & HTTPS
- Nginx Proxy Manager pour la gestion centralisée des sous-domaines
- Certificats SSL/TLS automatiques via Let's Encrypt sur tous les services
- Support HTTP/2 et Force SSL

### Sécurité
- Interface d'administration accessible uniquement via HTTPS (port d'admin fermé au public, lié en local uniquement)
- Inscriptions désactivées sur Vaultwarden après création du compte principal
- Pare-feu UFW configuré (SSH, HTTP, HTTPS uniquement)

### Monitoring
- Surveillance de la disponibilité de 4 services + 2ᵉ VPS de production
- Vérification automatique toutes les 60 secondes
- Alertes email automatiques (SMTP) en cas de panne
- Suivi de l'expiration des certificats SSL

### Sauvegardes
- Script Bash de sauvegarde automatisée de tous les volumes Docker
- Planification via Cron (exécution quotidienne)
- Rétention automatique de 7 jours
- Réplication des sauvegardes vers un poste distant via rsync

## Scripts

Voir le dossier `/scripts` pour les scripts de sauvegarde utilisés.

## Statut

✅ En production

## Auteur

Trari Abbes — Administrateur système Linux en formation, Oran, Algérie
