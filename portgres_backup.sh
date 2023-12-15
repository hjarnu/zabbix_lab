#!/bin/bash

container=zabbix_db
dump=zabbix.tar
local_dir=/backups/postgres/
archive=/backups/postgres/zabbix_$(date +%d-%h-%Y_%H%M%S).tar.gz

docker exec $container bash -c "pg_dump -Ft -U zabbix zabbix > /${dump}" \
&& docker cp ${container}:/${dump} ${local_dir}/${dump} \
&& gzip ${local_dir}/${dump} \
&& mv ${local_dir}/${dump}.gz $archive
