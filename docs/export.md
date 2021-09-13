Note that the export will result in a file containing the binary postgres export data. It can be converted to plain text using `pg_restore` as follows

```shell
pg_restore data.dump -f plain.sql
```
