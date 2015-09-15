# dokku postgres (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-postgres.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-postgres) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official postgres plugin for dokku. Currently defaults to installing [postgres 9.4.4](https://hub.docker.com/_/postgres/).

## requirements

- dokku 0.4.0+
- docker 1.8.x

## installation

```
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-postgres.git postgres
dokku plugins-install-dependencies
dokku plugins-install
```

## commands

```
postgres:alias <name> <alias>     Set an alias for the docker link
postgres:clone <name> <new-name>  Create container <new-name> then copy data from <name> into <new-name>
postgres:connect <name>           Connect via psql to a postgres service
postgres:create <name>            Create a postgres service
postgres:destroy <name>           Delete the service and stop its container if there are no links left
postgres:export <name>            Export a dump of the postgres service database
postgres:expose <name> [port]     Expose a postgres service on custom port if provided (random port otherwise)
postgres:import <name> < <file>   Import a dump into the postgres service database
postgres:info <name>              Print the connection information
postgres:link <name> <app>        Link the postgres service to the app
postgres:list                     List all postgres services
postgres:logs <name> [-t]         Print the most recent log(s) for this service
postgres:restart <name>           Graceful shutdown and restart of the postgres service container
postgres:start <name>             Start a previously stopped postgres service
postgres:stop <name>              Stop a running postgres service
postgres:unexpose <name>          Unexpose a previously exposed postgres service
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
export POSTGRES_IMAGE_VERSION="9.4.4"
dokku postgres:create lolipop

# get connection information as follows
dokku postgres:info lolipop

# lets assume the ip of our postgres service is 172.17.0.1

# a postgres service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku postgres:link lolipop playground

# the above will expose the following environment variables
#
#   DATABASE_URL=postgres://postgres:SOME_PASSWORD@172.17.0.1:5432/lolipop
#   DATABASE_NAME=/lolipop/DATABASE
#   DATABASE_PORT=tcp://172.17.0.1:5432
#   DATABASE_PORT_5432_TCP=tcp://172.17.0.1:5432
#   DATABASE_PORT_5432_TCP_PROTO=tcp
#   DATABASE_PORT_5432_TCP_PORT=5432
#   DATABASE_PORT_5432_TCP_ADDR=172.17.0.1

# you can customize the environment
# variables through a custom docker link alias
dokku postgres:alias lolipop POSTGRES_DATABASE

# you can also unlink a postgres service
# NOTE: this will restart your app
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

## upgrade/downgrade

At the moment a database can’t be upgraded  (or downgraded) inplace. Instead a clone has to be made, like this:

```shell
# Our original DB using default PG 9.4.4
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
