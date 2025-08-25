alter session set "_ORACLE_SCRIPT"=true
/
create user Test_User identified by test
                    default tablespace users
                    temporary tablespace temp
                    quota unlimited on users
/

grant connect, development
    to Test_User with admin option
/

grant debug connect session
    to Test_User
/

create user Test_Admin identified by test
                    default tablespace users
                    temporary tablespace temp
                    quota unlimited on users
/

grant connect, development
    to Test_Admin with admin option
/

grant select any dictionary, debug connect session, debug any procedure
    to Test_Admin
/

grant select_catalog_role
    to Test_Admin
/

grant execute on sys.dbms_Lock
    to Test_User
/

grant execute on sys.dbms_Lock
    to Test_Admin
/exit;
