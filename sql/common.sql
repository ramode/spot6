CREATE DATABASE spot6;
CREATE ROLE admin;
ALTER ROLE admin WITH SUPERUSER INHERIT CREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md55e6fba03d6bab1e5b653f662009a4cf5'; 
-- password 'admin'

grant ALL on DATABASE spot6 to admin ;
\c spot6
create extension pgcrypto ;

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
	password varchar,
	parent integer default 0 not null
		constraint users_parent_fk
			references common.users
				on delete set default,
	"group" integer default 0 not null
		constraint users_group_fk
			references common.users
				on delete set default
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

alter table common.users
	add deleted bool default false not null;

INSERT INTO common.users (id, login, label, email, phone, password, parent, "group", deleted) VALUES (0, 'root', 'Рут', 'me@eri.su', '+79158327039', 'ghpass', 0, 0, false);