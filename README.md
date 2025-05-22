# dokku postgres [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-postgres/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-postgres/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official postgres plugin for dokku. Currently defaults to installing [postgres 17.5](https://hub.docker.com/_/postgres/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git --name postgres
```

## Commands

```
postgres:app-links <app>                           # list all postgres service links for a given app
postgres:backup <service> <bucket-name> [--use-iam] # create a backup of the postgres service to an existing s3 bucket
postgres:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # set up authentication for backups on the postgres service
postgres:backup-deauth <service>                   # remove backup authentication for the postgres service
postgres:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedule a backup of the postgres service
postgres:backup-schedule-cat <service>             # cat the contents of the configured backup cronfile for the service
postgres:backup-set-encryption <service> <passphrase> # set encryption for all future backups of postgres service
postgres:backup-set-public-key-encryption <service> <public-key-id> # set GPG Public Key encryption for all future backups of postgres service
postgres:backup-unschedule <service>               # unschedule the backup of the postgres service
postgres:backup-unset-encryption <service>         # unset encryption for future backups of the postgres service
postgres:backup-unset-public-key-encryption <service> # unset GPG Public Key encryption for future backups of the postgres service
postgres:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
postgres:connect <service>                         # connect to the service via the postgres connection tool
postgres:create <service> [--create-flags...]      # create a postgres service
postgres:destroy <service> [-f|--force]            # delete the postgres service/data/container if there are no links left
postgres:enter <service>                           # enter or run a command in a running postgres service container
postgres:exists <service>                          # check if the postgres service exists
postgres:export <service>                          # export a dump of the postgres service database
postgres:expose <service> <ports...>               # expose a postgres service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
postgres:import <service>                          # import a dump into the postgres service database
postgres:info <service> [--single-info-flag]       # print the service information
postgres:link <service> <app> [--link-flags...]    # link the postgres service to the app
postgres:linked <service> <app>                    # check if the postgres service is linked to an app
postgres:links <service>                           # list all apps linked to the postgres service
postgres:list                                      # list all postgres services
postgres:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
postgres:pause <service>                           # pause a running postgres service
postgres:promote <service> <app>                   # promote service <service> as DATABASE_URL in <app>
postgres:restart <service>                         # graceful shutdown and restart of the postgres service container
postgres:set <service> <key> <value>               # set or clear a property for a service
postgres:start <service>                           # start a previously stopped postgres service
postgres:stop <service>                            # stop a running postgres service
postgres:unexpose <service>                        # unexpose a previously exposed postgres service
postgres:unlink <service> <app>                    # unlink the postgres service from the app
postgres:upgrade <service> [--upgrade-flags...]    # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to postgres:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `postgres:help` command for any undocumented commands.

### Basic Usage

### create a postgres service

```shell
# usage
dokku postgres:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-p|--password PASSWORD`: override the user-level service password
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-r|--root-password PASSWORD`: override the root-level service password
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for postgres docker container

Create a postgres service named lollipop:

```shell
dokku postgres:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the postgres image.

```shell
export POSTGRES_IMAGE="postgres"
export POSTGRES_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku postgres:create lollipop
```

You can also specify custom environment variables to start the postgres service in semicolon-separated form.

```shell
export POSTGRES_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku postgres:create lollipop
```

Official Postgres "$DOCKER_BIN" image ls does not include postgis extension (amongst others). The following example creates a new postgres service using `postgis/postgis:13-3.1` image, which includes the `postgis` extension.

```shell
# use the appropriate image-version for your use-case
dokku postgres:create postgis-database --image "postgis/postgis" --image-version "13-3.1"
```

To use pgvector instead, run the following:

```shell
# use the appropriate image-version for your use-case
dokku postgres:create pgvector-database --image "pgvector/pgvector" --image-version "pg17"
```

### print the service information

```shell
# usage
dokku postgres:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--initial-network`: show the initial network being connected to
- `--links`: show the service app links
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku postgres:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku postgres:info lollipop --config-dir
dokku postgres:info lollipop --data-dir
dokku postgres:info lollipop --dsn
dokku postgres:info lollipop --exposed-ports
dokku postgres:info lollipop --id
dokku postgres:info lollipop --internal-ip
dokku postgres:info lollipop --initial-network
dokku postgres:info lollipop --links
dokku postgres:info lollipop --post-create-network
dokku postgres:info lollipop --post-start-network
dokku postgres:info lollipop --service-root
dokku postgres:info lollipop --status
dokku postgres:info lollipop --version
```

### list all postgres services

```shell
# usage
dokku postgres:list
```

List all services:

```shell
dokku postgres:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku postgres:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku postgres:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku postgres:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku postgres:logs lollipop --tail 5
```

### link the postgres service to the app

```shell
# usage
dokku postgres:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link
- `-n|--no-restart "false"`: whether or not to restart the app on link (default: true)

