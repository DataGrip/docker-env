#!/bin/bash

source ${SETUPDIR?}/include/db2_constants
source ${SETUPDIR?}/include/db2_common_functions

enable_explain_plan()
{
    echo "(*) Enabling explain plan feature"
    su - ${DB2INSTANCE?} -c "db2 connect to ${DBNAME?} && db2 -f /var/custom/init.sql"
}

create_buffer_pool()
{
    echo "(*) Creating buffer pool and table space"
    su - ${DB2INSTANCE?} -c "db2 connect to ${DBNAME?} && db2 -f /var/custom/initspatial.sql"
}

enable_spatial_operations()
{
    echo "(*) Enabling spatial operations feature"
    su - ${DB2INSTANCE?} -c "/opt/ibm/db2/V11.1/bin/db2se enable_db ${DBNAME?}"
}

enable_explain_plan
create_buffer_pool
enable_spatial_operations