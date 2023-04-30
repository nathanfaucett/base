CREATE VIEW public."user" AS
SELECT id, "role", username, active, confirmed, created_at, updated_at
FROM "private"."user";

GRANT ALL ON TABLE public."user" TO "user";


CREATE VIEW public.email AS
SELECT id, user_id, email, "primary", confirmed, created_at, updated_at
FROM "private"."email";

GRANT ALL ON TABLE public.email TO "user";


CREATE FUNCTION public.user_sign_up(p_username text, p_password text, p_password_confirmation text)
	RETURNS text
	LANGUAGE plpgsql
AS $function$
	DECLARE
		sub BIGINT;
		email TEXT;
		jwt_secret TEXT;
		jwt_expires_in INTERVAL;
		jwt TEXT;
	BEGIN
		IF p_username IS NULL THEN
			RAISE EXCEPTION 'username:required';
		END IF;
		IF LENGTH(p_username) < 1 THEN 
			RAISE EXCEPTION 'username:minlength:1';
		END IF;
		IF p_password IS NULL THEN
			RAISE EXCEPTION 'password:required';
		END IF;
		IF LENGTH(p_password) < 6 THEN 
			RAISE EXCEPTION 'password:minlength:6';
		END IF;
		IF p_password_confirmation IS NULL THEN
			RAISE EXCEPTION 'password_confirmation:required';
		END IF;
		IF p_password != p_password_confirmation THEN
			RAISE EXCEPTION 'password,password_confirmation:mismatch';
		END IF;
		IF EXISTS (SELECT u.id FROM public."user" u WHERE u.username=p_username) THEN
			RAISE EXCEPTION 'username:exists';
		END IF;

		SET ROLE "user";

		INSERT INTO "private"."user" 
			(username, encrypted_password) 
			VALUES (p_username, auth.crypt(p_password, auth.gen_salt('bf')));
		
		sub := (
			SELECT u.id 
			FROM "private"."user" u 
			WHERE u.username=p_username 
			LIMIT 1
		);
		email := (
			SELECT e.email 
			FROM public.email e 
			WHERE e.user_id=sub and e.primary=true
			LIMIT 1
		);
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
			FROM (
				SELECT 
					sub::text as sub,
					email,
					(SELECT u.role FROM "private"."user" u WHERE u.id=sub) as "role",
					md5(random()::text) as nonce,
					extract(epoch from (now() + jwt_expires_in)) as exp
			) j
		);

		RETURN jwt;
	END;
$function$;

GRANT EXECUTE ON FUNCTION public.user_sign_up(p_username text, p_password text, p_password_confirmation text) TO anon;


CREATE FUNCTION public.user_sign_in(p_username text, p_password text)
	RETURNS text
	LANGUAGE plpgsql
AS $function$
	DECLARE
		sub BIGINT;
		email TEXT;
		jwt_secret TEXT;
		jwt_expires_in INTERVAL;
		jwt TEXT;
	BEGIN
		SET ROLE "user";

		sub := (
			SELECT u.id
			FROM "private"."user" u
			WHERE u.username=p_username AND u.encrypted_password=auth.crypt(p_password, u.encrypted_password)
			LIMIT 1
		);
		IF sub IS NULL THEN
			RETURN NULL;
		END IF;

		email := (
			SELECT e.email 
			FROM "private".email e 
			WHERE e.user_id=sub and e.primary=true
			LIMIT 1
		);
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
			FROM (
				SELECT 
					sub::text as sub,
					email,
					(SELECT u.role FROM "private"."user" u WHERE u.id=sub) as "role",
					md5(random()::text) as nonce,
					extract(epoch from (now() + jwt_expires_in)) as exp
			) j
		);

		RETURN jwt;
	END;
$function$;

GRANT EXECUTE ON FUNCTION public.user_sign_in(p_username text, p_password text) TO anon;


CREATE FUNCTION public.user_reset_password(p_username text, p_old_password text, p_password text, p_password_confirmation text)
	RETURNS text
	LANGUAGE plpgsql
AS $function$
	DECLARE
		sub BIGINT;
		email TEXT;
		jwt_secret TEXT;
		jwt_expires_in INTERVAL;
		jwt TEXT;
	BEGIN
		IF p_username IS NULL THEN
			RAISE EXCEPTION 'username:required';
		END IF;
		IF LENGTH(p_username) < 1 THEN 
			RAISE EXCEPTION 'username:minlength:1';
		END IF;
		IF p_old_password IS NULL THEN
			RAISE EXCEPTION 'old_password:required';
		END IF;
		IF p_password IS NULL THEN
			RAISE EXCEPTION 'password:required';
		END IF;
		IF LENGTH(p_password) < 6 THEN 
			RAISE EXCEPTION 'password:minlength:6';
		END IF;
		IF p_password_confirmation IS NULL THEN
			RAISE EXCEPTION 'password_confirmation:required';
		END IF;
		IF p_password != p_password_confirmation THEN
			RAISE EXCEPTION 'password,p_password_confirmation:mismatch';
		END IF;
		IF EXISTS (SELECT u.id FROM "private"."user" u WHERE u.username=p_username) THEN
			RAISE EXCEPTION 'username:exists';
		END IF;

		sub := (
			SELECT u.id
			FROM "private"."user" u
			WHERE u.username=p_username AND u.encrypted_password=auth.crypt(p_old_password, u.encrypted_password)
			LIMIT 1
		);
		IF sub IS NULL THEN
			RETURN NULL;
		END IF;

		UPDATE "private"."user" SET encrypted_password=auth.crypt(p_password, auth.gen_salt('bf')) WHERE id=sub;
		
		email := (
			SELECT e.email 
			FROM "private".email e 
			WHERE e.user_id=sub and e.primary=true
			LIMIT 1
		);
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
			FROM (
				SELECT 
					sub::text as sub,
					email,
					(SELECT u.role FROM "private"."user" u WHERE u.id=sub) as "role",
					md5(random()::text) as nonce,
					extract(epoch from (now() + jwt_expires_in)) as exp
			) j
		);

		RETURN jwt;
	END;
$function$;

GRANT EXECUTE ON FUNCTION 
	public.user_reset_password(p_username text, p_old_password text, p_password text, p_password_confirmation text) TO "user";


GRANT ALL ON ALL TABLES IN SCHEMA public TO "admin";
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO "admin";