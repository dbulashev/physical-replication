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
COPY scripts/pg_profile_take_sample.sh /usr/local/bin/

RUN mkdir /snippets
COPY snippets/* /snippets/

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    wget \
    postgresql-16-pg-stat-kcache \
    cron \
    rsyslog \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/zubkov-andrei/pg_profile/releases/download/4.4/pg_profile--4.4.tar.gz
RUN tar xzf pg_profile--4.4.tar.gz --directory $(pg_config --sharedir)/extension
RUN rm pg_profile--4.4.tar.gz

COPY configs/rsyslog.conf /etc/rsyslog.d/console.conf

EXPOSE 5432
