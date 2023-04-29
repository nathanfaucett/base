```bash
curl http://localhost:6543/user \
   -H "Accept: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOm51bGwsInJvbGUiOiJhZG1pbiIsIm5vbmNlIjoiZTk3ZDJkZjQyZDU2ZmJmZjJhYTUyZDU2NjZiNjk0M2MiLCJleHAiOjE2ODI3Njc4MDEuMDkzMTUzfQ.q0zodlJU4yqP9lbC1c6Mvc57SXjhTQg90lTj-A-HkVY"
```

```bash
curl http://localhost:6543/user \
   -H "Accept: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwiZW1haWwiOm51bGwsInJvbGUiOiJ1c2VyIiwibm9uY2UiOiJkMWQyYTdmZGM2MDNjZDIzYTlhZDQwMTcwNTYxNThmNyIsImV4cCI6MTY4Mjc2ODY2My41MjEyNDl9.D4rYdIGqXzl4AAET_GDqIFmoCUzFkaZhBtD-YIIswfQ"
```

```bash
curl "http://localhost:6543/rpc/user_sign_in" \
  -X POST -H "Content-Type: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsIm5vbmNlIjoiYzc0NTI5YjRjOGM0NTk2NTRiMmVhZWMwZmRiYjIwNjQifQ.9RqJIvDvU2xI33p9Azh6QlBqwB8KsG0X5FuVu9ncYKw" \
  -d '{"p_username":"admin","p_password":"admin"}'
```
