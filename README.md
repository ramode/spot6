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

### Exampels for debug:
set role admin;
set request.jwt.claim.role = 'admin';
set request.jwt.claim.email = 'test@eth0.pro';

SHOW current_setting('request.jwt.claim.email');

select * from basic_auth.user_id();