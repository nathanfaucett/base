CREATE ROLE anon NOINHERIT;
CREATE ROLE "user" NOINHERIT;
CREATE ROLE "admin" NOINHERIT;
CREATE ROLE authenticator NOINHERIT;

GRANT anon TO authenticator;
GRANT "user" TO authenticator;
GRANT "admin" TO authenticator;