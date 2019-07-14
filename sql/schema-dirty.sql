--
-- PostgreSQL database dump
--

-- Dumped from database version 11.4 (Debian 11.4-1.pgdg90+1)
-- Dumped by pg_dump version 11.3 (Debian 11.3-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: spot6; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE spot6 WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'ru_RU.UTF-8' LC_CTYPE = 'ru_RU.UTF-8';


ALTER DATABASE spot6 OWNER TO postgres;

\connect spot6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: spot6; Type: DATABASE PROPERTIES; Schema: -; Owner: postgres
--

ALTER DATABASE spot6 SET "app.jwt_secret" TO '2T4lpv9zE8DNx+j1Gexsc3FW+Zk81T86segOcVJIg9M=';


\connect spot6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: api; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO postgres;

--
-- Name: common; Type: SCHEMA; Schema: -; Owner: dba
--

CREATE SCHEMA common;


ALTER SCHEMA common OWNER TO dba;

--
-- Name: hotspot; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hotspot;


ALTER SCHEMA hotspot OWNER TO postgres;

--
-- Name: radius; Type: SCHEMA; Schema: -; Owner: dba
--

CREATE SCHEMA radius;


ALTER SCHEMA radius OWNER TO dba;

--
-- Name: web; Type: SCHEMA; Schema: -; Owner: dba
--

CREATE SCHEMA web;


ALTER SCHEMA web OWNER TO dba;

--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA public;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: jwt_token; Type: TYPE; Schema: common; Owner: postgres
--

CREATE TYPE common.jwt_token AS (
	token text
);


ALTER TYPE common.jwt_token OWNER TO postgres;

--
-- Name: roles_type; Type: TYPE; Schema: common; Owner: dba
--

CREATE TYPE common.roles_type AS ENUM (
    'super',
    'admin',
    'manager',
    'guest'
);


ALTER TYPE common.roles_type OWNER TO dba;

--
-- Name: nastype; Type: TYPE; Schema: hotspot; Owner: dba
--

CREATE TYPE hotspot.nastype AS ENUM (
    'routeros',
    'keenetic',
    'coova-chilli'
);


ALTER TYPE hotspot.nastype OWNER TO dba;

--
-- Name: chpassw(text, text); Type: FUNCTION; Schema: api; Owner: dba
--

CREATE FUNCTION api.chpassw(oldpassword text, newpassword text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
    update common.users set users.password = newpassword where users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer and
      users.password = public.crypt(oldpassword, users.password);
    return true;
end
$$;


ALTER FUNCTION api.chpassw(oldpassword text, newpassword text) OWNER TO dba;

--
-- Name: login(character varying, character varying); Type: FUNCTION; Schema: api; Owner: dba
--

CREATE FUNCTION api.login(username character varying, password character varying) RETURNS common.jwt_token
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
    return common.login(username,password);
end
$$;


ALTER FUNCTION api.login(username character varying, password character varying) OWNER TO dba;

--
-- Name: passwd(integer, text); Type: FUNCTION; Schema: api; Owner: dba
--

CREATE FUNCTION api.passwd(user_id integer, newpassword text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
    update common.users set password = passwd.newpassword where id = user_id and id in (select id from common.users_tree);
    
    -- id in (select id from common.users_tree); переместить на row security
    
    return true;
end
$$;


ALTER FUNCTION api.passwd(user_id integer, newpassword text) OWNER TO dba;

--
-- Name: refresh(); Type: FUNCTION; Schema: api; Owner: dba
--

CREATE FUNCTION api.refresh() RETURNS common.jwt_token
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _user record;
  _payload record;
  result common.jwt_token;
begin
  -- check email and password
  select users.* , settings.session_time from common.users LEFT OUTER JOIN common.settings ON (users.id = settings.id) where
    users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer AND users.disabled = false
    into _user;
  if _user.role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  if _user.session_time is null then
    _user.session_time = '1:00:00'::interval;
  end if;

  select _user.role as role, _user.id as uid, _user.group_id as gid,(current_setting('request.jwt.claim.seq'::text, true))::integer as seq,
         extract(epoch from (now() + _user.session_time ))::integer as exp into _payload;

  select public.sign(
      row_to_json(_payload), current_setting('app.jwt_secret')
    ) as token
    into result;
  return result;
end
$$;


ALTER FUNCTION api.refresh() OWNER TO dba;

--
-- Name: refresh(integer); Type: FUNCTION; Schema: api; Owner: dba
--

CREATE FUNCTION api.refresh(group_id integer) RETURNS common.jwt_token
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _user record;
  _payload record;
  result common.jwt_token;
begin
  -- check email and password
  select users.* , settings.session_time from common.users LEFT OUTER JOIN common.settings ON (users.id = settings.id) where
    users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer AND users.disabled = false
    into _user;
  if _user.role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  if _user.session_time is null then
    _user.session_time = '1:00:00'::interval;
  end if;

  select _user.role as role, _user.id as uid, group_id as gid,(current_setting('request.jwt.claim.seq'::text, true))::integer as seq,
         extract(epoch from (now() + _user.session_time ))::integer as exp into _payload;

  select public.sign(
      row_to_json(_payload), current_setting('app.jwt_secret')
    ) as token
    into result;
  return result;
end
$$;


ALTER FUNCTION api.refresh(group_id integer) OWNER TO dba;

--
-- Name: reg(character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION api.reg(login character varying, pass character varying, reg_secret character varying, email character varying DEFAULT NULL::character varying, phone character varying DEFAULT NULL::character varying) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  _settings record;
  _new_id integer;
begin

		select * from common.settings where settings.reg_secret = reg.reg_secret and settings.reg_enabled = TRUE limit 1 into _settings;
	
	    if _settings.id isnull then
            raise exception 'Error during registration (mf)';
        end if;
	
		insert into common.users (login, password, role, disabled, label, parent, email, phone)
 			values (login, pass, _settings.reg_role, _settings.reg_activation_needed, login||' (self-reged)', _settings.id, email, phone)
 			returning id into _new_id;


        update hotspot.auth_types set group_ids = array_append(group_ids, _new_id) where auth_types.id = any( _settings.reg_auth_types);

		return _settings.reg_activation_needed;


end
$$;


ALTER FUNCTION api.reg(login character varying, pass character varying, reg_secret character varying, email character varying, phone character varying) OWNER TO postgres;

--
-- Name: user(); Type: FUNCTION; Schema: api; Owner: dba
--

CREATE FUNCTION api."user"(OUT profile record, OUT role character varying, OUT group_id integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin

        select * from api.user_profile limit 1 into profile;
        role = (current_setting('request.jwt.claim.role'::text, true));
        group_id = (current_setting('request.jwt.claim.gid'::text, true))::integer;
        return;
    end
$$;


ALTER FUNCTION api."user"(OUT profile record, OUT role character varying, OUT group_id integer) OWNER TO dba;

--
-- Name: encrypt_pass(); Type: FUNCTION; Schema: common; Owner: postgres
--

CREATE FUNCTION common.encrypt_pass() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin

  if tg_op = 'INSERT' or ( new.password IS NOT NULL and new.password <> '' and ( old.password isnull or  new.password <> old.password ))then
    new.password = public.crypt(new.password, public.gen_salt('bf'));
  else
    new.password = old.password;
  end if;
  return new;
end
$$;


ALTER FUNCTION common.encrypt_pass() OWNER TO postgres;

--
-- Name: login(text, text); Type: FUNCTION; Schema: common; Owner: postgres
--

CREATE FUNCTION common.login(username text, password text) RETURNS common.jwt_token
    LANGUAGE plpgsql
    AS $$
declare
  _user record;
  _payload record;
  result common.jwt_token;
begin
  -- check email and password
  select users.* , settings.session_time from common.users LEFT OUTER JOIN common.settings ON (users.id = settings.id) where
    (users.login = username or users.email = username) AND
    users.password = public.crypt(login.password, users.password) and users.disabled = false
    into _user;
  if _user.role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  if _user.session_time is null then
    _user.session_time = '1:00:00'::interval;
  end if;

  select _user.role as role, _user.id as uid, _user.group_id as gid, nextval('common.token_seq') as seq,
         extract(epoch from (now() + _user.session_time ))::integer as exp into _payload;

  select public.sign(
      row_to_json(_payload), current_setting('app.jwt_secret')
    ) as token
    into result;
  return result;
end
$$;


ALTER FUNCTION common.login(username text, password text) OWNER TO postgres;

--
-- Name: security_check(); Type: FUNCTION; Schema: common; Owner: dba
--

CREATE FUNCTION common.security_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if
		-- Не надо пугаться web_anon, у него все равно нет доступа на api.users,
		-- он не сможет сделать write эту таблицу, тока через функци api.reg()
		current_setting('request.jwt.claim.role') not in ('super', 'web_anon')
		and
		(
			(new.role not in ('manager','guest') )
			or
			( old.role != new.role )
		    or
			( new.id = current_setting('request.jwt.claim.uid')::int)
		)
	then
		RAISE exception 'security violation (mf)';
	end if;
	return new;
end
$$;


ALTER FUNCTION common.security_check() OWNER TO dba;

--
-- Name: user_label(); Type: FUNCTION; Schema: common; Owner: dba
--

CREATE FUNCTION common.user_label() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin

  if new.login ISNULL then
    new.login = new.email;
  end if;  
    
  if new.label ISNULL then
    new.label = new.full_name||' ('||new.login ||')';
  end if;
  
  return new;
end
$$;


ALTER FUNCTION common.user_label() OWNER TO dba;

--
-- Name: user_new_settings(); Type: FUNCTION; Schema: common; Owner: dba
--

CREATE FUNCTION common.user_new_settings() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  insert into common.settings (id) values (new.id);
  return new;
end
$$;


ALTER FUNCTION common.user_new_settings() OWNER TO dba;

--
-- Name: update_accounting(); Type: FUNCTION; Schema: radius; Owner: dba
--

CREATE FUNCTION radius.update_accounting() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

        IF (TG_OP = 'INSERT') THEN

          select id,group_id from (
            SELECT id,group_id, profile,1 as priority  from hotspot.profiles where profile=NEW.called
            UNION SELECT id,group_id, profile,2 as priority  from hotspot.profiles where profile=NEW.nas
            order by priority) as profiles limit 1 into NEW.profile_id, NEW.group_id;
        END IF;

        RETURN NEW;
end
$$;


ALTER FUNCTION radius.update_accounting() OWNER TO dba;

--
-- Name: update_radius(); Type: FUNCTION; Schema: radius; Owner: dba
--

CREATE FUNCTION radius.update_radius() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
        REFRESH MATERIALIZED VIEW radius.hotspot_group_reply;
        REFRESH MATERIALIZED VIEW radius.hotspot_group_check;

        RETURN NULL; 
    end;
$$;


ALTER FUNCTION radius.update_radius() OWNER TO dba;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: abonents; Type: TABLE; Schema: hotspot; Owner: dba
--

CREATE TABLE hotspot.abonents (
    id bigint NOT NULL,
    username character varying,
    password character varying DEFAULT (public.uuid_generate_v4())::character varying NOT NULL,
    phone character varying,
    time_registred timestamp without time zone DEFAULT now(),
    time_seen timestamp without time zone DEFAULT now(),
    group_id integer,
    profile_id integer
);


ALTER TABLE hotspot.abonents OWNER TO dba;

--
-- Name: devices; Type: TABLE; Schema: hotspot; Owner: dba
--

CREATE TABLE hotspot.devices (
    abonent_id integer,
    mac macaddr,
    auth_id integer,
    time_registred timestamp without time zone DEFAULT now(),
    time_seen timestamp without time zone DEFAULT now(),
    useragent character varying,
    profile_id integer
);


ALTER TABLE hotspot.devices OWNER TO dba;

--
-- Name: hotspot_devices; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.hotspot_devices AS
 SELECT abonents.username,
    devices.mac,
    devices.time_seen,
    devices.time_registred,
    abonents.phone,
    devices.profile_id
   FROM (hotspot.devices
     JOIN hotspot.abonents ON ((devices.abonent_id = abonents.id)))
  WHERE (abonents.group_id = (current_setting('request.jwt.claim.gid'::text))::integer)
  ORDER BY abonents.time_seen DESC;


ALTER TABLE api.hotspot_devices OWNER TO dba;

--
-- Name: profiles; Type: TABLE; Schema: hotspot; Owner: dba
--

CREATE TABLE hotspot.profiles (
    id integer NOT NULL,
    profile character varying NOT NULL,
    group_id integer DEFAULT (current_setting('request.jwt.claim.gid'::text, true))::integer NOT NULL,
    label character varying,
    auth_types integer[],
    theme character varying DEFAULT 'default'::character varying,
    template json DEFAULT '{}'::json NOT NULL,
    mac_auth boolean DEFAULT true NOT NULL,
    limit_ports smallint DEFAULT 3,
    limit_speed integer DEFAULT (5120 * 1024),
    filter_id character varying,
    address_list character varying,
    limit_bytes bigint,
    redirect_url character varying,
    billing boolean DEFAULT false NOT NULL,
    limit_time interval DEFAULT '23:59:59'::interval,
    ad_url character varying,
    disabled boolean DEFAULT false NOT NULL,
    login_button boolean DEFAULT false NOT NULL,
    registration_timeout interval DEFAULT '1 mon'::interval,
    shared_check boolean DEFAULT true,
    CONSTRAINT limit_check CHECK ((((limit_time IS NULL) OR (date_part('epoch'::text, limit_time) > (0)::double precision)) AND ((limit_ports IS NULL) OR (limit_ports > 0)) AND ((limit_bytes IS NULL) OR (limit_bytes > 0)) AND ((limit_speed IS NULL) OR (limit_speed > 0)))),
    CONSTRAINT profile_check CHECK (((profile)::text ~* '^[A-Za-z][0-9a-zA-z._-]*$'::text))
);


ALTER TABLE hotspot.profiles OWNER TO dba;

--
-- Name: COLUMN profiles.profile; Type: COMMENT; Schema: hotspot; Owner: dba
--

COMMENT ON COLUMN hotspot.profiles.profile IS 'стоит чек на ^[A-Za-z][0-9A-Za-z._-]&';


--
-- Name: COLUMN profiles.limit_speed; Type: COMMENT; Schema: hotspot; Owner: dba
--

COMMENT ON COLUMN hotspot.profiles.limit_speed IS 'bit/s';


--
-- Name: COLUMN profiles.limit_bytes; Type: COMMENT; Schema: hotspot; Owner: dba
--

COMMENT ON COLUMN hotspot.profiles.limit_bytes IS 'MB';


--
-- Name: COLUMN profiles.redirect_url; Type: COMMENT; Schema: hotspot; Owner: dba
--

COMMENT ON COLUMN hotspot.profiles.redirect_url IS 'url';


--
-- Name: COLUMN profiles.billing; Type: COMMENT; Schema: hotspot; Owner: dba
--

COMMENT ON COLUMN hotspot.profiles.billing IS 'пока скрой';


--
-- Name: COLUMN profiles.ad_url; Type: COMMENT; Schema: hotspot; Owner: dba
--

COMMENT ON COLUMN hotspot.profiles.ad_url IS 'url
';


--
-- Name: accounting; Type: TABLE; Schema: radius; Owner: dba
--

CREATE TABLE radius.accounting (
    username character varying,
    mac macaddr,
    nas character varying,
    called character varying,
    time_start timestamp without time zone DEFAULT now() NOT NULL,
    time_end timestamp without time zone DEFAULT now(),
    ip inet,
    nas_ip inet,
    upload bigint,
    download bigint,
    group_id integer,
    upload_packets bigint,
    download_packets bigint,
    termination_cause integer,
    uptime interval,
    location_id uuid,
    location_name character varying,
    profile_id integer,
    session bytea,
    class uuid,
    nas_ip_port smallint
);


ALTER TABLE radius.accounting OWNER TO dba;

--
-- Name: COLUMN accounting.nas; Type: COMMENT; Schema: radius; Owner: dba
--

COMMENT ON COLUMN radius.accounting.nas IS 'хостнейм наса, для отбора и жойнов используй location_id';


--
-- Name: COLUMN accounting.called; Type: COMMENT; Schema: radius; Owner: dba
--

COMMENT ON COLUMN radius.accounting.called IS 'чаще всего совпадает с именем профайла, но не на всех насах';


--
-- Name: COLUMN accounting.upload; Type: COMMENT; Schema: radius; Owner: dba
--

COMMENT ON COLUMN radius.accounting.upload IS 'B';


--
-- Name: accounting; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.accounting AS
 SELECT hotspot_devices.phone,
    accounting.mac,
    accounting.nas,
    accounting.nas_ip,
    accounting.called AS called_station_id,
    min(accounting.time_start) AS time_start,
    sum(accounting.uptime) AS uptime,
    max(accounting.time_end) AS time_end,
    accounting.ip,
    sum(accounting.download) AS download,
    sum(accounting.upload) AS upload,
    profiles.label AS profile,
    accounting.profile_id,
    accounting.termination_cause
   FROM ((radius.accounting
     JOIN hotspot.profiles ON ((profiles.id = accounting.profile_id)))
     JOIN api.hotspot_devices ON ((hotspot_devices.mac = accounting.mac)))
  WHERE (accounting.group_id = (current_setting('request.jwt.claim.gid'::text))::integer)
  GROUP BY (date_trunc('day'::text, accounting.time_start)), (date_trunc('day'::text, accounting.time_end) + '00:00:01'::interval), hotspot_devices.phone, accounting.mac, accounting.nas, accounting.nas_ip, accounting.called, accounting.ip, profiles.label, accounting.profile_id, accounting.termination_cause
  ORDER BY (min(accounting.time_start)) DESC, (max(accounting.time_end)) DESC;


ALTER TABLE api.accounting OWNER TO postgres;

--
-- Name: auth_drivers; Type: TABLE; Schema: hotspot; Owner: dba
--

CREATE TABLE hotspot.auth_drivers (
    module character varying NOT NULL,
    label character varying NOT NULL
);


ALTER TABLE hotspot.auth_drivers OWNER TO dba;

--
-- Name: auth_drivers; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.auth_drivers AS
 SELECT auth_drivers.module,
    auth_drivers.label
   FROM hotspot.auth_drivers;


ALTER TABLE api.auth_drivers OWNER TO dba;

--
-- Name: auth_types; Type: TABLE; Schema: hotspot; Owner: dba
--

CREATE TABLE hotspot.auth_types (
    driver character varying DEFAULT 'smsru_callcheck'::character varying NOT NULL,
    group_id integer DEFAULT (current_setting('request.jwt.claim.gid'::text, true))::integer NOT NULL,
    key1 character varying,
    key2 character varying,
    label character varying,
    id integer NOT NULL,
    button text DEFAULT 'Авторизоваться'::text,
    disabled boolean DEFAULT false,
    group_ids integer[] DEFAULT ARRAY[(current_setting('request.jwt.claim.gid'::text, true))::integer]
);


ALTER TABLE hotspot.auth_types OWNER TO dba;

--
-- Name: COLUMN auth_types.group_id; Type: COMMENT; Schema: hotspot; Owner: dba
--

COMMENT ON COLUMN hotspot.auth_types.group_id IS 'тот кто менеджит тип авторизации
редактирование';


--
-- Name: COLUMN auth_types.group_ids; Type: COMMENT; Schema: hotspot; Owner: dba
--

COMMENT ON COLUMN hotspot.auth_types.group_ids IS 'кто может выбирать в профиль. только чтение label id type стобцов';


--
-- Name: auth_types; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.auth_types AS
 SELECT auth_types.id,
    auth_types.label,
    auth_types.driver,
    auth_types.key1,
    auth_types.key2,
    auth_types.button,
    auth_types.disabled,
    auth_types.group_ids
   FROM hotspot.auth_types
  WHERE (auth_types.group_id = (current_setting('request.jwt.claim.gid'::text, true))::integer);


ALTER TABLE api.auth_types OWNER TO dba;

--
-- Name: COLUMN auth_types.driver; Type: COMMENT; Schema: api; Owner: dba
--

COMMENT ON COLUMN api.auth_types.driver IS 'взять из auth_drivers. список питонских модулей на бэкэнде. ставится при создании, а потом ридонли';


--
-- Name: COLUMN auth_types.key1; Type: COMMENT; Schema: api; Owner: dba
--

COMMENT ON COLUMN api.auth_types.key1 IS 'открытый ключ';


--
-- Name: COLUMN auth_types.key2; Type: COMMENT; Schema: api; Owner: dba
--

COMMENT ON COLUMN api.auth_types.key2 IS 'закрытый ключ';


--
-- Name: COLUMN auth_types.button; Type: COMMENT; Schema: api; Owner: dba
--

COMMENT ON COLUMN api.auth_types.button IS 'подпись к кнопке в интерфейсе авторизации';


--
-- Name: COLUMN auth_types.group_ids; Type: COMMENT; Schema: api; Owner: dba
--

COMMENT ON COLUMN api.auth_types.group_ids IS 'список групп, тут надо сначала отрефакторить твоих юзеров.... пока поставь [0,1] hidden';


--
-- Name: auth_types_list; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.auth_types_list AS
 SELECT auth_types.id,
    auth_types.label
   FROM hotspot.auth_types
  WHERE ((current_setting('request.jwt.claim.gid'::text))::integer = ANY (auth_types.group_ids));


ALTER TABLE api.auth_types_list OWNER TO dba;

--
-- Name: nases; Type: TABLE; Schema: hotspot; Owner: dba
--

CREATE TABLE hotspot.nases (
    group_id integer DEFAULT (current_setting('request.jwt.claim.gid'::text, true))::integer NOT NULL,
    ident character varying,
    label character varying,
    id integer NOT NULL,
    location_id uuid DEFAULT public.uuid_generate_v4(),
    location_name character varying,
    nastype hotspot.nastype DEFAULT 'routeros'::hotspot.nastype NOT NULL,
    disabled boolean DEFAULT false NOT NULL
);


ALTER TABLE hotspot.nases OWNER TO dba;

--
-- Name: hotspot_nases; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.hotspot_nases AS
 SELECT nases.id,
    nases.nastype,
    nases.ident,
    nases.label,
    nases.location_id,
    nases.location_name,
    nases.disabled
   FROM hotspot.nases
  WHERE (nases.group_id = (current_setting('request.jwt.claim.gid'::text, true))::integer);


ALTER TABLE api.hotspot_nases OWNER TO dba;

--
-- Name: hotspot_profiles; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.hotspot_profiles AS
 SELECT profiles.id,
    profiles.profile,
    profiles.label,
    profiles.auth_types,
    profiles.theme,
    profiles.template,
    profiles.mac_auth,
    profiles.login_button,
    profiles.limit_ports,
    profiles.limit_bytes,
    profiles.limit_speed,
    profiles.limit_time,
    profiles.redirect_url,
    profiles.ad_url,
    profiles.address_list,
    profiles.filter_id,
    profiles.disabled
   FROM hotspot.profiles
  WHERE (profiles.group_id = (current_setting('request.jwt.claim.gid'::text, true))::integer);


ALTER TABLE api.hotspot_profiles OWNER TO dba;

--
-- Name: COLUMN hotspot_profiles.profile; Type: COMMENT; Schema: api; Owner: dba
--

COMMENT ON COLUMN api.hotspot_profiles.profile IS 'стоит чек на ^[A-Za-z][0-9A-Za-z._-]&';


--
-- Name: users; Type: TABLE; Schema: common; Owner: postgres
--

CREATE TABLE common.users (
    id integer NOT NULL,
    login character varying,
    label character varying DEFAULT 'Пользователь'::character varying,
    email character varying,
    phone character varying,
    password character varying,
    parent integer DEFAULT (current_setting('request.jwt.claim.uid'::text, true))::integer,
    group_id integer,
    deleted boolean DEFAULT false NOT NULL,
    role name DEFAULT 'guest'::name NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    full_name character varying
);


ALTER TABLE common.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: common; Owner: postgres
--

COMMENT ON TABLE common.users IS 'пользователи продукта, админы';


--
-- Name: users_tree; Type: VIEW; Schema: common; Owner: dba
--

CREATE VIEW common.users_tree AS
 WITH RECURSIVE r AS (
         SELECT users.id,
            users.parent,
            users.group_id,
            users.deleted
           FROM common.users
          WHERE ((users.parent = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR (users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer))
        UNION
         SELECT users.id,
            users.parent,
            users.group_id,
            users.deleted
           FROM (common.users
             JOIN r r_1 ON ((users.parent = r_1.id)))
        )
 SELECT r.id,
    r.parent,
    r.group_id
   FROM r
  WHERE (r.deleted = false);


ALTER TABLE common.users_tree OWNER TO dba;

--
-- Name: user_users; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.user_users AS
 SELECT users.id,
    users.login,
    users.label,
    users.email,
    users.phone,
    users.parent,
    users.group_id,
    users.disabled,
    users.role,
    users.full_name
   FROM common.users
  WHERE (users.id IN ( SELECT users_tree.id
           FROM common.users_tree));


ALTER TABLE api.user_users OWNER TO dba;

--
-- Name: dashboard; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.dashboard AS
 SELECT ( SELECT count(*) AS count
           FROM api.hotspot_devices) AS client_devices,
    ( SELECT count(*) AS count
           FROM api.user_users
          WHERE ((user_users.role = 'admin'::name) OR (user_users.role = 'super'::name))) AS admins,
    ( SELECT count(*) AS count
           FROM api.user_users
          WHERE ((user_users.role = 'manager'::name) OR (user_users.role = 'guest'::name))) AS managers,
    ( SELECT count(*) AS count
           FROM api.hotspot_nases) AS nases,
    ( SELECT count(*) AS count
           FROM api.hotspot_profiles) AS profiles;


ALTER TABLE api.dashboard OWNER TO postgres;

--
-- Name: hotspot_nastypes; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.hotspot_nastypes AS
 SELECT unnest(enum_range(NULL::hotspot.nastype)) AS nastype;


ALTER TABLE api.hotspot_nastypes OWNER TO dba;

--
-- Name: themes; Type: TABLE; Schema: hotspot; Owner: dba
--

CREATE TABLE hotspot.themes (
    name character varying NOT NULL,
    variables json DEFAULT '{}'::json,
    label character varying
);


ALTER TABLE hotspot.themes OWNER TO dba;

--
-- Name: hotspot_themes; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.hotspot_themes AS
 SELECT themes.name,
    themes.label,
    themes.variables
   FROM hotspot.themes;


ALTER TABLE api.hotspot_themes OWNER TO dba;

--
-- Name: client; Type: TABLE; Schema: radius; Owner: dba
--

CREATE TABLE radius.client (
    id integer NOT NULL,
    nasname cidr NOT NULL,
    shortname text NOT NULL,
    type text DEFAULT 'other'::text NOT NULL,
    ports integer,
    secret text NOT NULL,
    server text,
    community text,
    description text
);


ALTER TABLE radius.client OWNER TO dba;

--
-- Name: radius_secret; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.radius_secret AS
 SELECT client.server,
    client.secret,
    client.description
   FROM radius.client;


ALTER TABLE api.radius_secret OWNER TO dba;

--
-- Name: VIEW radius_secret; Type: COMMENT; Schema: api; Owner: dba
--

COMMENT ON VIEW api.radius_secret IS 'нужна для генератора конфигов';


--
-- Name: roles; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.roles AS
 SELECT (r.rolname)::name AS rolname
   FROM ( SELECT unnest(enum_range(NULL::common.roles_type)) AS rolname) r
  WHERE (r.rolname > (current_setting('request.jwt.claim.role'::text, true))::common.roles_type);


ALTER TABLE api.roles OWNER TO postgres;

--
-- Name: stat_cl_devices_cnt_by_month; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.stat_cl_devices_cnt_by_month AS
 SELECT count(*) AS cnt,
    date_trunc('month'::text, hotspot_devices.time_seen) AS month
   FROM api.hotspot_devices
  GROUP BY (date_trunc('month'::text, hotspot_devices.time_seen))
  ORDER BY (date_trunc('month'::text, hotspot_devices.time_seen)) DESC;


ALTER TABLE api.stat_cl_devices_cnt_by_month OWNER TO postgres;

--
-- Name: VIEW stat_cl_devices_cnt_by_month; Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON VIEW api.stat_cl_devices_cnt_by_month IS 'поменяй на селект дистинкт из аккаунтинга. а так пользователи со старых месяцев сливаются в последние';


--
-- Name: stat_cl_devices_regs_cnt_by_month; Type: VIEW; Schema: api; Owner: postgres
--

CREATE VIEW api.stat_cl_devices_regs_cnt_by_month AS
 SELECT count(*) AS cnt,
    date_trunc('month'::text, hotspot_devices.time_registred) AS month
   FROM api.hotspot_devices
  GROUP BY (date_trunc('month'::text, hotspot_devices.time_registred))
  ORDER BY (date_trunc('month'::text, hotspot_devices.time_registred)) DESC;


ALTER TABLE api.stat_cl_devices_regs_cnt_by_month OWNER TO postgres;

--
-- Name: user_groups; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.user_groups AS
 SELECT users.label,
    users.id
   FROM common.users
  WHERE ((users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR (users.parent = (current_setting('request.jwt.claim.uid'::text, true))::integer) OR (users.id = (current_setting('request.jwt.claim.gid'::text, true))::integer));


ALTER TABLE api.user_groups OWNER TO dba;

--
-- Name: user_profile; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.user_profile AS
 SELECT users.login,
    users.email,
    users.phone,
    users.full_name
   FROM common.users
  WHERE (users.id = (current_setting('request.jwt.claim.uid'::text, true))::integer);


ALTER TABLE api.user_profile OWNER TO dba;

--
-- Name: VIEW user_profile; Type: COMMENT; Schema: api; Owner: dba
--

COMMENT ON VIEW api.user_profile IS 'для менеджеров и гостей, чтоб указывали только свои данные';


--
-- Name: settings; Type: TABLE; Schema: common; Owner: dba
--

CREATE TABLE common.settings (
    id integer DEFAULT (current_setting('request.jwt.claim.uid'::text, true))::integer NOT NULL,
    session_time interval DEFAULT '08:00:00'::interval,
    reg_enabled boolean DEFAULT false NOT NULL,
    reg_activation_needed boolean DEFAULT false,
    reg_role name DEFAULT 'guest'::name,
    reg_secret character varying DEFAULT public.uuid_generate_v4(),
    reg_auth_types integer[] DEFAULT ARRAY[]::integer[] NOT NULL
);


ALTER TABLE common.settings OWNER TO dba;

--
-- Name: user_settings; Type: VIEW; Schema: api; Owner: dba
--

CREATE VIEW api.user_settings AS
 SELECT settings.session_time,
    settings.reg_enabled,
    settings.reg_activation_needed,
    settings.reg_role,
    settings.reg_secret,
    settings.reg_auth_types
   FROM common.settings
  WHERE (settings.id = (current_setting('request.jwt.claim.uid'::text, true))::integer);


ALTER TABLE api.user_settings OWNER TO dba;

--
-- Name: token_seq; Type: SEQUENCE; Schema: common; Owner: dba
--

CREATE SEQUENCE common.token_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


ALTER TABLE common.token_seq OWNER TO dba;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: common; Owner: postgres
--

CREATE SEQUENCE common.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE common.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: postgres
--

ALTER SEQUENCE common.users_id_seq OWNED BY common.users.id;


--
-- Name: auth_check; Type: TABLE; Schema: hotspot; Owner: dba
--

CREATE TABLE hotspot.auth_check (
    phone character varying,
    mac macaddr,
    auth_type_id integer NOT NULL,
    challenge json,
    "time" timestamp without time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    check_id character varying,
    challenge_data json,
    done boolean DEFAULT false NOT NULL,
    useragent character varying,
    group_id integer,
    profile character varying
);


ALTER TABLE hotspot.auth_check OWNER TO dba;

--
-- Name: auth_check_id_seq; Type: SEQUENCE; Schema: hotspot; Owner: dba
--

CREATE SEQUENCE hotspot.auth_check_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotspot.auth_check_id_seq OWNER TO dba;

--
-- Name: auth_check_id_seq; Type: SEQUENCE OWNED BY; Schema: hotspot; Owner: dba
--

ALTER SEQUENCE hotspot.auth_check_id_seq OWNED BY hotspot.auth_check.id;


--
-- Name: auth_types_id_seq; Type: SEQUENCE; Schema: hotspot; Owner: dba
--

CREATE SEQUENCE hotspot.auth_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotspot.auth_types_id_seq OWNER TO dba;

--
-- Name: auth_types_id_seq; Type: SEQUENCE OWNED BY; Schema: hotspot; Owner: dba
--

ALTER SEQUENCE hotspot.auth_types_id_seq OWNED BY hotspot.auth_types.id;


--
-- Name: nases_id_seq; Type: SEQUENCE; Schema: hotspot; Owner: dba
--

CREATE SEQUENCE hotspot.nases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotspot.nases_id_seq OWNER TO dba;

--
-- Name: nases_id_seq; Type: SEQUENCE OWNED BY; Schema: hotspot; Owner: dba
--

ALTER SEQUENCE hotspot.nases_id_seq OWNED BY hotspot.nases.id;


--
-- Name: peoples_id_seq; Type: SEQUENCE; Schema: hotspot; Owner: dba
--

CREATE SEQUENCE hotspot.peoples_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotspot.peoples_id_seq OWNER TO dba;

--
-- Name: peoples_id_seq; Type: SEQUENCE OWNED BY; Schema: hotspot; Owner: dba
--

ALTER SEQUENCE hotspot.peoples_id_seq OWNED BY hotspot.abonents.id;


--
-- Name: profile_id_seq; Type: SEQUENCE; Schema: hotspot; Owner: dba
--

CREATE SEQUENCE hotspot.profile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotspot.profile_id_seq OWNER TO dba;

--
-- Name: profile_id_seq; Type: SEQUENCE OWNED BY; Schema: hotspot; Owner: dba
--

ALTER SEQUENCE hotspot.profile_id_seq OWNED BY hotspot.profiles.id;


--
-- Name: client_id_seq; Type: SEQUENCE; Schema: radius; Owner: dba
--

CREATE SEQUENCE radius.client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE radius.client_id_seq OWNER TO dba;

--
-- Name: client_id_seq; Type: SEQUENCE OWNED BY; Schema: radius; Owner: dba
--

ALTER SEQUENCE radius.client_id_seq OWNED BY radius.client.id;


--
-- Name: collector; Type: TABLE; Schema: radius; Owner: dba
--

CREATE UNLOGGED TABLE radius.collector (
    input smallint NOT NULL,
    output smallint NOT NULL,
    pkts integer NOT NULL,
    octets integer NOT NULL,
    "time" tsrange NOT NULL,
    sport smallint NOT NULL,
    dport smallint NOT NULL,
    prot smallint NOT NULL,
    sensor_port smallint NOT NULL,
    sequence integer NOT NULL,
    sensor inet NOT NULL,
    srcaddr inet NOT NULL,
    dstaddr inet NOT NULL,
    nexthop inet NOT NULL,
    srcmac macaddr NOT NULL,
    dstmac macaddr NOT NULL
)
WITH (fillfactor='100', autovacuum_enabled='false');


ALTER TABLE radius.collector OWNER TO dba;

--
-- Name: hotspot_auth_check; Type: VIEW; Schema: radius; Owner: dba
--

CREATE VIEW radius.hotspot_auth_check AS
 SELECT abonents.id,
    abonents.username,
    abonents.password,
    devices.mac
   FROM hotspot.abonents,
    hotspot.devices
  WHERE (devices.abonent_id = abonents.id);


ALTER TABLE radius.hotspot_auth_check OWNER TO dba;

--
-- Name: hotspot_group; Type: VIEW; Schema: radius; Owner: dba
--

CREATE VIEW radius.hotspot_group AS
 SELECT profiles.profile,
    profiles.group_id
   FROM hotspot.profiles;


ALTER TABLE radius.hotspot_group OWNER TO dba;

--
-- Name: hotspot_group_check; Type: MATERIALIZED VIEW; Schema: radius; Owner: dba
--

CREATE MATERIALIZED VIEW radius.hotspot_group_check AS
 SELECT r.id,
    r.groupname,
    r.attribute,
    r.value,
    r.op
   FROM ( SELECT profiles.id,
            profiles.profile AS groupname,
            unnest(ARRAY['Simultaneous-Use'::text]) AS attribute,
            unnest(ARRAY[(profiles.limit_ports)::text]) AS value,
            unnest(ARRAY[':='::text]) AS op
           FROM hotspot.profiles
          WHERE (profiles.disabled = false)) r
  WHERE (r.value IS NOT NULL)
  WITH NO DATA;


ALTER TABLE radius.hotspot_group_check OWNER TO dba;

--
-- Name: hotspot_group_reply; Type: MATERIALIZED VIEW; Schema: radius; Owner: dba
--

CREATE MATERIALIZED VIEW radius.hotspot_group_reply AS
 SELECT r.id,
    r.groupname,
    r.attribute,
    r.value,
    r.op
   FROM ( SELECT profiles.id,
            profiles.profile AS groupname,
            unnest(ARRAY['Port-Limit'::text, 'Mikrotik-Xmit-Limit'::text, 'Mikrotik-Xmit-Limit-Gigawords'::text, 'Ascend-Data-Rate'::text, 'Session-Timeout'::text, 'WISPr-Redirection-URL'::text, 'Mikrotik-Advertise-URL'::text, 'Mikrotik-Address-List'::text, 'Filter-Id'::text]) AS attribute,
            unnest(ARRAY[(profiles.limit_ports)::text, (profiles.limit_bytes)::text, ((profiles.limit_bytes & '4294967295'::bigint))::text, ((profiles.limit_speed >> 32))::text, (date_part('epoch'::text, profiles.limit_time))::text, (profiles.redirect_url)::text, (profiles.ad_url)::text, (profiles.address_list)::text, (profiles.filter_id)::text]) AS value,
            unnest(ARRAY[':='::text, ':='::text, ':='::text, ':='::text, ':='::text, ':='::text, ':='::text, ':='::text, ':='::text]) AS op
           FROM hotspot.profiles
          WHERE (profiles.disabled = false)) r
  WHERE (r.value IS NOT NULL)
  WITH NO DATA;


ALTER TABLE radius.hotspot_group_reply OWNER TO dba;

--
-- Name: sessions; Type: TABLE; Schema: web; Owner: dba
--

CREATE TABLE web.sessions (
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    session json,
    expire timestamp without time zone,
    created timestamp without time zone DEFAULT now()
);


ALTER TABLE web.sessions OWNER TO dba;

--
-- Name: users id; Type: DEFAULT; Schema: common; Owner: postgres
--

ALTER TABLE ONLY common.users ALTER COLUMN id SET DEFAULT nextval('common.users_id_seq'::regclass);


--
-- Name: users group_id; Type: DEFAULT; Schema: common; Owner: postgres
--

ALTER TABLE ONLY common.users ALTER COLUMN group_id SET DEFAULT currval('common.users_id_seq'::regclass);


--
-- Name: abonents id; Type: DEFAULT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.abonents ALTER COLUMN id SET DEFAULT nextval('hotspot.peoples_id_seq'::regclass);


--
-- Name: abonents username; Type: DEFAULT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.abonents ALTER COLUMN username SET DEFAULT ('HS'::text || btrim(encode((to_hex(currval('hotspot.peoples_id_seq'::regclass)))::bytea, 'base64'::text), '='::text));


--
-- Name: auth_check id; Type: DEFAULT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.auth_check ALTER COLUMN id SET DEFAULT nextval('hotspot.auth_check_id_seq'::regclass);


--
-- Name: auth_types id; Type: DEFAULT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.auth_types ALTER COLUMN id SET DEFAULT nextval('hotspot.auth_types_id_seq'::regclass);


--
-- Name: nases id; Type: DEFAULT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.nases ALTER COLUMN id SET DEFAULT nextval('hotspot.nases_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.profiles ALTER COLUMN id SET DEFAULT nextval('hotspot.profile_id_seq'::regclass);


--
-- Name: profiles profile; Type: DEFAULT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.profiles ALTER COLUMN profile SET DEFAULT (('hotspot'::text || current_setting('request.jwt.claim.gid'::text, true)) || (currval('hotspot.profile_id_seq'::regclass))::text);


--
-- Name: client id; Type: DEFAULT; Schema: radius; Owner: dba
--

ALTER TABLE ONLY radius.client ALTER COLUMN id SET DEFAULT nextval('radius.client_id_seq'::regclass);


--
-- Name: settings settings_pk; Type: CONSTRAINT; Schema: common; Owner: dba
--

ALTER TABLE ONLY common.settings
    ADD CONSTRAINT settings_pk PRIMARY KEY (id);


--
-- Name: users users_login; Type: CONSTRAINT; Schema: common; Owner: postgres
--

ALTER TABLE ONLY common.users
    ADD CONSTRAINT users_login UNIQUE (login);


--
-- Name: users users_pk; Type: CONSTRAINT; Schema: common; Owner: postgres
--

ALTER TABLE ONLY common.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);


--
-- Name: abonents abonents_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.abonents
    ADD CONSTRAINT abonents_pk UNIQUE (username);


--
-- Name: auth_check auth_check_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.auth_check
    ADD CONSTRAINT auth_check_pk PRIMARY KEY (id);


--
-- Name: auth_drivers auth_drivers_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.auth_drivers
    ADD CONSTRAINT auth_drivers_pk PRIMARY KEY (module);


--
-- Name: auth_types auth_types_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.auth_types
    ADD CONSTRAINT auth_types_pk PRIMARY KEY (id);


--
-- Name: devices devices_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.devices
    ADD CONSTRAINT devices_pk UNIQUE (abonent_id, mac, profile_id);


--
-- Name: nases nases_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.nases
    ADD CONSTRAINT nases_pk PRIMARY KEY (id);


--
-- Name: abonents peoples_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.abonents
    ADD CONSTRAINT peoples_pk PRIMARY KEY (id);


--
-- Name: abonents phone_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.abonents
    ADD CONSTRAINT phone_pk UNIQUE (phone, group_id);


--
-- Name: profiles profile_name; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.profiles
    ADD CONSTRAINT profile_name UNIQUE (profile);


--
-- Name: profiles profile_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.profiles
    ADD CONSTRAINT profile_pk PRIMARY KEY (id);


--
-- Name: themes themes_pk; Type: CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.themes
    ADD CONSTRAINT themes_pk PRIMARY KEY (name);


--
-- Name: accounting accounting_pk; Type: CONSTRAINT; Schema: radius; Owner: dba
--

ALTER TABLE ONLY radius.accounting
    ADD CONSTRAINT accounting_pk UNIQUE (class);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: radius; Owner: dba
--

ALTER TABLE ONLY radius.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pk; Type: CONSTRAINT; Schema: web; Owner: dba
--

ALTER TABLE ONLY web.sessions
    ADD CONSTRAINT sessions_pk PRIMARY KEY (uuid);


--
-- Name: settings_reg_secret_uindex; Type: INDEX; Schema: common; Owner: dba
--

CREATE UNIQUE INDEX settings_reg_secret_uindex ON common.settings USING btree (reg_secret);


--
-- Name: users_login_uindex; Type: INDEX; Schema: common; Owner: postgres
--

CREATE UNIQUE INDEX users_login_uindex ON common.users USING btree (login);


--
-- Name: abonents_time_seen_index; Type: INDEX; Schema: hotspot; Owner: dba
--

CREATE INDEX abonents_time_seen_index ON hotspot.abonents USING btree (time_seen DESC);


--
-- Name: auth_check_check_id_index; Type: INDEX; Schema: hotspot; Owner: dba
--

CREATE INDEX auth_check_check_id_index ON hotspot.auth_check USING btree (check_id);


--
-- Name: auth_drivers_label_uindex; Type: INDEX; Schema: hotspot; Owner: dba
--

CREATE UNIQUE INDEX auth_drivers_label_uindex ON hotspot.auth_drivers USING btree (label);


--
-- Name: auth_types_group_id_index; Type: INDEX; Schema: hotspot; Owner: dba
--

CREATE INDEX auth_types_group_id_index ON hotspot.auth_types USING btree (group_id);


--
-- Name: auth_types_type_index; Type: INDEX; Schema: hotspot; Owner: dba
--

CREATE INDEX auth_types_type_index ON hotspot.auth_types USING btree (driver);


--
-- Name: accounting_group_index; Type: INDEX; Schema: radius; Owner: dba
--

CREATE INDEX accounting_group_index ON radius.accounting USING btree (group_id);


--
-- Name: accounting_nas_index; Type: INDEX; Schema: radius; Owner: dba
--

CREATE INDEX accounting_nas_index ON radius.accounting USING btree (nas);


--
-- Name: accounting_time_index; Type: INDEX; Schema: radius; Owner: dba
--

CREATE INDEX accounting_time_index ON radius.accounting USING brin (time_start, time_end);


--
-- Name: accounting_username_termination_cause_index; Type: INDEX; Schema: radius; Owner: dba
--

CREATE INDEX accounting_username_termination_cause_index ON radius.accounting USING btree (username, termination_cause);


--
-- Name: collector_time_index; Type: INDEX; Schema: radius; Owner: dba
--

CREATE INDEX collector_time_index ON radius.collector USING brin ("time");


--
-- Name: users encrypt_pass; Type: TRIGGER; Schema: common; Owner: postgres
--

CREATE TRIGGER encrypt_pass BEFORE INSERT OR UPDATE ON common.users FOR EACH ROW EXECUTE PROCEDURE common.encrypt_pass();


--
-- Name: users label; Type: TRIGGER; Schema: common; Owner: postgres
--

CREATE TRIGGER label BEFORE INSERT ON common.users FOR EACH ROW EXECUTE PROCEDURE common.user_label();


--
-- Name: users security_check; Type: TRIGGER; Schema: common; Owner: postgres
--

CREATE TRIGGER security_check BEFORE INSERT OR UPDATE ON common.users FOR EACH ROW EXECUTE PROCEDURE common.security_check();


--
-- Name: users settings; Type: TRIGGER; Schema: common; Owner: postgres
--

CREATE TRIGGER settings AFTER INSERT ON common.users FOR EACH ROW EXECUTE PROCEDURE common.user_new_settings();


--
-- Name: profiles update_radius; Type: TRIGGER; Schema: hotspot; Owner: dba
--

CREATE TRIGGER update_radius AFTER INSERT OR DELETE OR UPDATE ON hotspot.profiles FOR EACH STATEMENT EXECUTE PROCEDURE radius.update_radius();


--
-- Name: accounting update_accounting; Type: TRIGGER; Schema: radius; Owner: dba
--

CREATE TRIGGER update_accounting BEFORE INSERT OR UPDATE ON radius.accounting FOR EACH ROW EXECUTE PROCEDURE radius.update_accounting();


--
-- Name: settings settings_users_id_fk; Type: FK CONSTRAINT; Schema: common; Owner: dba
--

ALTER TABLE ONLY common.settings
    ADD CONSTRAINT settings_users_id_fk FOREIGN KEY (id) REFERENCES common.users(id);


--
-- Name: users users_group_fk; Type: FK CONSTRAINT; Schema: common; Owner: postgres
--

ALTER TABLE ONLY common.users
    ADD CONSTRAINT users_group_fk FOREIGN KEY (group_id) REFERENCES common.users(id) ON DELETE SET DEFAULT;


--
-- Name: users users_parent_fk; Type: FK CONSTRAINT; Schema: common; Owner: postgres
--

ALTER TABLE ONLY common.users
    ADD CONSTRAINT users_parent_fk FOREIGN KEY (parent) REFERENCES common.users(id) ON DELETE SET DEFAULT;


--
-- Name: auth_types auth_types_auth_drivers_module_fk; Type: FK CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.auth_types
    ADD CONSTRAINT auth_types_auth_drivers_module_fk FOREIGN KEY (driver) REFERENCES hotspot.auth_drivers(module);


--
-- Name: profiles profile_themes_name_fk; Type: FK CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.profiles
    ADD CONSTRAINT profile_themes_name_fk FOREIGN KEY (theme) REFERENCES hotspot.themes(name);


--
-- Name: profiles profile_users__fk; Type: FK CONSTRAINT; Schema: hotspot; Owner: dba
--

ALTER TABLE ONLY hotspot.profiles
    ADD CONSTRAINT profile_users__fk FOREIGN KEY (group_id) REFERENCES common.users(id);


--
-- Name: DATABASE spot6; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE spot6 TO dba;


--
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA api TO web_anon;
GRANT USAGE ON SCHEMA api TO backend;
GRANT USAGE ON SCHEMA api TO admin;
GRANT USAGE ON SCHEMA api TO manager;
GRANT USAGE ON SCHEMA api TO super;
GRANT ALL ON SCHEMA api TO dba;


--
-- Name: SCHEMA common; Type: ACL; Schema: -; Owner: dba
--

GRANT ALL ON SCHEMA common TO postgres;
GRANT USAGE ON SCHEMA common TO admin;
GRANT USAGE ON SCHEMA common TO super;
GRANT USAGE ON SCHEMA common TO manager;


--
-- Name: SCHEMA hotspot; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA hotspot TO radius;


--
-- Name: SCHEMA radius; Type: ACL; Schema: -; Owner: dba
--

GRANT USAGE ON SCHEMA radius TO radius;


--
-- Name: FUNCTION login(username character varying, password character varying); Type: ACL; Schema: api; Owner: dba
--

GRANT ALL ON FUNCTION api.login(username character varying, password character varying) TO web_anon;
GRANT ALL ON FUNCTION api.login(username character varying, password character varying) TO super;
GRANT ALL ON FUNCTION api.login(username character varying, password character varying) TO admin;
GRANT ALL ON FUNCTION api.login(username character varying, password character varying) TO manager;
GRANT ALL ON FUNCTION api.login(username character varying, password character varying) TO guest;


--
-- Name: FUNCTION passwd(user_id integer, newpassword text); Type: ACL; Schema: api; Owner: dba
--

GRANT ALL ON FUNCTION api.passwd(user_id integer, newpassword text) TO admin;
GRANT ALL ON FUNCTION api.passwd(user_id integer, newpassword text) TO super;


--
-- Name: FUNCTION refresh(); Type: ACL; Schema: api; Owner: dba
--

GRANT ALL ON FUNCTION api.refresh() TO super;
GRANT ALL ON FUNCTION api.refresh() TO admin;
GRANT ALL ON FUNCTION api.refresh() TO manager;
GRANT ALL ON FUNCTION api.refresh() TO guest;


--
-- Name: TABLE hotspot_devices; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE api.hotspot_devices TO super;
GRANT SELECT,REFERENCES ON TABLE api.hotspot_devices TO admin;
GRANT SELECT,REFERENCES ON TABLE api.hotspot_devices TO manager;
GRANT SELECT,REFERENCES ON TABLE api.hotspot_devices TO guest;


--
-- Name: TABLE profiles; Type: ACL; Schema: hotspot; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE hotspot.profiles TO radius;


--
-- Name: TABLE accounting; Type: ACL; Schema: radius; Owner: dba
--

GRANT SELECT,INSERT,REFERENCES,UPDATE ON TABLE radius.accounting TO radius;


--
-- Name: TABLE accounting; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.accounting TO super;
GRANT SELECT ON TABLE api.accounting TO admin;
GRANT SELECT ON TABLE api.accounting TO manager;


--
-- Name: TABLE auth_drivers; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE api.auth_drivers TO super;
GRANT SELECT,REFERENCES ON TABLE api.auth_drivers TO admin;
GRANT SELECT,REFERENCES ON TABLE api.auth_drivers TO manager;
GRANT SELECT,REFERENCES ON TABLE api.auth_drivers TO guest;


--
-- Name: TABLE auth_types; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE api.auth_types TO super;
GRANT SELECT,REFERENCES ON TABLE api.auth_types TO admin;


--
-- Name: TABLE auth_types_list; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE api.auth_types_list TO super;
GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE api.auth_types_list TO admin;
GRANT SELECT,REFERENCES ON TABLE api.auth_types_list TO manager;
GRANT SELECT,REFERENCES ON TABLE api.auth_types_list TO guest;


--
-- Name: TABLE hotspot_nases; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,INSERT,REFERENCES,UPDATE ON TABLE api.hotspot_nases TO super;
GRANT SELECT,INSERT,REFERENCES,UPDATE ON TABLE api.hotspot_nases TO admin;
GRANT SELECT,INSERT,REFERENCES,UPDATE ON TABLE api.hotspot_nases TO manager;
GRANT SELECT,REFERENCES ON TABLE api.hotspot_nases TO guest;


--
-- Name: TABLE hotspot_profiles; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE api.hotspot_profiles TO super;
GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE api.hotspot_profiles TO admin;
GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE api.hotspot_profiles TO manager;
GRANT SELECT,REFERENCES ON TABLE api.hotspot_profiles TO guest;


--
-- Name: TABLE user_users; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.user_users TO super;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.user_users TO admin;
GRANT SELECT ON TABLE api.user_users TO manager;
GRANT SELECT ON TABLE api.user_users TO guest;


--
-- Name: TABLE dashboard; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.dashboard TO super;


--
-- Name: TABLE hotspot_nastypes; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT ON TABLE api.hotspot_nastypes TO super;


--
-- Name: TABLE hotspot_themes; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE api.hotspot_themes TO super;
GRANT SELECT,REFERENCES ON TABLE api.hotspot_themes TO admin;
GRANT SELECT,REFERENCES ON TABLE api.hotspot_themes TO manager;
GRANT SELECT,REFERENCES ON TABLE api.hotspot_themes TO guest;


--
-- Name: TABLE client; Type: ACL; Schema: radius; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE radius.client TO radius;


--
-- Name: TABLE radius_secret; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT ON TABLE api.radius_secret TO super;
GRANT SELECT ON TABLE api.radius_secret TO admin;
GRANT SELECT ON TABLE api.radius_secret TO manager;


--
-- Name: TABLE roles; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.roles TO admin;
GRANT SELECT ON TABLE api.roles TO super;


--
-- Name: TABLE stat_cl_devices_cnt_by_month; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.stat_cl_devices_cnt_by_month TO super;
GRANT SELECT ON TABLE api.stat_cl_devices_cnt_by_month TO admin;
GRANT SELECT ON TABLE api.stat_cl_devices_cnt_by_month TO manager;


--
-- Name: TABLE stat_cl_devices_regs_cnt_by_month; Type: ACL; Schema: api; Owner: postgres
--

GRANT SELECT ON TABLE api.stat_cl_devices_regs_cnt_by_month TO super;
GRANT SELECT ON TABLE api.stat_cl_devices_regs_cnt_by_month TO admin;
GRANT SELECT ON TABLE api.stat_cl_devices_regs_cnt_by_month TO manager;


--
-- Name: TABLE user_groups; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.user_groups TO super;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.user_groups TO admin;


--
-- Name: TABLE user_profile; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.user_profile TO super;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.user_profile TO admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.user_profile TO manager;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE api.user_profile TO guest;


--
-- Name: TABLE user_settings; Type: ACL; Schema: api; Owner: dba
--

GRANT SELECT,INSERT,UPDATE ON TABLE api.user_settings TO super;
GRANT SELECT,INSERT,UPDATE ON TABLE api.user_settings TO admin;
GRANT SELECT,INSERT,UPDATE ON TABLE api.user_settings TO manager;
GRANT SELECT,INSERT,UPDATE ON TABLE api.user_settings TO guest;


--
-- Name: SEQUENCE users_id_seq; Type: ACL; Schema: common; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE common.users_id_seq TO admin;
GRANT SELECT,USAGE ON SEQUENCE common.users_id_seq TO super;


--
-- Name: SEQUENCE profile_id_seq; Type: ACL; Schema: hotspot; Owner: dba
--

GRANT USAGE ON SEQUENCE hotspot.profile_id_seq TO super;
GRANT USAGE ON SEQUENCE hotspot.profile_id_seq TO admin;
GRANT USAGE ON SEQUENCE hotspot.profile_id_seq TO manager;


--
-- Name: TABLE collector; Type: ACL; Schema: radius; Owner: dba
--

GRANT INSERT ON TABLE radius.collector TO radius;


--
-- Name: TABLE hotspot_auth_check; Type: ACL; Schema: radius; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE radius.hotspot_auth_check TO radius;


--
-- Name: TABLE hotspot_group; Type: ACL; Schema: radius; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE radius.hotspot_group TO radius;


--
-- Name: TABLE hotspot_group_check; Type: ACL; Schema: radius; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE radius.hotspot_group_check TO radius;


--
-- Name: TABLE hotspot_group_reply; Type: ACL; Schema: radius; Owner: dba
--

GRANT SELECT,REFERENCES ON TABLE radius.hotspot_group_reply TO radius;


--
-- PostgreSQL database dump complete
--

