
database.schema.table

Shows schema that will be used for any tables or other named objects that are created without specifying a target schema.
SHOW search_path;

The search path can be altered at run time. The command is:
SET search_path TO schema [, schema, ...]
SET search_path TO myschema,public;

SHOW default_tablespace;

SELECT * FROM pg_language WHERE lanname like 'java%';

SELECT has_table_privilege('myschema.mytable', 'select');


## pSQL Commands

List of installed extensions
\dx

List of schemas
\dn

List of relations
\d

List of functions
\df