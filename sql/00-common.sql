CREATE DATABASE spot6;

\c spot6

CREATE ROLE authenticator;
ALTER ROLE authenticator WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;
ALTER USER authenticator WITH PASSWORD 'pass123';

CREATE ROLE dba;
ALTER ROLE dba WITH SUPERUSER NOINHERIT CREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;

ALTER USER dba WITH PASSWORD 'adminpass';
grant ALL on DATABASE spot6 TO dba;

create extension pgcrypto ;


CREATE ROLE super;
ALTER ROLE super WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE admin;
ALTER ROLE admin WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE manager;
ALTER ROLE manager WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE guest;
ALTER ROLE guest WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE anon;
ALTER ROLE anon WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;

GRANT super TO authenticator;
GRANT admin TO authenticator;
GRANT manager TO authenticator;
GRANT guest TO authenticator;
GRANT anon TO authenticator;

create type common.roles_type as enum ('super', 'admin', 'manager', 'guest');

create table common.users
(
	id serial not null
		constraint users_pk
			primary key,
	login varchar
		constraint users_login
			unique,
	label varchar default 'Пользователь'::varchar not null,
	email varchar,
	phone varchar,
	password varchar default '' not null,
	parent integer default 0 not null
		constraint users_parent_fk
			references common.users
				on delete set default,
	"group" integer default 0 not null
		constraint users_group_fk
			references common.users
				on delete set default,
	deleted  boolean             default false not null,
        roles    common.roles_type default 'guest'::common.roles_type not null
);

comment on table common.users is 'пользователи продукта, админы';

alter table common.users owner to admin;

create unique index users_login_uindex
	on common.users (login);

create function common.encrypt_pass() returns trigger
    language plpgsql
as
$$
begin

  if tg_op = 'INSERT' or ( new.password IS NOT NULL and new.password <> '' and new.password <> old.password )then
    new.password = public.crypt(new.password, public.gen_salt('bf'));
  else
    new.password = old.password;
  end if;
  return new;
end
$$;

create trigger encrypt_pass
    before insert or update
    on common.users
    for each row
execute procedure common.encrypt_pass();

INSERT INTO common.users (id, login, label, email, phone, password, parent, "group", deleted) VALUES (0, 'root', 'Рут', 'me@eri.su', '+79158327039', 'ghpass', 0, 0, false);


create view "api".user_groups(label, id) as
SELECT users.label,
       users.id
FROM "common".users
WHERE ((users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR
       (users.parent = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR
       (users.id = (current_setting('request.jwt.claim.gid'::text, true))::integer));


create view "api".user_users as
WITH RECURSIVE r AS (
SELECT users.*
FROM "common".users
   WHERE ((users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR
       (users.parent = (current_setting('request.jwt.claim.uid'::text, true))::integer))

   UNION

   SELECT users.*
   FROM "common".users
      JOIN r
          ON users.parent = r.id
) select * from r;


alter table common.users alter column parent set default (current_setting('request.jwt.claim.uid'::text, true))::integer;
alter table common.users alter column "group" set default (current_setting('request.jwt.claim.gid'::text, true))::integer;
