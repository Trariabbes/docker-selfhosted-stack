#!/bin/bash

# ============================
# Script de sauvegarde Docker Stack
# ============================

DATE=$(date "+%Y%m%d_%H%M%S")
BACKUP_DIR="/root/backups/docker-stack"
STACK_DIR="/opt/docker-stack"
LOG_FILE="/root/backups/docker-stack-backup.log"

echo "=== Sauvegarde demarree le $DATE ===" >> $LOG_FILE

# 1. Sauvegarder tous les volumes (npm, uptime-kuma, gitea, vaultwarden)
tar -czf "$BACKUP_DIR/volumes_$DATE.tar.gz" -C $STACK_DIR npm uptime-kuma gitea vaultwarden
echo "Volumes sauvegardes : volumes_$DATE.tar.gz" >> $LOG_FILE

# 2. Sauvegarder le docker-compose.yml
cp $STACK_DIR/docker-compose.yml "$BACKUP_DIR/docker-compose_$DATE.yml"
echo "docker-compose.yml sauvegarde" >> $LOG_FILE

# 3. Supprimer les sauvegardes de plus de 7 jours
find $BACKUP_DIR -type f -mtime +7 -delete
echo "Anciennes sauvegardes nettoyees (plus de 7 jours)" >> $LOG_FILE

echo "=== Sauvegarde terminee le $(date '+%Y-%m-%d %H:%M:%S') ===" >> $LOG_FILE
echo "" >> $LOG_FILE
