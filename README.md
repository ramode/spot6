# spot6

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Run your tests
```
npm run test
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).


### NOTES:
Row level policy: select * from pg_policies;

On api.login() function set SECURITY DEFINER;

### PostgREST
To refresh the cache without restarting the PostgREST server, send the server process a SIGUSR1 signal:
```
killall -SIGUSR1 postgrest
```

### Exampels for debug:
```
set role admin; set request.jwt.claim.role = 'admin'; set request.jwt.claim.login = 'test@eth0.pro'; set request.jwt.claim.uid = '3'; set request.jwt.claim.gid = '1';
set role super; set request.jwt.claim.role = 'super'; set request.jwt.claim.login = 'morfair@gmail.com'; set request.jwt.claim.uid = '1'; set request.jwt.claim.gid = '0';
```
```
SHOW current_setting('request.jwt.claim.email');
```
```
select * from basic_auth.user_id();
```
