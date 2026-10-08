# dokku postgres [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-postgres/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-postgres/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official postgres plugin for dokku. Currently defaults to installing [postgres 18.6](https://hub.docker.com/_/postgres/).

## Requirements

- dokku 0.35.x+
- docker 1.8.x

## Installation

```shell
# on 0.35.x+
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git --name postgres
```

## Commands

```
postgres:app-links [<app>]                         # list all Postgres service links for a given app
postgres:backup <service> <bucket-name> [-u|--use-iam] # create a backup of the Postgres service to an existing s3 bucket
postgres:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # set up authentication for backups on the Postgres service
postgres:backup-deauth <service>                   # remove backup authentication for the Postgres service
postgres:backup-logs <service> [-t|--tail [<tail-num>]] # print the most recent output of the scheduled backups of the service
postgres:backup-schedule <service> <schedule> <bucket-name> [-u|--use-iam] # schedule a backup of the Postgres service
postgres:backup-schedule-cat <service>             # cat the crontab line of the scheduled backup for the service
postgres:backup-set-encryption <service> <passphrase> # set encryption for all future backups of Postgres service
postgres:backup-set-public-key-encryption <service> <public-key-id> # set GPG Public Key encryption for all future backups of Postgres service
postgres:backup-unschedule <service>               # unschedule the backup of the Postgres service
postgres:backup-unset-encryption <service>         # unset encryption for future backups of the Postgres service
postgres:backup-unset-public-key-encryption <service> # unset GPG Public Key encryption for future backups of the Postgres service
postgres:certificate <service>                     # print the certificate the Postgres service encrypts connections with
postgres:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
postgres:connect <service>                         # connect to the service via the postgres connection tool
postgres:create <service> [--create-flags...]      # create a Postgres service
postgres:destroy <service> [-f|--force]            # delete the Postgres service/data/container if there are no links left
postgres:enter <service>                           # enter or run a command in a running Postgres service container
postgres:exists <service>                          # check if the Postgres service exists
postgres:export <service> [-f|--file <path>] [--force] [--all-databases] [-- <export-args...>] # export a dump of the Postgres service database
postgres:expose <service> <ports...>               # expose a Postgres service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
postgres:import <service> [-f|--file <path>] [--all-databases] [-- <import-args...>] # import a dump into the Postgres service database
postgres:info [<service>] [--info-flags...]        # print the service information
postgres:link <service> [<app>] [--link-flags...]  # link the Postgres service to the app
postgres:linked <service> [<app>]                  # check if the Postgres service is linked to an app
postgres:links <service>                           # list all apps linked to the Postgres service
postgres:list                                      # list all Postgres services
postgres:logs <service> [-t|--tail [<tail-num>]]   # print the most recent log(s) for this service
postgres:mount [--replace] <service> <source:container-dir[:options]>... # mount a host path or docker volume into the service container
postgres:pause <service>                           # pause a running Postgres service
postgres:promote <service> [<app>]                 # promote service <service> as DATABASE_URL in <app>
postgres:reexpose <service>                        # reexpose a Postgres service, applying its expose settings
postgres:reset <service> [-f|--force]              # delete all data in the Postgres service, keeping the service and its links
postgres:restart <service>                         # graceful shutdown and restart of the Postgres service container
postgres:set <service> <key> <value>               # set or clear a property for a service
postgres:start <service>                           # start a previously stopped Postgres service
postgres:stop <service>                            # stop a running Postgres service
postgres:unexpose <service>                        # unexpose a previously exposed Postgres service
postgres:unlink <service> [<app>] [-n|--no-restart] # unlink the Postgres service from the app
postgres:unmount [--all] <service> [<source:container-dir>...] # remove one or all mounts from the service container
postgres:upgrade <service> [--upgrade-flags...]    # upgrade service <service> to the specified versions
postgres:upgrade-cleanup <service>                 # remove the data an upgrade across a major version kept aside
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to postgres:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `postgres:help` command for any undocumented commands.

### Basic Usage

### create a Postgres service

```shell
# usage
dokku postgres:create <service> [--create-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `--definition <string>`: the definition to run the service on, instead of the one its image and version resolve to
- `-i|--image <string>`: the image name to start the service with
- `-I|--image-version <string>`: the image version to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password, for datastores that have one
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-r|--root-password <string>`: override the root-level service password, for datastores that have one
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable
- `--volume-target <stringArray>`: mount one of the definition's volumes at another container path, as <volume>=<container-dir>, repeatable
- `--wait-timeout <string>`: seconds to wait for the service to become ready (default: the datastore's own)

Create a postgres service named lollipop:

```shell
dokku postgres:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the postgres image.

```shell
export POSTGRES_IMAGE="postgres"
export POSTGRES_IMAGE_VERSION="18.6"
dokku postgres:create lollipop
```

An image other than postgres has no version to fall back on, because the version this plugin pins belongs to postgres, so name one alongside it.

```shell
dokku postgres:create lollipop --image <image> --image-version <version>
```

These images each have definitions of their own, one per major version, so a service on one is placed by the major its tag carries and has a version to fall back on.

```shell
dokku postgres:create lollipop --image pgvector/pgvector --image-version 0.8.7-pg18
dokku postgres:create lollipop --image postgis/postgis --image-version 18-3.6
dokku postgres:create lollipop --image timescale/timescaledb --image-version 2.30.2-pg18
```

The definition a service runs on decides where its data is mounted, and is otherwise worked out from the image and version. An image whose tags do not carry the major version can name one outright, and --image and --image-version are laid over the image and version it ships. The definitions are: postgres-17, postgres-18, postgres-pgvector-pg17, postgres-pgvector-pg18, postgres-postgis-pg17, postgres-postgis-pg18, postgres-timescaledb-pg17, postgres-timescaledb-pg18.

```shell
export POSTGRES_DEFINITION="postgres-17"
dokku postgres:create lollipop --definition postgres-17 --image <image> --image-version <version>
```

You can also specify custom environment variables to start the postgres service in semicolon-separated form.

```shell
export POSTGRES_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku postgres:create lollipop
```

The container log is bounded by whatever `dokku logs:set --global max-size` says, and by dokku's own default where it says nothing, which a service may override for itself.

```shell
dokku postgres:create lollipop --log-opt max-size=20m,max-file=3
```

The container is restarted by docker whenever it stops, which a service may change for itself.

```shell
dokku postgres:create lollipop --restart unless-stopped
```

The service is waited on until it answers, for as long as the datastore's own default, which a slow host may raise for every service with `POSTGRES_WAIT_TIMEOUT` or a service may raise for itself.

```shell
dokku postgres:create lollipop --wait-timeout 120
```

The config options are handed to the process the container runs, not to docker, so a host path or docker volume is mounted with --volume, which may be repeated.

```shell
dokku postgres:create lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
```

The definition's own volumes can be mounted at another path in the container, for an image that keeps its data somewhere else, with --volume-target, which may be repeated.

```shell
export POSTGRES_VOLUME_TARGETS="data=/srv/postgres"
dokku postgres:create lollipop --volume-target data=/srv/postgres
```

The service passwords are generated unless they are given. A datastore without a root password refuses --root-password rather than dropping it.

```shell
dokku postgres:create lollipop --password <password> --root-password <root-password>
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

### delete the Postgres service/data/container if there are no links left

```shell
# usage
dokku postgres:destroy <service> [-f|--force]
```

flags:

- `-f|--force`: force the destruction of the service

Destroy the service, it's data, and the running container:

```shell
dokku postgres:destroy lollipop
```

A service that is still linked to an app is not destroyed, and the apps it is linked to are named. Unlink them first.

### print the service information

```shell
# usage
dokku postgres:info [<service>] [--info-flags...]
```

flags:

- `--backend`: show the execution backend the service was created with
- `--backup-auth-fingerprint`: show a sha256 fingerprint of the stored backup access key id and secret
- `--backup-authenticated`: show whether backup credentials are stored for the service
- `--backup-bucket`: show the bucket scheduled backups are shipped to
- `--backup-default-region`: show the region backups authenticate against
- `--backup-encrypted`: show whether scheduled backups are encrypted with a passphrase
- `--backup-encryption-fingerprint`: show a sha256 fingerprint of the stored backup passphrase
- `--backup-endpoint-url`: show the s3-compatible endpoint backups are shipped to
- `--backup-keyserver`: show the keyserver backup public keys are fetched from
- `--backup-mailto`: show who cron mails the output of scheduled backups to in place of the global MAILTO
- `--backup-object-name`: show the name backups are uploaded under in place of the default
- `--backup-public-key-id`: show the gpg public key id backups are encrypted with
- `--backup-schedule`: show the cron schedule backups run on
- `--backup-signature-version`: show the signature version backups authenticate with
- `--backup-storage-class`: show the s3 storage class backups are uploaded with
- `--backup-timestamp`: show whether backups are uploaded under a key ending in the time they started
- `--backup-use-iam`: show whether scheduled backups authenticate with an instance role
- `--config-dir`: show the service configuration directory
- `--config-options`: show the config options the service container is run with
- `--custom-env`: show the custom environment the service container is run with
- `--data-dir`: show the service data directory
- `--database-name`: show the name of the database inside the service
- `--definition`: show the definition the service was created with
- `--dsn`: show the service DSN
- `--export-args`: show the extra arguments every export of the service is run with
- `--expose-host`: show the host the exposed DSN names
- `--expose-mode`: show whether exposed ports are published through an ambassador or directly by the service container
- `--exposed-dsn`: show the DSN the service is reached at through its exposed ports
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--image`: show the image the service runs
- `--image-version`: show the image version the service was created with
- `--import-args`: show the extra arguments every import into the service is run with
- `--initial-network`: show the initial network being connected to
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--log-driver`: show the docker logging driver the service container is run with
- `--log-opt`: show the docker log options the service container is run with
- `--memory`: show the memory limit the service container is run with
- `--mounts`: show the host paths and docker volumes mounted into the service container
- `--port-bind-address`: show the address exposed ports without one of their own are bound on
- `--port-source-range`: show the only range of client addresses the exposed ports accept
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--restart-policy`: show the restart policy the service container is run with
- `--service`: show the name of the service
- `--service-root`: show the service root directory
- `--shm-size`: show the shared memory size the service container is run with
- `--status`: show the service running status
- `--version`: show the service image version
- `--volume-targets`: show the container paths the service's volumes are mounted at in place of the definition's
- `--wait-timeout`: show the seconds the service is waited on to become ready

Get connection information as follows:

```shell
dokku postgres:info lollipop
```

Alongside the connection information this reports the properties set on the service, the state it was created with, and its backup settings. A property that was never set, or that was unset, reports as empty. Omit the service to report on every postgres service:

```shell
dokku postgres:info
```

The information can be read by machine, one json object per service:

```shell
dokku postgres:info lollipop --format json
```

You can also retrieve a specific piece of service info via a flag, which prints it on its own:

```shell
dokku postgres:info lollipop --dsn
dokku postgres:info lollipop --status
dokku postgres:info lollipop --internal-ip
dokku postgres:info lollipop --initial-network
```

> NOTE: a flag cannot be combined with --format, and only one may be given

The exposed dsn is the one a client off the host connects with. It names the expose-host, or the first global domain without one, and is empty until the service is exposed and there is a host to name:

```shell
dokku postgres:info lollipop --exposed-dsn
```

The properties postgres:set writes are reported under the names it takes, so a value read here can be written back:

```shell
dokku postgres:set lollipop initial-network my-network
```

The stored backup credentials and passphrase are never printed. Each is reported as a lowercase hex sha256 fingerprint of the stored value, with surrounding whitespace trimmed, so a copy of the values can be compared against it:

```shell
dokku postgres:info lollipop --backup-auth-fingerprint
dokku postgres:info lollipop --backup-encryption-fingerprint
```

The same fingerprints can be computed from the values that were passed to backup-auth and backup-set-encryption:

```
printf '%s\n%s' "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" | sha256sum
printf '%s' "$PASSPHRASE" | sha256sum
```

### list all Postgres services

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
dokku postgres:logs <service> [-t|--tail [<tail-num>]]
```

flags:

- `-t|--tail <int>`: tail the logs, optionally showing this many lines

You can tail logs for a particular service:

```shell
dokku postgres:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku postgres:logs lollipop --tail
```

By default the last 100 lines are shown, but a different count can be specified:

```shell
dokku postgres:logs lollipop --tail=5
```

### link the Postgres service to the app

```shell
# usage
dokku postgres:link <service> [<app>] [--link-flags...]
```

flags:

- `-a|--alias <string>`: the prefix of the config variable the service url is set as on the app, which is suffixed with _URL
- `-e|--env-var <string>`: the full name of the config variable the service url is set as on the app, used instead of an alias and not suffixed with _URL
- `-n|--no-restart`: whether to skip restarting the app
- `-q|--querystring <string>`: ampersand delimited querystring arguments to append to the service url after a ?

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
DATABASE_URL=postgres://:SOME_PASSWORD@dokku-postgres-lollipop:5432
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku postgres:link other_service playground
```

The url can be set under another name with the `--alias` flag. The value given is the prefix of the config variable, which is suffixed with `_URL` and holds the same url:

```shell
dokku postgres:link lollipop playground --alias BLUE_DATABASE
```

This will set the following on the linked application instead of `DATABASE_URL`:

```
BLUE_DATABASE_URL=postgres://:SOME_PASSWORD@dokku-postgres-lollipop:5432
```

An alias whose variable is already set on the app is refused, and unlink removes the variable whatever alias it was set under. An app that expects the url under a name that does not end in `_URL` can be given that name in full with the `--env-var` flag, which cannot be combined with `--alias`:

```shell
dokku postgres:link lollipop playground --env-var MB_DB_CONNECTION_URI
```

This will set the following on the linked application instead of `DATABASE_URL`:

```
MB_DB_CONNECTION_URI=postgres://:SOME_PASSWORD@dokku-postgres-lollipop:5432
```

A name already set on the app is refused. Arguments can be appended to the url as a querystring with the `--querystring` flag:

```shell
dokku postgres:link lollipop playground --querystring "foo=bar&baz=qux"
```

This will cause `DATABASE_URL` to be set as:

```
postgres://:SOME_PASSWORD@dokku-postgres-lollipop:5432?foo=bar&baz=qux
```

It is possible to change the protocol for `DATABASE_URL` by setting the environment variable `POSTGRES_DATABASE_SCHEME` on the app. Link records the variable it set, so unlink still removes it after the scheme or querystring on it changes. A link made by an earlier version of the plugin is recorded the next time link or promote runs for it, and until then we advise you to unlink before changing the scheme.

```shell
dokku config:set playground POSTGRES_DATABASE_SCHEME=postgres2
dokku postgres:link lollipop playground
```

This will cause `DATABASE_URL` to be set as:

```
postgres2://:SOME_PASSWORD@dokku-postgres-lollipop:5432
```

### unlink the Postgres service from the app

```shell
# usage
dokku postgres:unlink <service> [<app>] [-n|--no-restart]
```

flags:

- `-n|--no-restart`: whether to skip restarting the app

You can unlink a postgres service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku postgres:unlink lollipop playground
```

An app is still linked after its `DATABASE_URL` is changed to point elsewhere, and is unlinked the same way. The variable it now holds is not the service's, so it is left alone, nothing is unset, the app is not restarted, and a warning says so. A variable link set that has only had its scheme or querystring changed still points at the service, and is unset.

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

Set the keyserver a public key for backup encryption is fetched from:

```shell
dokku postgres:set lollipop backup-keyserver hkp://keys.example.com
```

Set the s3 storage class backups are uploaded with, one of `STANDARD,` `REDUCED_REDUNDANCY,` `STANDARD_IA,` `ONEZONE_IA,` `INTELLIGENT_TIERING,` `GLACIER,` `DEEP_ARCHIVE` or `GLACIER_IR`:

```shell
dokku postgres:set lollipop backup-storage-class STANDARD_IA
```

Go back to uploading backups with the bucket's default storage class:

```shell
dokku postgres:set lollipop backup-storage-class
```

Upload backups under a name of your own rather than postgres-lollipop:

```shell
dokku postgres:set lollipop backup-object-name db/latest
```

Upload every backup to the same key, without a timestamp, so bucket versioning and lifecycle rules can keep and rotate them:

```shell
dokku postgres:set lollipop backup-timestamp false
```

Go back to timestamped backups:

```shell
dokku postgres:set lollipop backup-timestamp
```

Mail the output of scheduled backups to a comma-separated list of email addresses or local users rather than to the global cron `MAILTO`. Requires a dokku version that reads json entries from the cron-entries plugin trigger, and a mail transfer agent on the host:

```shell
dokku postgres:set lollipop backup-mailto ops@example.com,dba@example.com
```

Go back to mailing scheduled backup output to the global cron `MAILTO`:

```shell
dokku postgres:set lollipop backup-mailto
```

Cap the container log at a size of your own rather than the one it inherits:

```shell
dokku postgres:set lollipop log-opt max-size=20m,max-file=3
```

Keep the log unbounded, which is what a service had before there was anything to say here:

```shell
dokku postgres:set lollipop log-opt max-size=unlimited
```

Send the container log somewhere other than the daemon's own driver:

```shell
dokku postgres:set lollipop log-driver journald
```

Restart the container unless it was stopped on purpose, including across a docker restart:

```shell
dokku postgres:set lollipop restart-policy unless-stopped
```

Go back to always restarting the container:

```shell
dokku postgres:set lollipop restart-policy
```

Wait up to two minutes for the service to answer, used the next time it is started:

```shell
dokku postgres:set lollipop wait-timeout 120
```

Go back to the wait timeout the host or the datastore sets:

```shell
dokku postgres:set lollipop wait-timeout
```

Publish exposed ports that have no address of their own on one address rather than on every interface:

```shell
dokku postgres:set lollipop port-bind-address 10.0.0.5
```

Only accept connections to the exposed ports from clients in one `IP` address or `CIDR`:

```shell
dokku postgres:set lollipop port-source-range 10.0.0.0/8
```

Go back to accepting every client:

```shell
dokku postgres:set lollipop port-source-range
```

Name the host the exposed dsn points clients at, when they reach the server by a name or address other than its global domain. It does not change where the ports are bound:

```shell
dokku postgres:set lollipop expose-host db.example.com
```

Go back to naming the first global domain:

```shell
dokku postgres:set lollipop expose-host
```

Publish the exposed ports on the service container itself rather than through an ambassador container, which relays every connection. A port-source-range cannot be used with it:

```shell
dokku postgres:set lollipop expose-mode direct
```

Go back to publishing the exposed ports through an ambassador container:

```shell
dokku postgres:set lollipop expose-mode
```

Pass extra arguments to every export of the service, including the ones backups and clones make. The value follows -- so that its leading dash is not read as a flag, and an argument with a space in it is quoted:

```shell
dokku postgres:set lollipop export-args -- "<export-args...>"
```

Go back to exporting with the datastore's own arguments alone:

```shell
dokku postgres:set lollipop export-args
```

Pass extra arguments to every import into the service, including the one a clone makes:

```shell
dokku postgres:set lollipop import-args -- "<import-args...>"
```

Go back to importing with the datastore's own arguments alone:

```shell
dokku postgres:set lollipop import-args
```

Mount one of the definition's volumes at another path in the container, for an image that keeps its data somewhere else. Each volume is named by where it lives in the service directory (data, certs), and several are separated by spaces:

```shell
dokku postgres:set lollipop volume-targets data=/srv/postgres
```

Go back to mounting every volume where the definition does:

```shell
dokku postgres:set lollipop volume-targets
```

> NOTE: a log setting, a restart policy or a volume target reaches the container the next time one is built. postgres:restart keeps the container it has, so use postgres:stop and then postgres:start on a service that is already running.
> NOTE: a port-bind-address or port-source-range reaches an exposed service with postgres:reexpose, which replaces the container publishing its ports and leaves the service container running.
> NOTE: an expose-mode, or a port-bind-address for a service exposed directly, reaches an exposed service with postgres:reexpose, which stops and starts a running service after asking. It also reaches the service the next time it is restarted, or stopped and started.

### mount a host path or docker volume into the service container

```shell
# usage
dokku postgres:mount [--replace] <service> <source:container-dir[:options]>...
```

flags:

- `--replace`: replace the service's entire set of mounts with the ones given
- `--volume-chown <string>`: who to hand the mounted directory to, for a host path inside the service's directory; not valid with --replace
- `--volume-options <string>`: comma-separated docker mount options, such as z or nocopy; not valid with --replace
- `--volume-readonly`: mount the volume read only; not valid with --replace
- `--volume-subpath <string>`: a subpath within the source to mount rather than the source itself; not valid with --replace

Mount a host directory into the service container:

```shell
dokku postgres:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

The source is an absolute host path, which must already exist, or the name of a docker volume. Options follow a second colon: ro or rw, docker's own mount options, volume-subpath=<path> and volume-chown=<option>:

```shell
dokku postgres:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra:ro,z
```

A subpath mounts a directory within the source rather than the source itself. A docker volume mounted from a subpath needs Docker Engine 26.0 or newer, and takes no mount option but nocopy.

```shell
dokku postgres:mount lollipop my-volume:/opt/extra:volume-subpath=uploads
```

A chown hands the mounted directory to a user before the container is made: herokuish, heroku, paketo, root or a uid. It is only taken for a host path inside the service's own directory.

```shell
dokku postgres:mount lollipop /var/lib/dokku/services/postgres/lollipop/extra:/opt/extra:volume-chown=heroku
```

The same can be said with flags instead:

```shell
dokku postgres:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra --volume-readonly --volume-options z
```

Mounting the same source at the same directory again rewrites its options:

```shell
dokku postgres:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

Replace every mount the service has with the ones given:

```shell
dokku postgres:mount --replace lollipop /srv/a:/opt/a:ro /srv/b:/opt/b
```

> NOTE: a mount cannot land where one of the definition's volumes is mounted, which for a volume moved with the volume-targets property is where it was moved to.
> NOTE: a mount reaches the container the next time one is built. postgres:restart keeps the container it has, so use postgres:stop and then postgres:start on a service that is already running.

### remove one or all mounts from the service container

```shell
# usage
dokku postgres:unmount [--all] <service> [<source:container-dir>...]
```

flags:

- `--all`: remove every mount the service has

Remove a mount, naming it the way it was mounted:

```shell
dokku postgres:unmount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

Remove every mount the service has:

```shell
dokku postgres:unmount --all lollipop
```

> NOTE: the mount is removed from the container the next time one is built. postgres:restart keeps the container it has, so use postgres:stop and then postgres:start on a service that is already running.

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

The connection tool only shows a prompt when it is given a terminal, which ssh allocates when run with -t. Without a terminal, statements are read from stdin instead.

```shell
dokku postgres:connect lollipop < statements.txt
```

### enter or run a command in a running Postgres service container

```shell
# usage
dokku postgres:enter <service>
```

A shell can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku postgres:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku postgres:enter lollipop touch /tmp/test
```

### expose a Postgres service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku postgres:expose <service> <ports...>
```

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku postgres:expose lollipop 5432
```

Expose the service on the service's normal ports, with the first on a specified ip address (127.0.0.1):

```shell
dokku postgres:expose lollipop 127.0.0.1:5432
```

Expose the service on random ports on a single address, and only to clients in one network:

```shell
dokku postgres:set lollipop port-bind-address 10.0.0.5
dokku postgres:set lollipop port-source-range 10.0.0.0/8
dokku postgres:expose lollipop
```

Expose the service by publishing its ports on the service container itself rather than through an ambassador container. A running service is stopped and started to publish them, after asking, or without asking when --force is given:

```shell
dokku postgres:set lollipop expose-mode direct
dokku postgres:expose lollipop --force
```

Print the dsn a client off the host connects with, which names the expose-host or the first global domain:

```shell
dokku postgres:info lollipop --exposed-dsn
```

### unexpose a previously exposed Postgres service

```shell
# usage
dokku postgres:unexpose <service>
```

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku postgres:unexpose lollipop
```

Unexpose a running service exposed directly, stopping and starting it without asking so that its container stops publishing the ports:

```shell
dokku postgres:unexpose lollipop --force
```

### reexpose a Postgres service, applying its expose settings

```shell
# usage
dokku postgres:reexpose <service>
```

flags:

- `-f|--force`: stop and start a running service without asking when its container has to publish other ports

Apply a changed port-bind-address or port-source-range to an exposed service, on the ports it is already exposed on:

```shell
dokku postgres:set lollipop port-source-range 10.0.0.0/8
dokku postgres:reexpose lollipop
```

Move an exposed service between being published through an ambassador and directly, stopping and starting it without asking:

```shell
dokku postgres:set lollipop expose-mode direct
dokku postgres:reexpose lollipop --force
```

> NOTE: a service published through an ambassador only has the ambassador replaced, so the service keeps running, though connections made through the exposed ports are dropped. An ambassador that already matches the service's settings and is publishing is left alone.
> NOTE: a service whose container has to publish other ports, because it is exposed directly or is being moved between expose modes, is stopped and started. A running service is asked about first, and nothing is changed if the answer is no.
> NOTE: A service that is not exposed is refused, as is one published through an ambassador that is not running.

### promote service <service> as DATABASE_URL in <app>

```shell
# usage
dokku postgres:promote <service> [<app>]
```

If you have a postgres service linked to an app and try to link another postgres service another link environment variable will be generated automatically:

```
DOKKU_POSTGRES_AQUA_URL=postgres://:ANOTHER_PASSWORD@dokku-postgres-other-service:5432/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku postgres:promote other_service playground
```

This will replace `DATABASE_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
DATABASE_URL=postgres://:ANOTHER_PASSWORD@dokku-postgres-other-service:5432/other_service
DOKKU_POSTGRES_AQUA_URL=postgres://:ANOTHER_PASSWORD@dokku-postgres-other-service:5432/other_service
DOKKU_POSTGRES_BLACK_URL=postgres://:SOME_PASSWORD@dokku-postgres-lollipop:5432/lollipop
```

### start a previously stopped Postgres service

```shell
# usage
dokku postgres:start <service>
```

Start the service:

```shell
dokku postgres:start lollipop
```

A service comes back on the version it was created with, or was last upgraded to, whatever version the plugin ships now. The image is fetched if the host no longer has it. A service that has never recorded a version and has no container left to read one from cannot be placed, and is reported rather than started on a guess. Use postgres:upgrade to say which version it should run.

### stop a running Postgres service

```shell
# usage
dokku postgres:stop <service>
```

Stop the service and removes the running container:

```shell
dokku postgres:stop lollipop
```

### pause a running Postgres service

```shell
# usage
dokku postgres:pause <service>
```

Pause the running container for the service:

```shell
dokku postgres:pause lollipop
```

### graceful shutdown and restart of the Postgres service container

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

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `--definition <string>`: the definition to move the service onto, instead of the one its image and version resolve to
- `-i|--image <string>`: the image to upgrade the service to
- `-I|--image-version <string>`: the image version to upgrade the service to
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes, 0 for unlimited
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-R|--restart-apps`: whether to stop and start the linked apps around the upgrade, required for one that migrates the data
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable
- `--volume-target <stringArray>`: mount one of the definition's volumes at another container path, as <volume>=<container-dir>, repeatable
- `--wait-timeout <string>`: seconds to wait for the service to become ready (default: the datastore's own)

You can upgrade an existing service to a new image or image-version:

```shell
dokku postgres:upgrade lollipop
```

This is the only command that changes the version a service runs. With no version named it moves to the newest the service's own major version ships, which leaves the data where it is.

```shell
dokku postgres:upgrade lollipop --image-version 1.2.3
```

Moving across a major version has to be asked for by name, because it is not a tag change: the data is mounted somewhere different under the new one, and pointing the version back does not undo it. A service can also be moved onto a definition by name, with --image and --image-version laid over the image and version it ships. This moves where the data is mounted in the same way, even when the image stays the same.

```shell
dokku postgres:upgrade lollipop --definition postgres-17
```

An upgrade that moves a service onto another of its definitions carries the data across rather than leaving it where the new one would not read it, which needs --restart-apps so that the linked apps write nothing while it is copied. The old data is kept beside the new, and a move that fails puts the service back on what it ran.

```shell
dokku postgres:upgrade lollipop --definition postgres-17 --restart-apps
```

A service keeps the mounts it has unless --volume is passed, which replaces them, and each one is checked against the new container before the old one is taken away.

```shell
dokku postgres:upgrade lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
```

A service keeps the volume targets it has unless --volume-target is passed, which replaces them, and an upgrade onto a definition that does not mount a volume the service moved is refused before the old container is taken away. --volume-target "" puts every volume back where the new definition mounts it.

```shell
dokku postgres:upgrade lollipop --volume-target ""
```

A service keeps its memory limit unless --memory is passed, and --memory 0 removes it.

```shell
dokku postgres:upgrade lollipop --memory 512
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

### list all Postgres service links for a given app

```shell
# usage
dokku postgres:app-links [<app>]
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

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password, for datastores that have one
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-r|--root-password <string>`: override the root-level service password, for datastores that have one
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable
- `--volume-target <stringArray>`: mount one of the definition's volumes at another container path, as <volume>=<container-dir>, repeatable
- `--wait-timeout <string>`: seconds to wait for the service to become ready (default: the datastore's own)

You can clone an existing service to a new one:

```shell
dokku postgres:clone lollipop lollipop-2
```

The new service starts from the settings of the one it copies: its config options, custom env, memory, shm size, networks, log driver, log options, restart policy, mounts, volume targets, backup keyserver, backup storage class and backup timestamp. A flag passed to clone overrides that one setting, and a flag passed empty clears it:

```shell
dokku postgres:clone lollipop lollipop-2 --restart no --custom-env ""
```

The password, exposed ports, links and backup credentials, schedule, encryption and object name are not copied. The clone's passwords are generated unless they are given.

```shell
dokku postgres:clone lollipop lollipop-2 --password <password>
```

### check if the Postgres service exists

```shell
# usage
dokku postgres:exists <service>
```

Here we check if the lollipop postgres service exists.

```shell
dokku postgres:exists lollipop
```

### check if the Postgres service is linked to an app

```shell
# usage
dokku postgres:linked <service> [<app>]
```

Here we check if the lollipop postgres service is linked to the `playground` app.

```shell
dokku postgres:linked lollipop playground
```

### list all apps linked to the Postgres service

```shell
# usage
dokku postgres:links <service>
```

List all apps linked to the `lollipop` postgres service.

```shell
dokku postgres:links lollipop
```

Renaming an app moves its link onto the new name, and cloning an app links the clone as well as the original.

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the Postgres service database

```shell
# usage
dokku postgres:import <service> [-f|--file <path>] [--all-databases] [-- <import-args...>]
```

flags:

- `--all-databases`: load a dump of every database in the service, as written by export --all-databases or a backup
- `-f|--file <string>`: a file on the dokku host to import instead of reading stdin

Import a datastore dump:

```shell
dokku postgres:import lollipop < data.dump
```

A dump that is already on the dokku host can be imported with --file. The path is on the dokku host, not on the machine running ssh.

```shell
dokku postgres:import lollipop --file /var/lib/dokku/data/storage/data.dump
```

A dump of every database, as written by export --all-databases or a backup, is imported with --all-databases. Each database in the dump is replaced under the name it was exported from, and any other database is left alone.

```shell
dokku postgres:import lollipop --all-databases < all.dump
```

Arguments after -- are passed to the tool that loads the dump, in place of the import-args property:

```shell
dokku postgres:import lollipop -- <import-args...> < data.dump
```

The import-args property holds the arguments every import into the service is made with, a clone's included:

```shell
dokku postgres:set lollipop import-args -- "<import-args...>"
```

### export a dump of the Postgres service database

```shell
# usage
dokku postgres:export <service> [-f|--file <path>] [--force] [--all-databases] [-- <export-args...>]
```

flags:

- `--all-databases`: export every database in the service rather than only the one named for it
- `-f|--file <string>`: a file on the dokku host to export to instead of writing stdout
- `--force`: replace the file named with --file if it already exists

By default, datastore output is exported to stdout:

```shell
dokku postgres:export lollipop
```

You can redirect this output to a file:

```shell
dokku postgres:export lollipop > data.dump
```

A dump can be written to a file on the dokku host with --file. The path is on the dokku host, not on the machine running ssh.

```shell
dokku postgres:export lollipop --file /var/lib/dokku/data/storage/data.dump
```

A file that already exists is not overwritten unless --force is given:

```shell
dokku postgres:export lollipop --file /var/lib/dokku/data/storage/data.dump --force
```

Only the database named for the service is exported unless --all-databases is given, which exports every database in the service, leaving out the ones the server keeps for itself. It is imported again with import --all-databases, into the databases it was exported from.

```shell
dokku postgres:export lollipop --all-databases > all.dump
```

Arguments after -- are passed to the tool that makes the dump, in place of the export-args property:

```shell
dokku postgres:export lollipop -- <export-args...>
```

The export-args property holds the arguments every export, backup and clone of the service is made with:

```shell
dokku postgres:set lollipop export-args -- "<export-args...>"
```

Note that the export will result in a file containing the binary postgres export data. It can be converted to plain text using `pg_restore` as follows

```shell
pg_restore data.dump -f plain.sql
```

### delete all data in the Postgres service, keeping the service and its links

```shell
# usage
dokku postgres:reset <service> [-f|--force]
```

flags:

- `-f|--force`: reset the service without asking for its name first

Delete all data in the service, leaving it as empty as a newly created one. The service, its credentials, and the apps it is linked to are kept, so linked apps do not need to be relinked. Connections the apps hold open may be closed.

```shell
dokku postgres:reset lollipop
```

The service name is asked for before anything is deleted, unless --force is given:

```shell
dokku postgres:reset lollipop --force
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio) and [DigitalOcean Spaces](https://docs.digitalocean.com/products/spaces/).

The endpoint of an S3 compatible service is passed as the `endpoint-url` argument of `backup-auth`, such as `https://nyc3.digitaloceanspaces.com`, and must not include the bucket. The bucket is passed to `backup` and `backup-schedule` by its name alone, such as `my-s3-bucket` rather than `s3://my-s3-bucket`, and must follow the [S3 bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

If both passphrase and public key forms of encryption are set, the public key encryption will take precedence.

Backups are uploaded with the bucket's default storage class unless the service sets the `backup-storage-class` property with the `set` command.

Backups are uploaded to `<prefix>-<service>-<timestamp>.tgz`. The service may name the key with the `backup-object-name` property and drop the timestamp by setting the `backup-timestamp` property to `false`, so that every backup is uploaded to the same key and bucket versioning and lifecycle rules can keep and rotate them. The bucket name may end in a path to upload under, such as `my-s3-bucket/backups`.

The underlying core backup script is present [here](https://github.com/dokku/docker-s3backup/blob/main/backup.sh).

Scheduled backups are added to the dokku crontab, and are listed by `dokku cron:list --global`. Each service's scheduled backups append their output to a log of its own, `/var/log/dokku/<prefix>.<service>.backup.log`, which the `backup-logs` command shows. The output of a service's scheduled backups can be mailed to specific recipients by setting the `backup-mailto` property with the `set` command, on dokku versions that support a per-entry `MAILTO`.

Backups can be performed using the backup commands:

### set up authentication for backups on the Postgres service

```shell
# usage
dokku postgres:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

> NOTE: each call replaces the stored credentials as a whole, so a region, signature version or endpoint url that is not passed is removed

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

More specific example for digitalocean spaces auth, where the endpoint does not include the space name:

```shell
dokku postgres:backup-auth lollipop SPACES_ACCESS_KEY SPACES_SECRET_KEY nyc3 s3v4 https://nyc3.digitaloceanspaces.com
```

### remove backup authentication for the Postgres service

```shell
# usage
dokku postgres:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku postgres:backup-deauth lollipop
```

### create a backup of the Postgres service to an existing s3 bucket

```shell
# usage
dokku postgres:backup <service> <bucket-name> [-u|--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Backup the `lollipop` service to the `my-s3-bucket` bucket on `AWS`:

```shell
dokku postgres:backup lollipop my-s3-bucket --use-iam
```

Backup the `lollipop` service under a path in the bucket:

```shell
dokku postgres:backup lollipop my-s3-bucket/postgres-backups
```

A backup holds every database in the service, so it is restored with --all-databases (assuming it was extracted via `tar -xf backup.tgz`):

```shell
dokku postgres:import lollipop --all-databases < backup-folder/export
```

A backup made by an older version of the plugin holds only the database named for the service, and is restored without it:

```shell
dokku postgres:import lollipop < backup-folder/export
```

### set encryption for all future backups of Postgres service

```shell
# usage
dokku postgres:backup-set-encryption <service> <passphrase>
```

Set the GPG-compatible passphrase for encrypting backups for backups:

```shell
dokku postgres:backup-set-encryption lollipop
```

Public key encryption will take precendence over the passphrase encryption if both types are set.

### set GPG Public Key encryption for all future backups of Postgres service

```shell
# usage
dokku postgres:backup-set-public-key-encryption <service> <public-key-id>
```

Set the `GPG` Public Key for encrypting backups:

```shell
dokku postgres:backup-set-public-key-encryption lollipop
```

The <public-key-id> is fetched from `keyserver.ubuntu.com`, unless the service names another one with the backup-keyserver property:

```shell
dokku postgres:set lollipop backup-keyserver hkp://keys.example.com
```

### unset encryption for future backups of the Postgres service

```shell
# usage
dokku postgres:backup-unset-encryption <service>
```

Unset the `GPG` encryption passphrase for backups:

```shell
dokku postgres:backup-unset-encryption lollipop
```

### unset GPG Public Key encryption for future backups of the Postgres service

```shell
# usage
dokku postgres:backup-unset-public-key-encryption <service>
```

Unset the `GPG` Public Key encryption for backups:

```shell
dokku postgres:backup-unset-public-key-encryption lollipop
```

### schedule a backup of the Postgres service

```shell
# usage
dokku postgres:backup-schedule <service> <schedule> <bucket-name> [-u|--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am, or a descriptor such as "@daily". A schedule cron cannot run is refused.
> the backup is added to the dokku crontab through the cron-entries plugin trigger, so it is listed by "dokku cron:list --global" and its output is appended to /var/log/dokku/postgres.<service>.backup.log, which "dokku postgres:backup-logs <service>" prints
> NOTE: dokku only writes a crontab when the global scheduler or at least one app uses the docker-local scheduler, so a scheduled backup does not run on a host that only uses k3s or null

```shell
dokku postgres:backup-schedule lollipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku postgres:backup-schedule lollipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the crontab line of the scheduled backup for the service

```shell
# usage
dokku postgres:backup-schedule-cat <service>
```

Cat the crontab line of the scheduled backup for the service:

```shell
dokku postgres:backup-schedule-cat lollipop
```

### unschedule the backup of the Postgres service

```shell
# usage
dokku postgres:backup-unschedule <service>
```

Remove the scheduled backup from the dokku crontab:

```shell
dokku postgres:backup-unschedule lollipop
```

### print the most recent output of the scheduled backups of the service

```shell
# usage
dokku postgres:backup-logs <service> [-t|--tail [<tail-num>]]
```

flags:

- `-t|--tail <int>`: follow the log, optionally showing this many lines

Print the most recent output of the scheduled backups of the service:

> each service's scheduled backups append their output to /var/log/dokku/postgres.<service>.backup.log, or to the same file under DOKKU_LOGS_DIR when dokku keeps its logs elsewhere. Every run starts and ends with a line marked with the time in utc.

```shell
dokku postgres:backup-logs lollipop
```

By default, the log will not be tailed, but you can do this with the --tail flag:

```shell
dokku postgres:backup-logs lollipop --tail
```

By default the last 100 lines are shown, but a different count can be specified:

```shell
dokku postgres:backup-logs lollipop --tail=5
```

### Custom Commands

This datastore adds the following commands of its own:

### print the certificate the Postgres service encrypts connections with

```shell
# usage
dokku postgres:certificate <service>
```

Print the certificate the Postgres service encrypts connections with:

> NOTE: the service must be running

```shell
dokku postgres:certificate lollipop
```

Save it to verify the server from a client off the host:

```shell
dokku postgres:certificate lollipop > server.crt
```

### remove the data an upgrade across a major version kept aside

```shell
# usage
dokku postgres:upgrade-cleanup <service>
```

Remove the data an upgrade across a major version kept aside:

> NOTE: the service must be running

```shell
dokku postgres:upgrade-cleanup lollipop
```

### Limiting where and to whom a service is exposed

An exposed service's ports are published on every interface unless they are given an address of their own. To publish them on one address instead, set the service's `port-bind-address` property with `dokku postgres:set`, and to accept connections only from clients in one IP address or CIDR, set its `port-source-range` property. Either reaches a running service with `dokku postgres:reexpose`, which leaves the service running when its ports are published through an ambassador.

Only one source range can be given. The range is checked against the address a connection reaches the service from, which for a connection to the exposed port on the loopback interface, or an IPv6 connection to a service network without IPv6, is the docker network's gateway rather than the client, so with a range that leaves the gateway out, connecting to `127.0.0.1` from the dokku host itself is refused.

### Exposing a service without an ambassador

An exposed service's ports are published by an ambassador, a container that relays every connection on to the service. The ambassador can be replaced without touching the service and can hold clients to a `port-source-range`, but relaying adds latency to every request.

To publish the ports on the service container itself instead, set the service's `expose-mode` property to `direct` with `dokku postgres:set`. Docker has no way of changing the ports a container publishes, so the container is made again whenever what it publishes changes: when the service is exposed or unexposed, when its `port-bind-address` changes, and when it moves between expose modes. For a running service, `dokku postgres:expose`, `dokku postgres:unexpose` and `dokku postgres:reexpose` ask before stopping and starting it, and change nothing if the answer is no. Pass `--force` to stop and start it without being asked. A change also reaches the service the next time it is restarted, or stopped and started.

A `port-source-range` cannot be enforced on a port the service container publishes itself, so it cannot be set on a service exposed directly, and a service with one cannot be exposed directly.

### Connecting to an exposed service from outside the host

`dokku postgres:info lollipop --exposed-dsn` prints the dsn a client off the dokku host connects with. It is the dsn a linked app is handed, with the exposed ports in place of the container's and a public host in place of the service container's name, so it carries the same credentials. The host is the service's `expose-host` property, set with `dokku postgres:set`, or the first global domain when it has none. The `port-bind-address`, or an address given with a port, is never used as the host, since it is where the port is bound rather than where a client elsewhere reaches it. The dsn is empty until the service is exposed and there is a host to name.

### Passing extra arguments to export and import

Arguments given to `export` or `import` after `--` are appended to the ones the datastore's own tool is run with, for that run alone. To use them every time, set the service's `export-args` or `import-args` property with `dokku postgres:set`, giving the value after `--` so that its leading dash is not read as a flag. The property is split the way a shell would split it, so an argument with a space in it is quoted, and a variable in it is refused rather than expanded.

Arguments given after `--` replace the property rather than adding to it. Backups and clones are made with the property, and a clone is given the source's.

### Waiting for a service to become ready

A service is waited on until it answers on its port after it is created, cloned, started, restarted, upgraded or exposed. If it takes longer than that to start - on a slow host, or with an image that does more on its first boot - the command fails with `ERROR: unable to connect`.

To wait longer for every postgres service on the host, set the `POSTGRES_WAIT_TIMEOUT` environment variable to a number of seconds. To wait longer for a single service, set its `wait-timeout` property with `dokku postgres:set` or pass `--wait-timeout` to `create`, `clone` or `upgrade`. The service's own setting is used first, then the environment variable, then the datastore's default.

### Moving where a service's volumes are mounted

Each volume a service mounts is named by the directory it lives in under the service's own directory, and is mounted where the datastore's definition says. To mount one somewhere else in the container, for an image that keeps its data at another path, set the service's `volume-targets` property with `dokku postgres:set`, pass `--volume-target` to `create`, `clone` or `upgrade`, or set the `POSTGRES_VOLUME_TARGETS` environment variable before `create`. Each is written as `<volume>=<container-path>`, several separated by spaces, and `dokku postgres:info lollipop --volume-targets` shows the ones a service moved.

| Definition | Volume | Mounted at |
| --- | --- | --- |
| postgres-17 | data | `/var/lib/postgresql/data` |
| postgres-17 | certs | `/certs` |
| postgres-18 | data | `/var/lib/postgresql` |
| postgres-18 | certs | `/certs` |
| postgres-pgvector-pg17 | data | `/var/lib/postgresql/data` |
| postgres-pgvector-pg17 | certs | `/certs` |
| postgres-pgvector-pg18 | data | `/var/lib/postgresql` |
| postgres-pgvector-pg18 | certs | `/certs` |
| postgres-postgis-pg17 | data | `/var/lib/postgresql/data` |
| postgres-postgis-pg17 | certs | `/certs` |
| postgres-postgis-pg18 | data | `/var/lib/postgresql` |
| postgres-postgis-pg18 | certs | `/certs` |
| postgres-timescaledb-pg17 | data | `/var/lib/postgresql/data` |
| postgres-timescaledb-pg17 | certs | `/certs` |
| postgres-timescaledb-pg18 | data | `/var/lib/postgresql` |
| postgres-timescaledb-pg18 | certs | `/certs` |

Moving a volume changes where it is mounted, not where the image reads and writes. The datastore's own commands and the paths it is started with follow the volume, but an image that keeps writing to its own path writes into the container rather than into the volume, and what it writes is lost when the container is rebuilt, so only move a volume to where the image expects its data. The data stays in the same directory on the host, and a move reaches the container the next time one is built, so use `dokku postgres:stop` and then `dokku postgres:start` on a running service. An upgrade onto a definition that does not mount a volume the service moved is refused until the move is cleared or replaced.

### Reserved service names

A service's database is named after the service, with hyphens replaced by underscores. So that an app is never handed a database Postgres keeps for itself, `dokku postgres:create` and `dokku postgres:clone` refuse a name that is, or whose database would be, one of `template0`, `template1`, in any case. A service that already has such a name is not affected.

### Encrypting connections with TLS

Every Postgres service is created with a self-signed certificate, and the server encrypts any connection whose client asks it to. The certificate and its key are kept in `/var/lib/dokku/services/postgres/lollipop/certs`, and are kept when the service is rebuilt or upgraded. Clients such as psql ask for an encrypted connection by default, but fall back to an unencrypted one when the server does not offer it. To refuse an unencrypted connection instead, add `sslmode=require` to the dsn the service is exposed at:

```shell
dokku postgres:info lollipop --exposed-dsn
```

```
postgres://postgres:PASSWORD@db.example.com:5432/lollipop?sslmode=require
```

To also check that the client is talking to this service, save its certificate and have the client verify the server with it. The certificate names no host, so `sslmode=verify-ca` works where `sslmode=verify-full` does not:

```shell
dokku postgres:certificate lollipop > server.crt
```

```
postgres://postgres:PASSWORD@db.example.com:5432/lollipop?sslmode=verify-ca&sslrootcert=server.crt
```

To use a certificate of your own, write it and its key over the ones the service was created with as root, and restart the service. Writing over the files rather than replacing them keeps the owner and mode the server needs to read its key:

```
sudo sh -c 'cat server.crt > /var/lib/dokku/services/postgres/lollipop/certs/server.crt'
sudo sh -c 'cat server.key > /var/lib/dokku/services/postgres/lollipop/certs/server.key'
```

```shell
dokku postgres:restart lollipop
```

### Choosing the database encoding and locale

The database is made the first time the service starts, with the encoding and locale of its container, which are utf8 and `en_US.utf8` unless the custom environment says otherwise. A custom environment that only sets `LC_ALL=C` leaves the database in the `SQL_ASCII` encoding, which stores bytes rather than utf8 text. To choose both, give the arguments `initdb` takes in `POSTGRES_INITDB_ARGS` when the service is created:

```shell
dokku postgres:create lollipop --custom-env "POSTGRES_INITDB_ARGS=--encoding=UTF8 --locale=C"
```

They are only read when the data directory is first made, so changing the custom environment of an existing service leaves its database as it was. To move a database to another encoding or locale, create a service with the new ones and import an export of the old service into it:

```shell
dokku postgres:export lollipop > lollipop.dump
dokku postgres:create lollipop-utf8 --custom-env "POSTGRES_INITDB_ARGS=--encoding=UTF8 --locale=C"
dokku postgres:import lollipop-utf8 < lollipop.dump
```

### Upgrading across a major version

An upgrade that moves a service to another major version, or onto another flavor, carries its data across rather than mounting it where the new version would not read it. The linked apps are stopped while the data is copied, so the upgrade has to be given `--restart-apps`:

```shell
dokku postgres:upgrade lollipop --definition postgres-18 --restart-apps
```

From 17 to 18 on the official image the data is copied with `pg_upgrade`, which needs as much free disk as the data takes up. Every other move exports every database and role from the old version with `pg_dumpall` and replays it into the new one. A move that fails puts the service back on the version it ran, with the data it had. The old data is kept in a `data.<definition>.<timestamp>` directory beside the service's data, and is removed once the upgrade is confirmed:

```shell
dokku postgres:upgrade-cleanup lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `POSTGRES_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
