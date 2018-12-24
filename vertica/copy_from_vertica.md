* docker-compose up -d vertica81 vertica91

* Connect to Vertica81 with DG with dbadmin (no password)

* Get gateway to create proper subnet:
```$docker inspect $(docker ps | grep vertica91 | awk '{print $1}') --format='{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}'```

`172.18.0.1`

* Get ip for vertica 81 & vertica91:
```$docker inspect $(docker ps | grep vertica81 | awk '{print $1}') --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'```

`172.18.0.2`

```$docker inspect $(docker ps | grep vertica91 | awk '{print $1}') --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'```

`172.18.0.3`


* Go to vertica81 and execute in db console:

```sql
CREATE SUBNET mySubnet WITH '172.18.0.0';
```

```sql
CREATE NETWORK INTERFACE mynetwork ON v_testdb_node0001 WITH '172.18.0.2';
```

* Get node name:
```sql
SELECT * FROM nodes;
```
`v_testdb_node0001 | ...`

```sql
ALTER DATABASE testdb EXPORT ON mySubnet;
ALTER NODE v_testdb_node0001 export on mynetwork;
```

* Go to vertica91 and execute in db console:

```sql
CREATE SUBNET mySubnet WITH '172.18.0.0';
CREATE NETWORK INTERFACE mynetwork ON v_testdb_node0001 WITH '172.18.0.3';
```

* Get node name:
```sql
SELECT * FROM nodes;
```
`v_testdb_node0001 | ...`

```sql
ALTER DATABASE testdb EXPORT ON mySubnet;
ALTER NODE v_testdb_node0001 export on mynetwork;
```

* Create test_table in vertica81 & vertica91. Fill test_table in vertica91 with some data.

* Go to vertica81 db console:
```sql

CONNECT TO VERTICA testdb USER dbadmin PASSWORD '' ON '172.18.0.3',5433;

COPY test_table FROM VERTICA testdb.test_table;

DISCONNECT testdb;
```
