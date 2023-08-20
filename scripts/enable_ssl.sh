#!/bin/sh

set -e

cd /var/lib/postgresql/data

cp ../certs/* .
chown postgres:postgres server.key
chmod 600 server.key

sed -i "s/^#ssl = off/ssl = on/" postgresql.conf
sed -i "s/^#ssl_ciphers =.*/ssl_ciphers = 'AES256+EECDH:AES256+EDH'/" postgresql.conf
