CREATE USER tester WITH PASSWORD 'pivotal' SUPERUSER;
CREATE DATABASE testdb WITH OWNER tester;
CREATE USER guest WITH PASSWORD 'guest';
CREATE DATABASE guest WITH OWNER guest;