#!/bin/bash

source ${SETUPDIR?}/include/db2_constants
source ${SETUPDIR?}/include/db2_common_functions

enable_explain_plan()
{
    echo "(*) Enabling explain plan feature"
    su - ${DB2INSTANCE?} -c "db2 connect to ${DBNAME?} && db2 -f /var/sql/init.sql"
}

create_buffer_pool()
{
    echo "(*) Creating buffer pool and table space"
    su - ${DB2INSTANCE?} -c "db2 connect to ${DBNAME?} && db2 -f /var/sql/initspatial.sql"
}

enable_spatial_operations()
{
    echo "(*) Enabling spatial operations feature"
    su - ${DB2INSTANCE?} -c "/opt/ibm/db2/V12.1/bin/db2se enable_db ${DBNAME?}"
}

start_server_listener()
{
    echo "(*) Restarting Db2 server's listener"
    su - ${DB2INSTANCE?} -c "
    db2set db2comm=tcpip
    db2 'update DBM CFG using SVCENAME 50000'
    db2stop
    db2start"
}

enable_explain_plan
create_buffer_pool
enable_spatial_operations
start_server_listener