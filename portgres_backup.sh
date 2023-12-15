#!/bin/bash

container=zabbix-db
dump=zabbix.tar
local_dir=/backups/postgres/
log_file=/var/log/postgres_backup.log

# Function for logging with timestamp
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") $1" >> $log_file
}

# Database dump
if docker exec $container bash -c "pg_dump -Ft -U zabbix zabbix > /${dump}" >> $log_file 2>&1; then
  log "Database dump completed successfully"
  archive="${local_dir}zabbix_$(date +"%d-%h-%Y_%H%M%S").tar.gz"
  docker cp ${container}:/${dump} ${local_dir}/${dump}
  log "Database dump file copied successfully to the local directory"
else
  log "Error: Database dump failed"
  exit 1
fi

# Move and compress the dump
gzip ${local_dir}${dump} && mv ${local_dir}${dump}.gz ${archive}
log "Backup saved to: ${archive}"

# Delete the dump file inside the container
docker exec $container bash -c "rm -f /${dump}" >> $log_file 2>&1
log "Dump file deleted inside the container"

# Retain only the latest three archive files
older_archives=$(ls -t ${local_dir} | grep -E '^zabbix_[0-9]{2}-[a-zA-Z]{3}-[0-9]{4}_[0-9]{6}\.tar\.gz' | tail -n +4)
for older_archive in $older_archives; do
  log "Removing older archive: ${local_dir}${older_archive}"
  rm "${local_dir}${older_archive}"
  log "Older archives removed, keeping only the latest three"
done
