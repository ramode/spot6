create table common.settings
(
	id integer not null
		constraint settings_pk
			primary key,
	autoreg_enabled boolean default true not null,
	autoreg_role pg_roles
);

comment on table common.settings is 'настройки для админа';



alter table common.settings alter column id set default (current_setting('request.jwt.claim.uid'::text, true))::integer ;


create table common.tokens
(
	id int default (current_setting('request.jwt.claim.uid'::text, true))::integer not null,
	expires timestamp not null,
	serial bigserial not null,
	user_agent varchar,
	ip inet
);



