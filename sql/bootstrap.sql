SET "request.jwt.claim.role" = 'super';
insert into common.users (login,password,role,id,parent, group_id) values ('root','rootpass','super',0,0,0);


ALTER USER authenticator with password 'pass123';
ALTER USER dba with password 'adminpass';
ALTER USER radius with password 'raddpass';

