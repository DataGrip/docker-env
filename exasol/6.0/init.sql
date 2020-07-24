CREATE SCHEMA adapter;

CREATE JAVA ADAPTER SCRIPT adapter.jdbc_adapter AS
 %scriptclass com.exasol.adapter.jdbc.JdbcAdapter;
 %jar /buckets/bfsdefault/default/virtualschema-jdbc-adapter-dist-0.0.1-SNAPSHOT.jar;
/