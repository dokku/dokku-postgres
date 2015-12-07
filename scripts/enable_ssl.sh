#!/bin/bash
cd /var/lib/postgresql/data
openssl req -new -newkey rsa:4096 -x509 -nodes -out server.crt -keyout server.key -batch
chmod 600 server.key
sed -i "s/^#ssl = off/ssl = on/" postgresql.conf
sed -i "s/^#ssl_ciphers =.*/ssl_ciphers = 'AES256+EECDH:AES256+EDH'/" postgresql.conf
