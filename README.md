# dokku postgres [![Build Status](https://img.shields.io/travis/dokku/dokku-postgres.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-postgres) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official postgres plugin for dokku. Currently defaults to installing [postgres 11.6](https://hub.docker.com/_/postgres/).

## Requirements

- dokku 0.12.x+
- docker 1.8.x

## Installation

```shell
# on 0.12.x+
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
```

## Commands

```
postgres:app-links <app>                           # list all postgres service links for a given app
postgres:backup <service> <bucket-name> [--use-iam] # creates a backup of the postgres service to an existing s3 bucket
postgres:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # sets up authentication for backups on the postgres service
postgres:backup-deauth <service>                   # removes backup authentication for the postgres service
postgres:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedules a backup of the postgres service
postgres:backup-schedule-cat <service>             # cat the contents of the configured backup cronfile for the service
postgres:backup-set-encryption <service> <passphrase> # sets encryption for all future backups of postgres service
postgres:backup-unschedule <service>               # unschedules the backup of the postgres service
postgres:backup-unset-encryption <service>         # unsets encryption for future backups of the postgres service
postgres:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
postgres:connect <service>                         # connect to the service via the postgres connection tool
postgres:create <service> [--create-flags...]      # create a postgres service
postgres:destroy <service> [-f|--force]            # delete the postgres service/data/container if there are no links left
postgres:enter <service>                           # enter or run a command in a running postgres service container
postgres:exists <service>                          # check if the postgres service exists
postgres:export <service>                          # export a dump of the postgres service database
postgres:expose <service> <ports...>               # expose a postgres service on custom port if provided (random port otherwise)
postgres:import <service>                          # import a dump into the postgres service database
postgres:info <service> [--single-info-flag]       # print the service information
postgres:link <service> <app> [--link-flags...]    # link the postgres service to the app
postgres:linked <service> <app>                    # check if the postgres service is linked to an app
postgres:links <service>                           # list all apps linked to the postgres service
postgres:list                                      # list all postgres services
postgres:logs <service> [-t|--tail]                # print the most recent log(s) for this service
postgres:promote <service> <app>                   # promote service <service> as DATABASE_URL in <app>
postgres:restart <service>                         # graceful shutdown and restart of the postgres service container
postgres:start <service>                           # start a previously stopped postgres service
postgres:stop <service>                            # stop a running postgres service
postgres:unexpose <service>                        # unexpose a previously exposed postgres service
postgres:unlink <service> <app>                    # unlink the postgres service from the app
postgres:upgrade <service> [--upgrade-flags...]    # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to postgres:help. Please consult the `postgres:help` command for any undocumented commands.

### Basic Usage

### create a postgres service

```shell
# usage
dokku postgres:create <service> [--create-flags...]
```

Create a postgres service named lolipop:

```shell
dokku postgres:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the ${plugin_image} image.

```shell
export DATABASE_IMAGE="${PLUGIN_IMAGE}"
export DATABASE_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku postgres:create lolipop
```

You can also specify custom environment variables to start the postgres service in semi-colon separated form.

```shell
export DATABASE_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku postgres:create lolipop
```

### print the service information

```shell
# usage
dokku postgres:info <service> [--single-info-flag]
```

Get connection information as follows:

```shell
dokku postgres:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
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
dokku postgres:logs <service> [-t|--tail]
```

You can tail logs for a particular service:

```shell
dokku postgres:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku postgres:logs lolipop --tail
```

### link the postgres service to the app

```shell
# usage
dokku postgres:link <service> <app> [--link-flags...]
```

A postgres service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app.

> NOTE: this will restart your app

```shell
dokku postgres:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_DATABASE_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_DATABASE_LOLIPOP_PORT=tcp://172.17.0.1:5432
DOKKU_DATABASE_LOLIPOP_PORT_5432_TCP=tcp://172.17.0.1:5432
DOKKU_DATABASE_LOLIPOP_PORT_5432_TCP_PROTO=tcp
DOKKU_DATABASE_LOLIPOP_PORT_5432_TCP_PORT=5432
DOKKU_DATABASE_LOLIPOP_PORT_5432_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
DATABASE_URL=postgres://lolipop:SOME_PASSWORD@dokku-postgres-lolipop:5432/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the 'expose' subcommand. Another service can be linked to your app:

```shell
dokku postgres:link other_service playground
```

It is possible to change the protocol for database_url by setting the environment variable database_database_scheme on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground DATABASE_DATABASE_SCHEME=postgres2
dokku postgres:link lolipop playground
```

This will cause database_url to be set as:

```
postgres2://lolipop:SOME_PASSWORD@dokku-postgres-lolipop:5432/lolipop
```

### unlink the postgres service from the app

```shell
# usage
dokku postgres:unlink <service> <app>
```

