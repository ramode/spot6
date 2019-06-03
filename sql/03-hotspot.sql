create table hotspot.hotspot_profile
(
	name varchar default 'server1' not null,
	"group" int default (current_setting('request.jwt.claim.gid'::text, true))::integer not null
		constraint hotspot_profile_group_pk
			unique
		constraint hotspot_profile_users_id_fk
			references "common".users (id)
				on delete set null,
	label varchar default 'Профиль',
	skin varchar default 'default' not null,
	session_time interval default '23:59:59'::interval,
	data_rate int default 5000000,
	port_limit int,
	redirect_url varchar,
	ad_url varchar,
	filter_id varchar,
	auth_methods varchar[]
);

comment on column hotspot.hotspot_profile.skin is 'folder in skins';

comment on column hotspot.hotspot_profile.data_rate is 'bit/s';

create unique index hotspot_profile_name_uindex
	on hotspot.hotspot_profile (name);

alter table hotspot.hotspot_profile
	add constraint hotspot_profile_name_pk
		unique (name);


