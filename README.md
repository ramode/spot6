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
SET search_path = 'api', 'public';
SET "role" = 'super';
SET "request.jwt.claim.exp" = '1561947535';
SET "request.jwt.claim.uid" = '0';
SET "request.jwt.claim.role" = 'super';
SET "request.jwt.claim.seq" = '2'; -- номер сессии
SET "request.jwt.claim.gid" = '0';

```

Http Locals

```
SET LOCAL "request.header.x-forwarded-host" = 'localhost:8080';
SET LOCAL "request.header.x-forwarded-proto" = 'http';SET LOCAL "request.header.x-forwarded-port" = '8080';SET LOCAL "request.header.x-forwarded-for" = '127.0.0.1';
SET LOCAL "request.header.x-compress" = 'null';
SET LOCAL "request.header.accept-language" = 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7';
SET LOCAL "request.header.accept-encoding" = 'gzip, deflate, br';
SET LOCAL "request.header.referer" = 'http://localhost:8080/users/9';
SET LOCAL "request.header.content-type" = 'application/json;charset=UTF-8';
SET LOCAL "request.header.dnt" = '1';
SET LOCAL "request.header.user-agent" = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36 OPR/60.0.3255.170';
SET LOCAL "request.header.origin" = 'http://localhost:8080';
SET LOCAL "request.header.accept" = 'application/json, text/plain, */*';
SET LOCAL "request.header.cache-control" = 'no-cache';SET LOCAL "request.header.pragma" = 'no-cache';
SET LOCAL "request.header.content-length" = '33';SET LOCAL "request.header.connection" = 'close';
SET LOCAL "request.header.host" = 'localhost:5000';SET LOCAL "request.cookie.rememberMe" = 'false';

```
