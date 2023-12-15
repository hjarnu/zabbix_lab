#!/bin/bash

container=zabbix-db
dump=zabbix.tar
local_dir=/backups/postgres/
archive=${local_dir}zabbix_$(date +"%d-%h-%Y_%H%M%S").tar.gz
log_file=/var/log/postgres_backup.log

# Function for logging with timestamp
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") $1" >> $log_file
}

# Database dump
if docker exec $container bash -c "pg_dump -Ft -U zabbix zabbix > /${dump}" >> $log_file 2>&1; then
  log "Database dump completed successfully"
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
