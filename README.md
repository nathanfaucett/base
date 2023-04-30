```bash
curl http://localhost:6543/user \
   -H "Accept: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOm51bGwsInJvbGUiOiJhZG1pbiIsIm5vbmNlIjoiODRhNjMzY2U0M2I5ZmE2Y2Y0NTlmNGI2MjlkMTkyYzEiLCJleHAiOjE2ODI5NTAzNDkuNzM5OTcxfQ.Cqy32y4AuXqoP6NFkw9Sv5EuJRsOYe0Qo8l0hAJ8JhE"
```

```bash
curl http://localhost:6543/user?select=\*,email\(\*\) \
   -H "Accept: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOm51bGwsInJvbGUiOiJhZG1pbiIsIm5vbmNlIjoiODRhNjMzY2U0M2I5ZmE2Y2Y0NTlmNGI2MjlkMTkyYzEiLCJleHAiOjE2ODI5NTAzNDkuNzM5OTcxfQ.Cqy32y4AuXqoP6NFkw9Sv5EuJRsOYe0Qo8l0hAJ8JhE"
```

```bash
curl "http://localhost:6543/rpc/user_sign_in" \
  -X POST -H "Content-Type: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsIm5vbmNlIjoiYzc0NTI5YjRjOGM0NTk2NTRiMmVhZWMwZmRiYjIwNjQifQ.9RqJIvDvU2xI33p9Azh6QlBqwB8KsG0X5FuVu9ncYKw" \
  -d '{"p_username":"admin","p_password":"admin"}'
```