You can unlink a postgres service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku postgres:unlink lolipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the postgres connection tool

```shell
# usage
dokku postgres:connect <service>
```

Connect to the service via the postgres connection tool:

```shell
dokku postgres:connect lolipop
```

### enter or run a command in a running postgres service container

```shell
# usage
dokku postgres:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

```shell
dokku postgres:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku postgres:enter lolipop touch /tmp/test
```

### expose a postgres service on custom port if provided (random port otherwise)

```shell
# usage
dokku postgres:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (0. 0. 0. 0):

```shell
dokku postgres:expose lolipop ${PLUGIN_DATASTORE_PORTS[@]}
```

### unexpose a previously exposed postgres service

```shell
# usage
dokku postgres:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (0. 0. 0. 0):

```shell
dokku postgres:unexpose lolipop
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

This will replace database_url with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
DATABASE_URL=postgres://other_service:ANOTHER_PASSWORD@dokku-postgres-other-service:5432/other_service
DOKKU_DATABASE_BLUE_URL=postgres://other_service:ANOTHER_PASSWORD@dokku-postgres-other-service:5432/other_service
DOKKU_DATABASE_SILVER_URL=postgres://lolipop:SOME_PASSWORD@dokku-postgres-lolipop:5432/lolipop
```

### start a previously stopped postgres service

```shell
# usage
dokku postgres:start <service>
```

Start the service:

```shell
dokku postgres:start lolipop
```

### stop a running postgres service

```shell
# usage
dokku postgres:stop <service>
```

Stop the service and the running container:

```shell
dokku postgres:stop lolipop
```

### graceful shutdown and restart of the postgres service container

```shell
# usage
dokku postgres:restart <service>
```

Restart the service:

```shell
dokku postgres:restart lolipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku postgres:upgrade <service> [--upgrade-flags...]
```

You can upgrade an existing service to a new image or image-version:

```shell
dokku postgres:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all postgres service links for a given app

```shell
# usage
dokku postgres:app-links <app>
```

List all postgres services that are linked to the 'playground' app.

```shell
dokku postgres:app-links playground
```

### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku postgres:clone <service> <new-service> [--clone-flags...]
```

You can clone an existing service to a new one:

```shell
dokku postgres:clone lolipop lolipop-2
```

### check if the postgres service exists

```shell
# usage
dokku postgres:exists <service>
```

Here we check if the lolipop postgres service exists.

```shell
dokku postgres:exists lolipop
```

### check if the postgres service is linked to an app

```shell
# usage
dokku postgres:linked <service> <app>
```

Here we check if the lolipop postgres service is linked to the 'playground' app.

```shell
dokku postgres:linked lolipop playground
```

### list all apps linked to the postgres service

```shell
# usage
dokku postgres:links <service>
```

List all apps linked to the 'lolipop' postgres service.

```shell
dokku postgres:links lolipop
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
dokku postgres:import lolipop < database.dump
```

### export a dump of the postgres service database

```shell
# usage
dokku postgres:export <service>
```

By default, datastore output is exported to stdout:

```shell
dokku postgres:export lolipop
```

You can redirect this output to a file:

```shell
dokku postgres:export lolipop > lolipop.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### sets up authentication for backups on the postgres service

```shell
# usage
dokku postgres:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

```shell
dokku postgres:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku postgres:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku postgres:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku postgres:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

### removes backup authentication for the postgres service

```shell
# usage
dokku postgres:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku postgres:backup-deauth lolipop
```

### creates a backup of the postgres service to an existing s3 bucket

```shell
# usage
dokku postgres:backup <service> <bucket-name> [--use-iam]
```

Backup the 'lolipop' service to the 'my-s3-bucket' bucket on aws:

```shell
dokku postgres:backup lolipop my-s3-bucket --use-iam
```

### sets encryption for all future backups of postgres service

```shell
# usage
dokku postgres:backup-set-encryption <service> <passphrase>
```

Set a gpg passphrase for backups:

```shell
dokku postgres:backup-set-encryption lolipop
```

### unsets encryption for future backups of the postgres service

```shell
# usage
dokku postgres:backup-unset-encryption <service>
```

Unset a gpg encryption key for backups:

```shell
dokku postgres:backup-unset-encryption lolipop
```

### schedules a backup of the postgres service

```shell
# usage
dokku postgres:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku postgres:backup-schedule lolipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku postgres:backup-schedule lolipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku postgres:backup-schedule-cat <service>
```

Cat the contents of the configured backup cronfile for the service:

```shell
dokku postgres:backup-schedule-cat lolipop
```

### unschedules the backup of the postgres service

```shell
# usage
dokku postgres:backup-unschedule <service>
```

Remove the scheduled backup from cron:

```shell
dokku postgres:backup-unschedule lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `POSTGRES_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.