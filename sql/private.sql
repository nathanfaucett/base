CREATE SCHEMA "private";

GRANT USAGE ON SCHEMA "private" TO "user";


CREATE TABLE "private"."user" (
	id serial4 NOT NULL,
	"role" varchar(255) NOT NULL DEFAULT 'user',
	username varchar(255) NOT NULL,
	encrypted_password varchar(71) NOT NULL,
	active boolean NOT NULL DEFAULT true,
	confirmed boolean NOT NULL DEFAULT false,
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT user_pk PRIMARY KEY (id)
);
CREATE UNIQUE INDEX user_username_uindex ON "private"."user" USING btree (username);

GRANT ALL ON TABLE "private"."user" TO "user";


CREATE TABLE "private".email (
	id serial4 NOT NULL,
	user_id serial4 NOT NULL,
	email varchar(320) NOT NULL,
	"primary" boolean NOT NULL DEFAULT false,
	confirmed boolean NOT NULL DEFAULT false,
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT email_pk PRIMARY KEY (id),
	CONSTRAINT email_user_id_fk FOREIGN KEY (user_id) REFERENCES "private"."user"(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX email_user_id_email_uindex ON "private"."email" USING btree (user_id, email);

GRANT ALL ON TABLE "private".email TO "user";


INSERT INTO "private"."user" 
	("role", username, encrypted_password, confirmed) 
	VALUES ('admin', 'admin', auth.crypt('admin', auth.gen_salt('bf')), true);


CREATE FUNCTION "private".pgrst_watch() RETURNS event_trigger
  LANGUAGE plpgsql
  AS $$
BEGIN
  NOTIFY pgrst, 'reload schema';
END;
$$;


CREATE EVENT TRIGGER pgrst_watch
  ON ddl_command_end
  EXECUTE PROCEDURE "private".pgrst_watch();