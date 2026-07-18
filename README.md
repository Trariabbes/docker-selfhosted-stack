# Docker Self-Hosted Stack

Plateforme self-hosted déployée avec Docker et Docker Compose, hébergeant plusieurs services derrière un reverse proxy avec HTTPS automatique.

## Architecture
## Services

| Service | Rôle |
|---------|------|
| Nginx Proxy Manager | Reverse proxy + HTTPS automatique (Let's Encrypt) |
| Nextcloud | Stockage et partage de fichiers |
| Gitea | Hébergement Git privé (alternative GitHub) |
| Uptime Kuma | Supervision de la disponibilité des services |
| Vaultwarden | Gestionnaire de mots de passe (alternative Bitwarden) |
| MariaDB | Base de données partagée |

## Objectifs techniques

- [ ] Installation de Docker et Docker Compose
- [ ] Configuration des réseaux Docker (isolation des services)
- [ ] Gestion des volumes (persistance des données)
- [ ] Reverse proxy avec HTTPS automatique
- [ ] Sauvegardes automatisées des volumes
- [ ] Mise à jour automatisée des conteneurs

## Statut

🚧 Projet en cours de construction

## Auteur

Trari Abbes — Administrateur système Linux en formation, Oran, Algérie
git add README.md
git commit -m "Mise à jour : Nginx Proxy Manager, Uptime Kuma, monitoring et HTTPS déployés"
git push origin main
