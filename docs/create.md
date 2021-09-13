Official Postgres docker images does not include postgis extension (amongst others). The following example creates a new postgres service using `postgis/postgis:13-3.1` image, which includes the `postgis` extension.

```shell
dokku postgres:create postgis-database --image "postgis/postgis" --image-version "13-3.1"
```
