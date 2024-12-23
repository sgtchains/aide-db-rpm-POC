DROP DATABASE IF EXISTS fim;
DROP ROLE IF EXISTS aide;
DROP ROLE IF EXISTS puppet;
DROP ROLE IF EXISTS rpm;
DROP ROLE IF EXISTS fim_users;
DROP ROLE IF EXISTS fim_query_tables;
DROP ROLE IF EXISTS fim_database;
CREATE DATABASE fim;

CREATE EXTENSION IF NOT EXISTS pg_repack WITH SCHEMA public;
COMMENT ON EXTENSION pg_repack IS 'Reorganize tables in PostgreSQL databases with minimal locks';

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

CREATE ROLE fim_database;
ALTER ROLE fim_database WITH NOSUPERUSER INHERIT CREATEROLE CREATEDB NOLOGIN NOREPLICATION;

SET ROLE fim_database;

CREATE ROLE fim_query_tables;
ALTER ROLE fim_query_tables WITH INHERIT NOCREATEROLE NOCREATEDB NOLOGIN;

CREATE ROLE fim_users;
ALTER ROLE fim_users WITH INHERIT NOCREATEROLE NOCREATEDB NOLOGIN;

CREATE ROLE aide;
ALTER ROLE aide WITH INHERIT NOCREATEROLE NOCREATEDB LOGIN PASSWORD 'md5ff7cd8c3e58b57297921d763ffd2bbe6';
GRANT fim_users TO aide;

CREATE ROLE puppet;
ALTER ROLE puppet WITH INHERIT NOCREATEROLE NOCREATEDB LOGIN PASSWORD 'md5ff7cd8c3e58b57297921d763ffd2bbe6';
GRANT fim_users TO puppet;

CREATE ROLE rpm;
ALTER ROLE puppet WITH INHERIT NOCREATEROLE NOCREATEDB LOGIN PASSWORD 'md5ff7cd8c3e58b57297921d763ffd2bbe6';
GRANT fim_users TO rpm;

ALTER ROLE fim_database WITH NOCREATEDB;
ALTER ROLE fim_database WITH NOCREATEROLE;



