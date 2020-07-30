CREATE SCHEMA adapter;

CREATE JAVA ADAPTER SCRIPT adapter.jdbc_adapter AS
 %scriptclass com.exasol.adapter.jdbc.JdbcAdapter;
 %jar /buckets/bfsdefault/default/virtual-schema-jdbc-adapter-4.0.2.jar;
/