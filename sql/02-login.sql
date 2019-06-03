create sequence tokens_serial_seq;


CREATE or replace FUNCTION api.login(username text, password text) RETURNS common.jwt_token
    LANGUAGE plpgsql
    AS $$
declare
  _user record;
  _payload record;
  result common.jwt_token;
begin
  -- check email and password
  select users.* , settings.session_time from common.users LEFT OUTER JOIN common.settings ON (users.id = settings.id) where
    users.login = username AND
    users.password = crypt(login.password, users.password) and users.disabled = false
    into _user;
  if _user.role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  if _user.session_time is null then
    _user.session_time = '2:00:00'::interval;
  end if;

  select _user.role as role, _user.id as uid, _user.group as gid, nextval('tokens_serial_seq') as seq,
         extract(epoch from (now() + _user.session_time ))::integer as exp into _payload;

  select public.sign(
      row_to_json(_payload), current_setting('app.jwt_secret')
    ) as token
    into result;
  return result;
end;
$$;
