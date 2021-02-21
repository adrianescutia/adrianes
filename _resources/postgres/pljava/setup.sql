--ALTER SYSTEM SET pljava.libjvm_location TO '/usr/lib/jvm/java-11-openjdk-amd64/lib/server/libjvm.so';
ALTER DATABASE ades SET pljava.libjvm_location TO '/usr/lib/jvm/java-11-openjdk-amd64/lib/server/libjvm.so';
CREATE EXTENSION pljava;

-- Creating a function
CREATE FUNCTION getsysprop(VARCHAR) 
  RETURNS VARCHAR
  AS 'java.lang.System.getProperty'
  LANGUAGE java;

-- SELECT getsysprop('user.home');
-- Getting error: access denied ("java.util.PropertyPermission" "user.home" "read")
-- FIXME: Configure java security?

-- What PL/Java version is installed?
SELECT array_agg(getsysprop(p)) FROM (values
('org.postgresql.pljava.version'),
('org.postgresql.version'),
('java.version'),
('os.name'),
('os.arch')
) AS props(p);
-- {1.6.2,"11.11 (Debian 11.11-1.pgdg90+1)",11.0.6,Linux,amd64}