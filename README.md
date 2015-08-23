# dokku postgres (beta)

Official postgres plugin for dokku. Currently installs postgres 9.5.

## requirements

- dokku 0.3.25+
- docker 1.6.x

## installation

```
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-postgres-plugin.git postgres
dokku plugins-install-dependencies
dokku plugins-install
```

## commands

```
postgres:alias <name> <alias>     Set an alias for the docker link
postgres:clone <name> <new-name>  NOT IMPLEMENTED
postgres:connect <name>           Connect via psql to a postgres service
postgres:create <name>            Create a postgres service
postgres:destroy <name>           Delete the service and stop its container if there are no links left
postgres:export <name>            Export a dump of the postgres service database
postgres:expose <name> <port>     NOT IMPLEMENTED
postgres:import <name> <file>     NOT IMPLEMENTED
postgres:info <name>              Print the connection information
postgres:link <name> <app>        Link the postgres service to the app
postgres:list                     List all postgres services
postgres:logs <name> [-t]         Print the most recent log(s) for this service
postgres:restart <name>           Graceful shutdown and restart of the service container
postgres:unexpose <name> <port>   NOT IMPLEMENTED
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
#   DATABASE_NAME=/playground/DATABASE
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

# finally, you can destroy the container
dokku postgres:destroy playground
```

## todo

- implement postgres:clone
- implement postgres:expose
- implement postgres:import
