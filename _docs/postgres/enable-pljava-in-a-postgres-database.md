---
title: Enable PL/Java in a Postgres database
description: >-
  Extension for PostgreSQL™ that allows stored procedures, triggers, and functions 
  to be written in the Java™ language and executed in the backend.
tags: 
    - Postgres
    - Java
    - Docker
---

# PL/Java: stored procedures, triggers, and functions for PostgreSQL™

You can use PL/Java to implement store procedures in Java.

In this document I describe how to deploy and setup a Postgres database with one of the dockerized 
prebuild packages I have generated:

* Postgres 11
* Java 11
* PL/Java 1.6.2

## Dockerized PL/Java

Adapt this [stack](https://labs.play-with-docker.com/?stack={{site.url}}/resources/postgres/pljava/docker-compose.yaml) 
as per your convenience, then, run `docker stack deploy -c docker-compose.yaml postgres` or 
`docker-compose -f docker-compose.yaml up --detach`, wait for it to initialize completely, and visit 
http://swarm-ip:9000, http://localhost:9000, or http://host-ip:9000 (as appropriate).

The PWD button below allows you to deploy the stack and test if this is what you expect.

```yaml
services:

  db:
    image: adrianescutia/postgres11-pljava-jdk:1.6.2
    restart: always
    environment:
      - POSTGRES_DB=ades
      - POSTGRES_USER=ades
      - POSTGRES_PASSWORD=supersecretpwd

  adminer:
    image: adminer
    depends_on:
      - db
    restart: always
    ports:
      - 9000:8080
```

[![Try in PWD](https://raw.githubusercontent.com/play-with-docker/stacks/master/assets/images/button.png)](https://play-with-docker.com/?stack={{site.url}}/resources/postgres/pljava/docker-compose.yaml)

**Issues with PWD?** See troubleshooting below.

You will have to set `pljava.libjvm_location` and create the java extension, to make 
this configuration use the [SQL in our resources](/resources/postgres/pljava/setup.sql), either, in Adminer UI, or executing following commands:

```s
curl {{site.url}}/resources/postgres/pljava/setup.sql -o setup.sql
# Execute the SQL in the database container
#cat ./setup.sql | docker exec -i <container-name> psql -U <user> -d <database>
cat ./setup.sql | docker exec -i pljava_db_1 psql -U ades -d ades
```

**NOTE:** Be sure to update the database name accordingly.

## Custom functions

1. Copy your Java archives (JAR files) to the same directory on all Database hosts. i.e.: $HOME/pljava/.
2. Install the JAR file:  
  `SELECT sqlj.install_jar('file:///`_/var/lib/postgresql/share/postgresql/pljava/pljava-hello.jar_`', 'hello', true);`
3. Set the _pljava_classpath_ server configuration parameter. For example:  
  `SELECT sqlj.set_classpath('javatest', 'hello');`
4. Create Function
```sql
CREATE FUNCTION sayHi()
  RETURNS void
   AS 'com.test.Hello.sayHi'
   LANGUAGE java;
```
5. Test function
   `select sayHi();`

I hope you find this document helpful. Thanks!

## Troubleshooting

If the PWD stack doesn't start.

1. Start a new session.
2. Click the link "Add New Instance"
3. Drag and Drop the file from your desktop.
   1. Other option is to get the file with `curl`: `curl https://adrianescutia.github.io/adrianes/resources/postgres/pljava/docker-compose.yaml -o docker-compose.yaml`

The caveat with curl is that you need to type the full address!! It doesn't support copy/paste (at least not when I tested).

![File upload](https://i2.wp.com/www.docker.com/blog/wp-content/uploads/pwd_upload-1.gif?resize=710%2C406&ssl=1)  
Source: [The best way to learn Docker for Free: Play-With-Docker (PWD)](https://www.docker.com/blog/best-way-learn-docker-free-play-docker-pwd/)

## References

* https://www.postgresql.org/docs/11/sql-createtrigger.html
* [PL/Java](https://tada.github.io/pljava/) project docs.
* [The best way to learn Docker for Free: Play-With-Docker (PWD)](https://www.docker.com/blog/best-way-learn-docker-free-play-docker-pwd/)

If there is a specific version you require, you need to [Build PL/Java](https://tada.github.io/pljava/build/build.html) 
and install your own version as per your requirements (Postgres and Java version).

 