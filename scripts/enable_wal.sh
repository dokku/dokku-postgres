POSTGRES_CONF="/var/lib/postgresql/data/postgresql.conf"
PG_HBA_CONF="/var/lib/postgresql/data/pg_hba.conf"

sed -i 's/^.*wal_level.*/wal_level = archive/' $POSTGRES_CONF
sed -i 's/^.*archive_mode.*/archive_mode = on/' $POSTGRES_CONF
sed -i 's/^.*archive_timeout.*/archive_timeout = 60/' $POSTGRES_CONF
sed -i "s/^.*archive_command.*/archive_command = 'cp %p \/var\/lib\/postgresql\/backups \&\& gzip \/var\/lib\/postgresql\/backups\/%f'/" $POSTGRES_CONF
sed -i 's/^.*max_wal_senders.*/max_wal_senders = 2/' $POSTGRES_CONF

sed -i "/replication.*postgres/s/^#//g" $PG_HBA_CONF