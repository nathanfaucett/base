#!/bin/sh

set -e

if [ -z "$PGRST_JWT_SECRET" ]; then
    echo "Must provide PGRST_JWT_SECRET in environment" 1>&2
    exit 1
fi

until psql -c '\l'; do
  echo >&2 "$(date +%Y%m%dt%H%M%S) Postgres is unavailable - sleeping"
  sleep 1
done

result=$(psql --quiet -t -A -c "SELECT count(*) FROM information_schema.schemata WHERE schema_name='auth'")
if [ "$result" = 1 ]; then
  echo "Already ran init"
else
echo "Running"
psql -v ON_ERROR_STOP=1 <<EOL
BEGIN;
\i sql/roles.sql
\i sql/private.sql
\i sql/auth.sql
\i sql/public.sql
INSERT INTO auth.jwt_secret ("name", "value", expires_in) VALUES ('postgrest', '$PGRST_JWT_SECRET', '1 day');
COMMIT;
EOL
fi