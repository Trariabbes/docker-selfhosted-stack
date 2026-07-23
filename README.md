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

Plateforme complète de gestion commerciale, du premier contact jusqu'à la livraison du service, testée de bout en bout avec de vrais utilisateurs.
## Base de données et portail client

Migration complète vers une base de données relationnelle SQLite, avec portail client authentifié.

### Base de données (SQLite)
- 6 tables : `clients`, `devis`, `abonnements`, `factures`, `tickets`, `audit_log`
- Migration complète des anciennes données JSON sans perte
- Gestion de la concurrence (WAL mode, busy_timeout, connexions persistantes)

### Portail client (`portail.traricloud.de`)
- Authentification par email/mot de passe (hashé)
- Définition du mot de passe via lien sécurisé (token unique)
- Tableau de bord : abonnements actifs, devis, factures, tickets support
- Journal d'audit de toutes les connexions

### Facturation récurrente automatique
- Création automatique de l'abonnement à la confirmation de paiement
- Génération de la première facture (statut "payée")
- Script Cron quotidien (`cron_facturation.php`) qui :
  - Détecte les abonnements arrivant à échéance
  - Génère automatiquement la facture suivante (numéro unique)
  - Avance la date de prochain paiement (+1 mois)
  - Envoie un email de facture au client
- Client peut consulter ses factures et abonnements dans son portail

### Stack technique ajoutée
- SQLite (base de données relationnelle)
- Sessions PHP pour l'authentification client
- Cron pour la facturation automatique
### Cycle de vente complet
1. **Formulaire enrichi** (`devis.traricloud.de`) — nom, entreprise, services souhaités, nombre d'utilisateurs, besoin détaillé
2. **Interface admin protégée** — liste des demandes, fixation du prix
3. **Génération PDF automatique** (DomPDF) — devis professionnel avec numéro unique
4. **Envoi automatique par email** (PHPMailer/SMTP) — PDF en pièce jointe
5. **Lien d'acceptation sécurisé** — token unique par devis, non réutilisable après acceptation
6. **Confirmation de paiement** — validation manuelle (virement/espèces), déclenche le provisioning
7. **Provisioning automatique multi-services** — Nextcloud, Gitea (via liaison SSH inter-serveurs), lien d'auto-inscription Vaultwarden
8. **Email final automatique** avec tous les identifiants et URLs de connexion

### Stack technique ajoutée
- PHP + Composer
- DomPDF (génération PDF)
- PHPMailer (envoi SMTP)
- Scripts Bash pour le provisioning (`occ` CLI Nextcloud, `gitea admin` CLI)
- Liaison SSH sécurisée entre les deux VPS (clé dédiée, sudoers restreint)
- Principe du moindre privilège : `www-data` autorisé à exécuter uniquement le script de provisioning en root, rien d'autre

### Architecture inter-serveurs
```
VPS Nextcloud (204.168.213.207)
    │
    │ SSH (clé dédiée, sans mot de passe)
    ▼
VPS Docker (167.233.221.164)
    └── Gitea (création de compte via docker exec)
```

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
## Tableau de bord administrateur centralisé

Page d'accueil de l'admin (`devis.traricloud.de/admin/`) offrant une vue d'ensemble complète de l'activité.

### Contenu
- **Statistiques clés** : nombre de clients, abonnements actifs, revenu mensuel récurrent, factures en attente, devis en cours
- **État des serveurs en temps réel** : RAM et disque des deux VPS (Nextcloud en local, Docker Stack via SSH)
- **Liste complète des clients** avec leurs services, prix, statut d'abonnement et prochaine échéance de paiement

### Navigation
- Page d'accueil admin = tableau de bord (`index.php`)
- Liste détaillée des demandes de devis accessible séparément (`demandes.php`)
## Statut

✅ En production — 12 services actifs, CI/CD fonctionnel, sauvegardes automatisées

## Auteur

Trari Abbes — Administrateur système Linux en formation, Oran, Algérie
