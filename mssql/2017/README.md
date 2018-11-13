Built on top of mssql-server-linux container
https://hub.docker.com/r/microsoft/mssql-server-linux/

##### To build docker image:

`docker build --no-cache -t datagrip/mssql-server-linux .`

##### To run:

`docker run --privileged -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=yourStrong123Password' -p 1433:1433 -d datagrip/mssql-server-linux`

System adminitrator login `sa`

System administrator password: `$SA_PASSWORD`

##### Environment variables:

`$MSSQL_DB=testdb`

```
$MSSQL_USER=tester 
#login is the same as $MSSQL_USER and ROLE is sysadmin
```

`$MSSQL_PASSWORD=My@Super@Secret`

##### Init script:
```sql
CREATE DATABASE $MSSQL_DB;
GO

USE $MSSQL_DB;
GO

CREATE LOGIN $MSSQL_USER WITH PASSWORD = '$MSSQL_PASSWORD';
GO

CREATE USER $MSSQL_USER FOR LOGIN $MSSQL_USER;
GO

ALTER SERVER ROLE sysadmin ADD MEMBER [$MSSQL_USER];
GO
```