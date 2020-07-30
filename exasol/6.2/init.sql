CREATE SCHEMA SCHEMA_FOR_VS_SCRIPT;

CREATE JAVA ADAPTER SCRIPT SCHEMA_FOR_VS_SCRIPT.JDBC_ADAPTER_SCRIPT AS
  %scriptclass com.exasol.adapter.RequestDispatcher;
  %jar /buckets/your-bucket-fs/your-bucket/virtual-schema-dist-5.0.2-bundle-4.0.2.jar;
  %jar /buckets/bfsdefault/default/virtual-schema-jdbc-adapter-4.0.2.jar;
/