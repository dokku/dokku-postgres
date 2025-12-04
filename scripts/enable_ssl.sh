#!/bin/sh

set -e

# Determine data directory: prefer PGDATA if set by the image, otherwise
# fall back to common location used by Postgres images.
if [ -n "$PGDATA" ] && [ -d "$PGDATA" ]; then
	data_dir="$PGDATA"
elif [ -d /var/lib/postgresql/data ]; then
	data_dir="/var/lib/postgresql/data"
else
	echo "No postgres data directory found" >&2
	exit 1
fi

cd "$data_dir"

# Certs are mounted to /var/lib/postgresql/certs by the plugin; copy them
# into the data directory if present.
certs_src="/var/lib/postgresql/certs"
if [ -d "$certs_src" ] && [ "$(ls -A "$certs_src" 2>/dev/null || true)" ]; then
	cp "$certs_src"/* .
	chown postgres:postgres server.key
	chmod 600 server.key
fi

# Enable SSL in postgresql.conf
sed -i "s/^#ssl = off/ssl = on/" postgresql.conf
sed -i "s/^#ssl_ciphers =.*/ssl_ciphers = 'AES256+EECDH:AES256+EDH'/" postgresql.conf
