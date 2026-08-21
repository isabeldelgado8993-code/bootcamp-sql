#!/bin/bash
# ============================================================
# backup_globaltech.sh
# Backup automatizable de la base de datos globaltech
# Uso: bash backup_globaltech.sh
# Cron diario a las 2 AM: 0 2 * * * /path/to/backup_globaltech.sh
# ============================================================

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_NAME="globaltech"
DB_USER="root"

# Crear directorio si no existe
mkdir -p $BACKUP_DIR

# Backup completo
mysqldump -u $DB_USER -p $DB_NAME > "$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql"

echo "Backup creado: ${DB_NAME}_${TIMESTAMP}.sql"

# Backup comprimido (opcional)
# mysqldump -u $DB_USER -p $DB_NAME | gzip > "$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"
# echo "Backup comprimido creado: ${DB_NAME}_${TIMESTAMP}.sql.gz"