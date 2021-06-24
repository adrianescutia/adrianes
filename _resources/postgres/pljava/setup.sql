ALTER DATABASE ades SET pljava.libjvm_location TO '/usr/lib/jvm/java-11-openjdk-amd64/lib/server/libjvm.so';
CREATE EXTENSION pljava;

CREATE FUNCTION getsysprop(VARCHAR) 
  RETURNS VARCHAR
  AS 'java.lang.System.getProperty'
  LANGUAGE java;

SELECT array_agg(getsysprop(p)) FROM (values
('org.postgresql.pljava.version'),
('org.postgresql.version'),
('java.version'),
('os.name'),
('os.arch')
) AS props(p);
-- PL/Java version, i.e.: {1.6.2,"11.11 (Debian 11.11-1.pgdg90+1)",11.0.6,Linux,amd64}