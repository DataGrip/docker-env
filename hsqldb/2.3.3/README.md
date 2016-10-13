# Docker Image with HSQLDB for Software Development.

Installed Software:

  * Java 8
  * HSQLDB
  * SQLTool


`
docker pull chernov/hsqldb:2.3.3
docker run -d -p 9001:9001 --name hsqldb chernov/hsqldb:2.3.3
`

Will run hsqldb which will be accessible through jdbc URL: jdbc:hsqldb:hsql://localhost/test, Username: sa, Password :
