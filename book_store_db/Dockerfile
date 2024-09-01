FROM mysql:9

ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=bookstoredb
ENV MYSQL_USER=myuser
ENV MYSQL_PASSWORD=mypassword

COPY sql_scripts/ /docker-entrypoint-initdb.d/

# Configurar o MySQL para usar utf8mb4 por padrão
RUN echo "[mysqld]\ncharacter-set-server=utf8mb4\ncollation-server=utf8mb4_unicode_ci\n[client]\ndefault-character-set=utf8mb4" > /etc/mysql/conf.d/charset.cnf