A postgres service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku postgres:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_POSTGRES_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_POSTGRES_LOLLIPOP_PORT=tcp://172.17.0.1:5432
DOKKU_POSTGRES_LOLLIPOP_PORT_5432_TCP=tcp://172.17.0.1:5432
DOKKU_POSTGRES_LOLLIPOP_PORT_5432_TCP_PROTO=tcp
DOKKU_POSTGRES_LOLLIPOP_PORT_5432_TCP_PORT=5432
DOKKU_POSTGRES_LOLLIPOP_PORT_5432_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
DATABASE_URL=postgres://lollipop:SOME_PASSWORD@dokku-postgres-lollipop:5432/lollipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku postgres:link other_service playground
```

It is possible to change the protocol for `DATABASE_URL` by setting the environment variable `POSTGRES_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground POSTGRES_DATABASE_SCHEME=postgres2
dokku postgres:link lollipop playground
```

This will cause `DATABASE_URL` to be set as:

```
postgres2://lollipop:SOME_PASSWORD@dokku-postgres-lollipop:5432/lollipop
```

### unlink the postgres service from the app

```shell
# usage
dokku postgres:unlink <service> <app>
```

flags:

- `-n|--no-restart "false"`: whether or not to restart the app on unlink (default: true)

You can unlink a postgres service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku postgres:unlink lollipop playground
```

### set or clear a property for a service

```shell
# usage
dokku postgres:set <service> <key> <value>
```

Set the network to attach after the service container is started:

```shell
dokku postgres:set lollipop post-create-network custom-network
```

Set multiple networks:

```shell
dokku postgres:set lollipop post-create-network custom-network,other-network
```

Unset the post-create-network value:

```shell
dokku postgres:set lollipop post-create-network
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the postgres connection tool

```shell
# usage
dokku postgres:connect <service>
```

Connect to the service via the postgres connection tool:

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku postgres:connect lollipop
```

### enter or run a command in a running postgres service container

```shell
# usage
dokku postgres:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku postgres:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku postgres:enter lollipop touch /tmp/test
```

### expose a postgres service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku postgres:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku postgres:expose lollipop 5432
```

Expose the service on the service's normal ports, with the first on a specified ip address (127.0.0.1):

```shell
dokku postgres:expose lollipop 127.0.0.1:5432
```

### unexpose a previously exposed postgres service

```shell
# usage
dokku postgres:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku postgres:unexpose lollipop
```

### promote service <service> as DATABASE_URL in <app>

```shell
# usage
dokku postgres:promote <service> <app>
```

If you have a postgres service linked to an app and try to link another postgres service another link environment variable will be generated automatically:

```
DOKKU_DATABASE_BLUE_URL=postgres://other_service:ANOTHER_PASSWORD@dokku-postgres-other-service:5432/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku postgres:promote other_service playground
```

This will replace `DATABASE_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
DATABASE_URL=postgres://other_service:ANOTHER_PASSWORD@dokku-postgres-other-service:5432/other_service
DOKKU_DATABASE_BLUE_URL=postgres://other_service:ANOTHER_PASSWORD@dokku-postgres-other-service:5432/other_service
DOKKU_DATABASE_SILVER_URL=postgres://lollipop:SOME_PASSWORD@dokku-postgres-lollipop:5432/lollipop
```

### start a previously stopped postgres service

```shell
# usage
dokku postgres:start <service>
```

Start the service:

```shell
dokku postgres:start lollipop
```

### stop a running postgres service

```shell
# usage
dokku postgres:stop <service>
```

Stop the service and removes the running container:

```shell
dokku postgres:stop lollipop
```

### pause a running postgres service

```shell
# usage
dokku postgres:pause <service>
```

Pause the running container for the service:

```shell
dokku postgres:pause lollipop
```

### graceful shutdown and restart of the postgres service container

```shell
# usage
dokku postgres:restart <service>
```

Restart the service:

```shell
dokku postgres:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku postgres:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-R|--restart-apps "true"`: whether or not to force an app restart (default: false)
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for postgres docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku postgres:upgrade lollipop
```

Postgres does not handle upgrading data for major versions automatically (eg. 11 => 12). Upgrades should be done manually. Users are encouraged to upgrade to the latest minor release for their postgres version before performing a major upgrade.

While there are many ways to upgrade a postgres database, for safety purposes, it is recommended that an upgrade is performed by exporting the data from an existing database and importing it into a new database. This also allows testing to ensure that applications interact with the database correctly after the upgrade, and can be used in a staging environment.

