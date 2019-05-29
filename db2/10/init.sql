create database guest @
connect to guest user guest using guest @
-- connect as db2inst1
connect to guest @
-- force SYSTOOLS schema creation
BEGIN
  DECLARE tmp INT;
  CALL SYSPROC.DB2LK_GENERATE_DDL('-e -t sysibm.sysdummy1', tmp);
END @
GRANT DATAACCESS ON DATABASE TO USER guest @
CALL SYSPROC.SYSINSTALLOBJECTS('EXPLAIN', 'C', 
        CAST (NULL AS VARCHAR(128)), CAST (NULL AS VARCHAR(128))) @
