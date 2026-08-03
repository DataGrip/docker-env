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