The following is an example of how to upgrade a postgres database named `lollipop-11` from 11.13 to 12.8.

```shell
# stop any linked apps
dokku ps:stop linked-app

# export the database contents
dokku postgres:export lollipop-11 > /tmp/lollipop-11.export

# create a new database at the desired version
dokku postgres:create lollipop-12 --image-version 12.8

# import the export file
dokku postgres:import lollipop-12 < /tmp/lollipop-11.export

# run any sql tests against the new database to verify the import went smoothly

# unlink the old database from your apps
dokku postgres:unlink lollipop-11 linked-app

# link the new database to your apps
dokku postgres:link lollipop-12 linked-app

# start the linked apps again
dokku ps:start linked-app
```

### Service Automation

Service scripting can be executed using the following commands:

### list all postgres service links for a given app

```shell
# usage
dokku postgres:app-links <app>
```

List all postgres services that are linked to the `playground` app.

```shell
dokku postgres:app-links playground
```

### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku postgres:clone <service> <new-service> [--clone-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-p|--password PASSWORD`: override the user-level service password
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-r|--root-password PASSWORD`: override the root-level service password
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for postgres docker container

You can clone an existing service to a new one:

```shell
dokku postgres:clone lollipop lollipop-2
```

### check if the postgres service exists

```shell
# usage
dokku postgres:exists <service>
```

Here we check if the lollipop postgres service exists.

```shell
dokku postgres:exists lollipop
```

### check if the postgres service is linked to an app

```shell
# usage
dokku postgres:linked <service> <app>
```

Here we check if the lollipop postgres service is linked to the `playground` app.

```shell
dokku postgres:linked lollipop playground
```

### list all apps linked to the postgres service

```shell
# usage
dokku postgres:links <service>
```

List all apps linked to the `lollipop` postgres service.

```shell
dokku postgres:links lollipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the postgres service database

```shell
# usage
dokku postgres:import <service>
```

Import a datastore dump:

```shell
dokku postgres:import lollipop < data.dump
```

### export a dump of the postgres service database

```shell
# usage
dokku postgres:export <service>
```

By default, datastore output is exported to stdout:

```shell
dokku postgres:export lollipop
```

You can redirect this output to a file:

```shell
dokku postgres:export lollipop > data.dump
```

Note that the export will result in a file containing the binary postgres export data. It can be converted to plain text using `pg_restore` as follows

```shell
pg_restore data.dump -f plain.sql
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### set up authentication for backups on the postgres service

```shell
# usage
dokku postgres:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

```shell
dokku postgres:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku postgres:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku postgres:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku postgres:backup-auth lollipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

### remove backup authentication for the postgres service

```shell
# usage
dokku postgres:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku postgres:backup-deauth lollipop
```

### create a backup of the postgres service to an existing s3 bucket

```shell
# usage
dokku postgres:backup <service> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Backup the `lollipop` service to the `my-s3-bucket` bucket on `AWS`:`

```shell
dokku postgres:backup lollipop my-s3-bucket --use-iam
```

Restore a backup file (assuming it was extracted via `tar -xf backup.tgz`):

```shell
dokku postgres:import lollipop < backup-folder/export
```

### set encryption for all future backups of postgres service

```shell
# usage
dokku postgres:backup-set-encryption <service> <passphrase>
```

Set the GPG-compatible passphrase for encrypting backups for backups:

```shell
dokku postgres:backup-set-encryption lollipop
```

### set GPG Public Key encryption for all future backups of postgres service

```shell
# usage
dokku postgres:backup-set-public-key-encryption <service> <public-key-id>
```

Set the `GPG` Public Key for encrypting backups:

```shell
dokku postgres:backup-set-public-key-encryption lollipop
```

### unset encryption for future backups of the postgres service

```shell
# usage
dokku postgres:backup-unset-encryption <service>
```

Unset the `GPG` encryption passphrase for backups:

```shell
dokku postgres:backup-unset-encryption lollipop
```

### unset GPG Public Key encryption for future backups of the postgres service

```shell
# usage
dokku postgres:backup-unset-public-key-encryption <service>
```

Unset the `GPG` Public Key encryption for backups:

```shell
dokku postgres:backup-unset-public-key-encryption lollipop
```

### schedule a backup of the postgres service

```shell
# usage
dokku postgres:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku postgres:backup-schedule lollipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku postgres:backup-schedule lollipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku postgres:backup-schedule-cat <service>
```

Cat the contents of the configured backup cronfile for the service:

```shell
dokku postgres:backup-schedule-cat lollipop
```

### unschedule the backup of the postgres service

```shell
# usage
dokku postgres:backup-unschedule <service>
```

Remove the scheduled backup from cron:

```shell
dokku postgres:backup-unschedule lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `POSTGRES_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
