# Docker Image with HSQLDB for Software Development.

Installed Software:

  * Java 8
  * HSQLDB
  * SQLTool


`
docker pull datagrip/hsqldb:2.0.0
docker run -d -p 9001:9001 --name hsqldb datagrip/hsqldb:2.0.0
`

Will run hsqldb which will be accessible through jdbc URL: jdbc:hsqldb:hsql://localhost/test, Username: sa, Password :
