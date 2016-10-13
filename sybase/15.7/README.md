### Sybase 15.7
Based on ifnazar/sybase_15_7
Needs about 30 seconds after start for correct initialization

#### Environment Variables

##### Guest user
Environment variable | Default value
--- | --- 
SYBASE_USER | guest 
SYBASE_PASSWORD | guest1234 
SYBASE_DB | guest

##### Admin user
Environment variable | Default value
--- | --- 
SYBASE_USER | sa
SYBASE_PASSWORD | password


Create container
```bash
docker run -d -t -p 5000:5000 -e "SYBASE_USER=guest" -h dksybase --name sybase157 chernov/sybase:latest
```

Install pubs2 test database
```
docker exec -t sybase157 /bin/bash /sybase/isql -i"/opt/sybase/ASE-15_0/scripts/installpubs2"
```
