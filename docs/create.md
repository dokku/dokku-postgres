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
