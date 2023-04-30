```bash
curl http://localhost:6543/user \
   -H "Accept: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOm51bGwsInJvbGUiOiJhZG1pbiIsIm5vbmNlIjoiY2Q0NWM2Y2M2MWU5NDMzNmFiZjEzYThkNzdlYzMxY2MiLCJleHAiOjE2ODI4Njc1MDEuNDc0ODc3fQ.O36gusy3wIdRV-H-Quhrz6Yde6BKGwDM4a8RNLCak-s"
```

```bash
curl http://localhost:6543/user?select=\*,email\(\*\) \
   -H "Accept: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOm51bGwsInJvbGUiOiJhZG1pbiIsIm5vbmNlIjoiY2Q0NWM2Y2M2MWU5NDMzNmFiZjEzYThkNzdlYzMxY2MiLCJleHAiOjE2ODI4Njc1MDEuNDc0ODc3fQ.O36gusy3wIdRV-H-Quhrz6Yde6BKGwDM4a8RNLCak-s"
```

```bash
curl "http://localhost:6543/rpc/user_sign_in" \
  -X POST -H "Content-Type: application/json" \
   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsIm5vbmNlIjoiYzc0NTI5YjRjOGM0NTk2NTRiMmVhZWMwZmRiYjIwNjQifQ.9RqJIvDvU2xI33p9Azh6QlBqwB8KsG0X5FuVu9ncYKw" \
  -d '{"p_username":"admin","p_password":"admin"}'
```
