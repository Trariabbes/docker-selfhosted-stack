# Plateforme SaaS Auto-hébergée

Plateforme complète de type SaaS, déployée avec Docker Compose sur un VPS dédié, incluant identité (SSO), stockage objet, monitoring et CI/CD.

## Services en ligne

| Service | URL | Rôle |
|---------|-----|------|
| Nginx Proxy Manager | Site vitrine | home.traricloud.de | Présentation des services TrariCloud | admin.traricloud.de | Reverse proxy (accès privé) |
| Uptime Kuma | status.traricloud.de | Supervision et monitoring |
| Gitea | git.traricloud.de | Hébergement Git privé + CI/CD |
| Vaultwarden | vault.traricloud.de | Gestionnaire de mots de passe |
| Authentik | auth.traricloud.de | SSO (Single Sign-On) |
| MinIO | s3.traricloud.de | Stockage objet (compatible S3) |
| MinIO Console | s3-console.traricloud.de | Administration du stockage |
| Grafana | grafana.traricloud.de | Dashboards et visualisation |
| Prometheus | metrics.traricloud.de | Collecte de métriques |
## Système de devis et provisioning automatique

Plateforme complète de gestion commerciale, du premier contact à la livraison du service :

- **Formulaire enrichi** (`devis.traricloud.de`) — nom, entreprise, services souhaités, nombre d'utilisateurs, besoin détaillé
- **Interface admin protégée** — liste des demandes, fixation du prix
- **Génération PDF automatique** (DomPDF) — devis professionnel avec numéro unique
- **Envoi automatique par email** (PHPMailer/SMTP) — PDF en pièce jointe
- **Lien d'acceptation sécurisé** — token unique par devis, non réutilisable après acceptation
- **Provisioning automatique** — création du compte Nextcloud dès l'acceptation, envoi des identifiants, sans intervention manuelle

### Stack technique ajoutée
- PHP + Composer
- DomPDF (génération PDF)
- PHPMailer (envoi SMTP)
- Scripts Bash pour le provisioning (`occ` CLI Nextcloud)
- sudoers restreint (principe du moindre privilège)
## Architecture
Internet
│
▼
Nginx Proxy Manager (HTTPS / Let's Encrypt)
│
├── Uptime Kuma
├── Gitea + Runner CI/CD ──┐
├── Vaultwarden             │
├── Authentik ──────────────┼── PostgreSQL
├── MinIO                   │── Redis
├── Grafana ◄── Prometheus ◄┴── cAdvisor + node-exporter
## Stack technique

- **OS** : Ubuntu 26.04 LTS (VPS Hetzner dédié, 4GB RAM + 4GB swap)
- **Conteneurisation** : Docker + Docker Compose (12 conteneurs)
- **Reverse proxy** : Nginx Proxy Manager
- **SSL** : Let's Encrypt (renouvellement automatique sur tous les services)
- **Base de données** : PostgreSQL 16
- **Cache/File d'attente** : Redis 7
- **SSO** : Authentik
- **Stockage objet** : MinIO (compatible API S3)
- **Monitoring** : Prometheus + Grafana + cAdvisor + node-exporter + Uptime Kuma
- **CI/CD** : Gitea Actions + Runner auto-hébergé
- **Git** : Gitea (SQLite)
- **Coffre-fort** : Vaultwarden (implémentation Bitwarden)

## Fonctionnalités mises en place

### Infrastructure
- VPS dédié séparé de l'environnement de production Nextcloud (isolation des risques)
- Swap de 4GB configuré en sécurité pour la charge mémoire
- 12 services conteneurisés gérés via un seul `docker-compose.yml`
- Réseau Docker géré automatiquement (résolution de noms entre conteneurs)

### Reverse Proxy & HTTPS
- Nginx Proxy Manager pour la gestion centralisée de 9 sous-domaines
- Certificats SSL/TLS automatiques via Let's Encrypt sur tous les services
- Interface d'administration accessible uniquement via HTTPS (port fermé au public)

### Identité & Sécurité
- Authentik déployé comme fournisseur SSO (PostgreSQL + Redis + worker asynchrone)
- Vaultwarden avec inscriptions désactivées après création du compte principal
- Pare-feu UFW configuré (SSH, HTTP, HTTPS uniquement)
- Aucun port de base de données exposé publiquement (PostgreSQL, Redis internes uniquement)

### Stockage & Données
- MinIO comme stockage objet compatible S3
- PostgreSQL comme base de données partagée
- Redis comme cache et broker de messages

### Monitoring
- Uptime Kuma pour la surveillance de la disponibilité de tous les services
- Prometheus pour la collecte de métriques (serveur + conteneurs)
- cAdvisor pour les métriques détaillées par conteneur (CPU, RAM, réseau)
- node-exporter pour les métriques système
- Grafana pour la visualisation avec dashboard temps réel
- Alertes email automatiques en cas de panne

### CI/CD
- Gitea Actions activé avec Runner auto-hébergé
- Pipeline automatique déclenché à chaque `git push`
- Tests exécutés sur les propres serveurs de l'infrastructure

### Sauvegardes
- Script de sauvegarde complet : dump PostgreSQL propre (`pg_dumpall`) + archive de tous les volumes
- Planification via Cron (exécution quotidienne)
- Rétention automatique de 7 jours
- Réplication des sauvegardes vers un poste distant via rsync

## Scripts

Voir le dossier `/scripts` pour les scripts de sauvegarde utilisés.

## Statut

✅ En production — 12 services actifs, CI/CD fonctionnel, sauvegardes automatisées

## Auteur

Trari Abbes — Administrateur système Linux en formation, Oran, Algérie
