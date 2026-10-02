### Sybase 16.2
Based on nguoianphu/docker-sybase
Needs about 30 seconds after start for correct initialization

#### Environment Variables

##### Guest user
Environment variable | Default value
--- | --- 
SYBASE_USER | tester 
SYBASE_PASSWORD | guest1234 
SYBASE_DB | testdb

##### Capacity for large tables and transactions

Environment variable | Default value | Description
--- | --- | ---
SYBASE_DATA_SIZE_MB | 2048 | Data device and database data size in MiB
SYBASE_LOG_SIZE_MB | 1024 | Separate transaction log device size in MiB
SYBASE_NUMBER_OF_LOCKS | 50000 | Server-wide lock pool size

These settings apply when initializing a fresh container. Data and log files are created in `/opt/sybase/data`.
Increasing the lock pool also requires additional ASE memory.

Size the log for the largest active transaction, including index changes.
`trunc log on chkpt` does not free log records belonging to active transactions.
For large imports, commit in batches (for example, 1000 rows per transaction)
or use `bcp`. The row count alone does not determine the required capacity.
The existing automatic log truncation setting is intended for test databases,
not for a transaction-log backup/recovery chain.

```bash
docker run -d -p 5000:5000 \
  -e SYBASE_DATA_SIZE_MB=4096 \
  -e SYBASE_LOG_SIZE_MB=2048 \
  -e SYBASE_NUMBER_OF_LOCKS=100000 \
  datagrip/sybase162
```

##### Admin user
Environment variable | Default value
--- | --- 
SYBASE_USER | sa
SYBASE_PASSWORD | myPassword

Create container
```bash
docker run -d -t -p 5000:5000 datagrip/sybase162
```



See also: http://www.petersap.nl/SybaseWiki/index.php/Docker_-_How_to_run_Sybase_ASE_in_a_container
