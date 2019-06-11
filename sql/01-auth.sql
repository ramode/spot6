create table common.users
(
    id       serial                                                                          not null
        constraint users_pk
            primary key,
    login    varchar
        constraint users_login
            unique,
    label    varchar default 'Пользователь'::character varying,
    email    varchar,
    phone    varchar,
    password varchar,
    parent   integer default (current_setting('request.jwt.claim.uid'::text, true))::integer not null
        constraint users_parent_fk
            references common.users
            on delete set default,
    "group"  integer default (current_setting('request.jwt.claim.gid'::text, true))::integer not null
        constraint users_group_fk
            references common.users
            on delete set default,
    deleted  boolean default false                                                           not null,
    disabled  boolean default false                                                           not null,
    role     name    default 'guest'::name                                                   not null
);

comment on table common.users is 'пользователи продукта, админы';


create unique index users_login_uindex
    on common.users (login);


CREATE TYPE common.jwt_token AS (
  token text
);




create view "api".user_groups(label, id) as
SELECT users.label,
       users.id
FROM "common".users
WHERE ((users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR
       (users.parent = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR
       (users.id = (current_setting('request.jwt.claim.gid'::text, true))::integer));


create view "api".user_users(id, login, label, email, phone, password, parent, "group", deleted, role) as
    WITH RECURSIVE r AS (
        SELECT users.id,
               users.login,
               users.label,
               users.email,
               users.phone,
               users.parent,
               users."group",
               users.deleted,
               users.disabled,
               users.role
        FROM common.users
        WHERE ((users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR
               (users.parent = (current_setting('request.jwt.claim.uid'::text, true))::integer))
        UNION
        SELECT users.id,
               users.login,
               users.label,
               users.email,
               users.phone,
               users.parent,
               users."group",
               users.deleted,
               users.disabled,
               users.role
        FROM (common.users
                 JOIN r r_1 ON ((users.parent = r_1.id)))
    )
    SELECT r.id,
           r.login,
           r.label,
           r.email,
           r.phone,
           r.parent,
           r."group",
           r.disabled,
           r.role
    FROM r where r.deleted = false;


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


INSERT INTO common.users (id, login, label, email, phone, password, parent, "group", deleted, role) VALUES (0, 'root', 'Рут', 'me@eri.su', '+79158327039', 'ghpass', 0, 0, false, 'super'::name);
