CREATE ROLE anon NOINHERIT;
CREATE ROLE "user" NOINHERIT;
CREATE ROLE "admin" INHERIT;
CREATE ROLE authenticator NOINHERIT;

GRANT "user" TO "admin";

GRANT anon TO authenticator;
GRANT "user" TO authenticator;
GRANT "admin" TO authenticator;
GRANT "admin" TO authenticator;