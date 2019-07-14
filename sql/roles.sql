--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE admin;
ALTER ROLE admin WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md549088b3a87b8ce56ecd39259d17ff834';
CREATE ROLE agents;
ALTER ROLE agents WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE authenticator;
ALTER ROLE authenticator WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md502b7df19a04089856a67eb7f1b5a3af2';
CREATE ROLE backend;
ALTER ROLE backend WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE dba;
ALTER ROLE dba WITH SUPERUSER NOINHERIT CREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md56ff9b44749b6224cf1f62d54f8c7726e';
CREATE ROLE guest;
ALTER ROLE guest WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE manager;
ALTER ROLE manager WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md5d370c5644aa8e06556212cf6ec2fd466';
CREATE ROLE radius;
ALTER ROLE radius WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5ccac0f31d41e99d19a7c38ac6c93b739';
CREATE ROLE super;
ALTER ROLE super WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE web_anon;
ALTER ROLE web_anon WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;


--
-- Role memberships
--

GRANT admin TO authenticator GRANTED BY postgres;
GRANT agents TO authenticator GRANTED BY postgres;
GRANT backend TO authenticator GRANTED BY postgres;
GRANT manager TO authenticator GRANTED BY postgres;
GRANT super TO authenticator GRANTED BY postgres;
GRANT web_anon TO authenticator GRANTED BY postgres;


--
-- PostgreSQL database cluster dump complete
--
