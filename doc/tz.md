tz
===


стек
---

freeradius 3+
postgresql 10+
python 3.6+
debian 10

таблицы
---

common.users

 - login
 - password(crypt)
 - email
 - label
 - phone
 - parent (fk users)
 - group (fk users) пользователи группы видят объекты своей группы
 

common.role

 - role ( create, read, update, delete)
 - part ( roles, users, hotspot, clients итд) - если есть роль, то открывается раздел админки
 - user_id


hotspot.profile

 - group
 - skin (папка html+js+css)
 - text - json для подстановки в шаблон. надо распарсить скин и выцепить оттуда переменные. из этого жсона подставлять значения при рендеринге переменные должны иметь префикс t_ext,l_abel,i_mage,v_ideo - соответственно картинка c аплоадом... для начала сырой текст
 - auth_mac
 - auth_mac_permanent
 - auth_call
 - auth_login
 - auth_otp

 - session_time
 - traffic
 - redirect_radius
 - redirect_js
 - session_count
 - filter
 - speed
 
hotspot.user

 - login
 - password
 - reg_date
 - seen_date
 - phone
 
hotspot.device

 - mac
 - hotspot.user_id
 - reg_date
 - seen_date
 - comfirmed
 - expires
 - challenge_type 
 - challenge_phone
 - challenge_token
 
hotspot.challenge
 - group
 - type (otp, smsc)
 - login
 - password
 - token
 - url
 
 accounting
 
 всё с радиуса

клиент
---

ссылка с редиректом - get запрос - редирект на фронт с сессией
запрос на звонок
аксиосом тянем лонгполинг
в ответе логин -пароль и страница которую открыть при авторизации

