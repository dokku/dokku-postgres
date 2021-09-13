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
