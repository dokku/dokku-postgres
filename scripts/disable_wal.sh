POSTGRES_CONF="/var/lib/postgresql/data/postgresql.conf"
PG_HBA_CONF="/var/lib/postgresql/data/pg_hba.conf"

sed -i 's/^.*wal_level.*/wal_level = minimal/' $POSTGRES_CONF
sed -i 's/^.*archive_mode.*/archive_mode = off/' $POSTGRES_CONF
sed -i 's/^.*max_wal_senders.*/max_wal_senders = 0/' $POSTGRES_CONF

sed -i "/replication.*postgres/s/^/#/g" $PG_HBA_CONF