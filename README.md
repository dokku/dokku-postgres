# dokku postgres (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-postgres.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-postgres) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official postgres plugin for dokku. Currently defaults to installing [postgres 9.5.4](https://hub.docker.com/_/postgres/).

## requirements

- dokku 0.4.x+
- docker 1.8.x

## installation

```shell
# on 0.4.x+
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
```

## commands

```
postgres:backup <name> <bucket>   Create a backup of the postgres service to an existing s3 bucket
postgres:backup-auth <name> <aws_access_key_id> <aws_secret_access_key> Sets up authentication for backups on the postgres service
postgres:backup-deauth <name>     Removes backup authentication for the postgres service
postgres:backup-schedule <name> <schedule> <bucket> Schedules a backup of the postgres service
postgres:backup-unschedule <name> Unschedules the backup of the postgres service
postgres:clone <name> <new-name>  Create container <new-name> then copy data from <name> into <new-name>
postgres:connect <name>           Connect via psql to a postgres service
postgres:create <name>            Create a postgres service with environment variables
postgres:destroy <name>           Delete the service and stop its container if there are no links left
postgres:enter <name> [command]   Enter or run a command in a running postgres service container
postgres:export <name> > <file>   Export a dump of the postgres service database
postgres:expose <name> [port]     Expose a postgres service on custom port if provided (random port otherwise)
postgres:import <name> < <file>   Import a dump into the postgres service database
postgres:info <name>              Print the connection information
postgres:link <name> <app>        Link the postgres service to the app
postgres:list                     List all postgres services
postgres:logs <name> [-t]         Print the most recent log(s) for this service
postgres:promote <name> <app>     Promote service <name> as DATABASE_URL in <app>
postgres:restart <name>           Graceful shutdown and restart of the postgres service container
postgres:start <name>             Start a previously stopped postgres service
postgres:stop <name>              Stop a running postgres service
postgres:unexpose <name>          Unexpose a previously exposed postgres service
postgres:unlink <name> <app>      Unlink the postgres service from the app
```

## usage

```shell
# create a postgres service named lolipop
dokku postgres:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official postgres image
export POSTGRES_IMAGE="postgres"
export POSTGRES_IMAGE_VERSION="9.5.4"
dokku postgres:create lolipop

# you can also specify custom environment
# variables to start the postgres service
# in semi-colon separated forma
export POSTGRES_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku postgres:create lolipop

# get connection information as follows
dokku postgres:info lolipop

# you can also retrieve a specific piece of service info via flags
dokku postgres:info lolipop --config-dir
dokku postgres:info lolipop --data-dir
dokku postgres:info lolipop --dsn
dokku postgres:info lolipop --exposed-ports
dokku postgres:info lolipop --id
dokku postgres:info lolipop --internal-ip
dokku postgres:info lolipop --links
dokku postgres:info lolipop --service-root
dokku postgres:info lolipop --status
dokku postgres:info lolipop --version

# a bash prompt can be opened against a running service
# filesystem changes will not be saved to disk
dokku postgres:enter lolipop

# you may also run a command directly against the service
# filesystem changes will not be saved to disk
dokku postgres:enter lolipop ls -lah /

# a postgres service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku postgres:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_POSTGRES_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_POSTGRES_LOLIPOP_PORT=tcp://172.17.0.1:5432
#   DOKKU_POSTGRES_LOLIPOP_PORT_5432_TCP=tcp://172.17.0.1:5432
#   DOKKU_POSTGRES_LOLIPOP_PORT_5432_TCP_PROTO=tcp
#   DOKKU_POSTGRES_LOLIPOP_PORT_5432_TCP_PORT=5432
#   DOKKU_POSTGRES_LOLIPOP_PORT_5432_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   DATABASE_URL=postgres://postgres:SOME_PASSWORD@dokku-postgres-lolipop:5432/lolipop
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku postgres:link other_service playground

# since DATABASE_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_POSTGRES_BLUE_URL=postgres://postgres:ANOTHER_PASSWORD@dokku-postgres-other_service:5432/other_service

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku postgres:promote other_service playground

# this will replace DATABASE_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   DATABASE_URL=postgres://postgres:ANOTHER_PASSWORD@dokku-postgres-other_service:5432/other_service
#   DOKKU_POSTGRES_BLUE_URL=postgres://postgres:ANOTHER_PASSWORD@dokku-postgres-other_service:5432/other_service
#   DOKKU_POSTGRES_SILVER_URL=postgres://postgres:SOME_PASSWORD@dokku-postgres-lolipop:5432/lolipop

# you can also unlink a postgres service
# NOTE: this will restart your app and unset related environment variables
dokku postgres:unlink lolipop playground

# you can tail logs for a particular service
dokku postgres:logs lolipop
dokku postgres:logs lolipop -t # to tail

# you can dump the database
dokku postgres:export lolipop > lolipop.dump

# you can import a dump
dokku postgres:import lolipop < database.dump

# you can clone an existing database to a new one
dokku postgres:clone lolipop new_database

# finally, you can destroy the container
dokku postgres:destroy lolipop
```

