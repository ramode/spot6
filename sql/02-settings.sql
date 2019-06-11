create table common.settings
(
	id integer default (current_setting('request.jwt.claim.uid'::text, true))::integer not null
		constraint settings_pk
		references common.users
			primary key,

	reg_users boolean default true not null,
	reg_as_enabled boolean default false not null,
	reg_role name,
	session_time interval default '23:59:59'
);

comment on table common.settings is 'настройки для админа';




