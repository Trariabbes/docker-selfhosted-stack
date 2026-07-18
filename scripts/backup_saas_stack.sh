#!/bin/bash

# ============================
# Script de sauvegarde Plateforme SaaS
# ============================

DATE=$(date "+%Y%m%d_%H%M%S")
BACKUP_DIR="/root/backups/saas-stack"
STACK_DIR="/opt/docker-stack"
LOG_FILE="/root/backups/saas-stack-backup.log"

echo "=== Sauvegarde demarree le $DATE ===" >> $LOG_FILE

# 1. Dump propre de PostgreSQL (toutes les bases)
docker exec postgres pg_dumpall -U postgres > "$BACKUP_DIR/postgres_$DATE.sql"
echo "PostgreSQL sauvegarde : postgres_$DATE.sql" >> $LOG_FILE

# 2. Sauvegarder tous les volumes de services
tar -czf "$BACKUP_DIR/volumes_$DATE.tar.gz" -C $STACK_DIR \
    npm uptime-kuma gitea vaultwarden authentik minio \
    prometheus grafana gitea-runner
echo "Volumes sauvegardes : volumes_$DATE.tar.gz" >> $LOG_FILE

# 3. Sauvegarder le docker-compose.yml
cp $STACK_DIR/docker-compose.yml "$BACKUP_DIR/docker-compose_$DATE.yml"
echo "docker-compose.yml sauvegarde" >> $LOG_FILE

# 4. Supprimer les sauvegardes de plus de 7 jours
find $BACKUP_DIR -type f -mtime +7 -delete
echo "Anciennes sauvegardes nettoyees (plus de 7 jours)" >> $LOG_FILE

echo "=== Sauvegarde terminee le $(date '+%Y-%m-%d %H:%M:%S') ===" >> $LOG_FILE
echo "" >> $LOG_FILE
