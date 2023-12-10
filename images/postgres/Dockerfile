# syntax=docker/dockerfile:1
ARG IMAGE_MAJOR_VERSION="16"
FROM postgres:${IMAGE_MAJOR_VERSION}-bullseye
ENV DEBIAN_FRONTEND=noninteractive
COPY scripts/sql_snippet.sh /usr/local/bin/
COPY scripts/sql_snippet_x.sh /usr/local/bin/
COPY scripts/init.sh /docker-entrypoint-initdb.d/init.sh
COPY scripts/replica-entrypoint.sh /usr/local/bin/
COPY scripts/pg_rewind_from_server.sh /usr/local/bin/
COPY scripts/sanitize_postgresql.conf.sh /usr/local/bin/
RUN mkdir /snippets
COPY snippets/* /snippets/
EXPOSE 5432
