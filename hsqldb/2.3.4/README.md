#Docker Image with HSQLDB for Software Development.
Based on java:8-alpine

Installed Software:

  * Java 8
  * HSQLDB
  * SQLTool

`docker pull datagrip/hsqldb:2.3.4`

`docker run -d -p 9001:9001 --name hsqldb datagrip/hsqldb:2.3.4`

Will run hsqldb which will be accessible through jdbc URL: jdbc:hsqldb:hsql://localhost/test, Username: sa, Password :
Available environment variables:

  * JAVA_VM_PARAMETERS (default: "-Dfile.encoding=UTF-8")
  * HSQLDB_USER (default: "sa")
  * HSQLDB_PASSWORD (default: ""(empty password))
  * HSQLDB_TRACE (default: "-trace true")
  * HSQLDB_SILENT (default: "-silent false")
  * HSQLDB_REMOTE (default: "-remote_open true")
  * HSQLDB_DATABASE_NAME (default: "hsqldb")
  * HSQLDB_DATABASE_ALIAS (default: "test")
  * HSQLDB_DATABASE_HOST (default: "localhost")

