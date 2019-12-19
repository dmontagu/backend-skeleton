FROM postgres:11

COPY ./container-scripts/init-db.sql /docker-entrypoint-initdb.d/01-init-db.sql
