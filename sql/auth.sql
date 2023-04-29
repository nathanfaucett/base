CREATE SCHEMA auth;
CREATE EXTENSION pgcrypto WITH SCHEMA "auth";

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO "user";
GRANT USAGE ON SCHEMA auth TO "admin";


CREATE FUNCTION auth.id()
	RETURNS bigint
	LANGUAGE plpgsql
AS $function$
	BEGIN
		RETURN (current_setting('request.jwt.claims', true)::json->>'sub')::bigint;
	END;
$function$;

CREATE FUNCTION auth.email()
	RETURNS text
	LANGUAGE plpgsql
AS $function$
	BEGIN
		RETURN current_setting('request.jwt.claims', true)::json->>'email';
	END;
$function$;


CREATE TABLE auth.jwt_secret (
	id serial4 NOT NULL,
	"name" varchar(255) NOT NULL,
	"value" text NOT NULL,
	expires_in interval NOT NULL,
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT jwt_secret_pk PRIMARY KEY (id)
);
CREATE UNIQUE INDEX jwt_secret_name_uindex ON auth.jwt_secret USING btree ("name");

GRANT SELECT ON TABLE auth.jwt_secret TO "user";


CREATE FUNCTION auth.url_encode(data bytea) RETURNS text LANGUAGE sql AS $$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$ IMMUTABLE;


CREATE FUNCTION auth.url_decode(data text) RETURNS bytea LANGUAGE sql AS $$
WITH t AS (SELECT translate(data, '-_', '+/') AS trans),
     rem AS (SELECT length(t.trans) % 4 AS remainder FROM t) -- compute padding size
    SELECT decode(
        t.trans ||
        CASE WHEN rem.remainder > 0
           THEN repeat('=', (4 - rem.remainder))
           ELSE '' END,
    'base64') FROM t, rem;
$$ IMMUTABLE;


CREATE FUNCTION auth.algorithm_sign(signables text, secret text, algorithm text)
RETURNS text LANGUAGE sql AS $$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END AS id)  -- hmac throws error
SELECT auth.url_encode(auth.hmac(signables, secret, alg.id)) FROM alg;
$$ IMMUTABLE;


CREATE FUNCTION auth.sign(payload json, secret text, algorithm text DEFAULT 'HS256')
RETURNS text LANGUAGE sql AS $$
WITH
  header AS (
    SELECT auth.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8')) AS data
    ),
  payload AS (
    SELECT auth.url_encode(convert_to(payload::text, 'utf8')) AS data
    ),
  signables AS (
    SELECT header.data || '.' || payload.data AS data FROM header, payload
    )
SELECT
    signables.data || '.' ||
    auth.algorithm_sign(signables.data, secret, algorithm) FROM signables;
$$ IMMUTABLE;


CREATE FUNCTION auth.try_cast_double(inp text)
RETURNS double precision AS $$
  BEGIN
    BEGIN
      RETURN inp::double precision;
    EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
    END;
  END;
$$ language plpgsql IMMUTABLE;


CREATE FUNCTION auth.verify(token text, secret text, algorithm text DEFAULT 'HS256')
RETURNS table(header json, payload json, valid boolean) LANGUAGE sql AS $$
  SELECT
    jwt.header AS header,
    jwt.payload AS payload,
    jwt.signature_ok AND tstzrange(
      to_timestamp(auth.try_cast_double(jwt.payload->>'nbf')),
      to_timestamp(auth.try_cast_double(jwt.payload->>'exp'))
    ) @> CURRENT_TIMESTAMP AS valid
  FROM (
    SELECT
      convert_from(auth.url_decode(r[1]), 'utf8')::json AS header,
      convert_from(auth.url_decode(r[2]), 'utf8')::json AS payload,
      r[3] = auth.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS signature_ok
    FROM regexp_split_to_array(token, '\.') r
  ) jwt
$$ IMMUTABLE;


CREATE FUNCTION auth.create_anon_jwt()
	RETURNS text
	LANGUAGE plpgsql
AS $function$
	DECLARE
		jwt_secret TEXT;
		jwt_expires_in INTERVAL;
		jwt TEXT;
	BEGIN
		jwt_secret := (
			SELECT js."value"
			FROM auth.jwt_secret js 
			WHERE js."name"='postgrest'
		);
		jwt_expires_in := (
			SELECT js."expires_in"
			FROM auth.jwt_secret js 
			WHERE js."name"='postgrest'
		);
		jwt := (
			SELECT auth.sign(
				row_to_json(j),
				jwt_secret,
				'HS256'
			)
			FROM (SELECT 'anon' as "role", md5(random()::text) as nonce) j
		);
		RETURN jwt;
	END;
$function$;