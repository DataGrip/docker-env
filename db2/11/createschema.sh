#!/bin/bash

source ${SETUPDIR?}/include/db2_constants
source ${SETUPDIR?}/include/db2_common_functions

enable_explain_plan()
{
    echo "(*) Enabling explain plan feature"
    su - ${DB2INSTANCE?} -c "db2 connect to ${DBNAME?} && db2 -f /var/custom/init.sql"
}

enable_explain_plan