## Changing database adapter

It's possible to change the protocol for DATABASE_URL by setting
the environment variable POSTGRES_DATABASE_SCHEME on the app:

```
dokku config:set playground POSTGRES_DATABASE_SCHEME=postgres2
dokku postgres:link lolipop playground
```

Will cause DATABASE_URL to be set as
postgres2://postgres:SOME_PASSWORD@dokku-postgres-lolipop:5432/lolipop

CAUTION: Changing POSTGRES_DATABASE_SCHEME after linking will cause dokku to
believe the postgres is not linked when attempting to use `dokku postgres:unlink`
or `dokku postgres:promote`.
You should be able to fix this by

- Changing DATABASE_URL manually to the new value.

OR

- Set POSTGRES_DATABASE_SCHEME back to its original setting
- Unlink the service
- Change POSTGRES_DATABASE_SCHEME to the desired setting
- Relink the service

## upgrade/downgrade

At the moment a database can’t be upgraded  (or downgraded) inplace. Instead a clone has to be made, like this:

```shell
# Our original DB using default PG 9.5.4
$ dokku postgres:create db9.4

# Migrate it like this for example
$ POSTGRES_IMAGE_VERSION=9.5 dokku postgres:clone db9.4 db9.5

# If it was linked to an application, first link the new DB
$ dokku postgres:link db9.5 my_app
# Then unlink the old one
$ dokku postgres:unlink db9.4 my_app

# And last, destroy the old container
$ dokku postgres:destroy db9.4
```

## importing data

The `import` command should be used with any non-plain-text files exported by `pg_dump`. To import a SQL file, use `connect` like this:

```shell
$ dokku postgres:connect db < ./dump.sql
```

## Security

The connection to the database is done over SSL. A self-signed certificate is
automatically generated when creating the service.  It can be replaced by a
custom certificate by overwriting the `server.crt` and `server.key` files in
`/var/lib/dokku/services/postgres/<DB_NAME>/data`.
The `server.key` must be chmoded to 600 and must be owned by the postgres user
or root.

## Backups

Datastore backups are supported via AWS S3. The only supported region is `us-east-1`, and using an S3 bucket in another region will result in an error.

> If you would like to sponsor work to enable support for other regions, please contact [@josegonzalez](http://github.com/josegonzalez/).

Backups can be performed using the backup commands:

```
# setup s3 backup authentication
dokku postgres:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

# remove s3 authentication
dokku postgres:backup-deauth lolipop

# backup the `lolipop` service to the `BUCKET_NAME` bucket on AWS
dokku postgres:backup lolipop BUCKET_NAME

# schedule a backup
# CRON_SCHEDULE is a crontab expression, eg. "0 3 * * *" for each day at 3am
dokku postgres:backup-schedule lolipop CRON_SCHEDULE BUCKET_NAME

# remove the scheduled backup from cron
dokku postgres:backup-unschedule lolipop
```
