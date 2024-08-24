FROM mysql:9

ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=bookstoredb
ENV MYSQL_USER=myuser
ENV MYSQL_PASSWORD=mypassword

COPY sql_scripts/ /docker-entrypoint-initdb.d/