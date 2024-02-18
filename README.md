# Docker Swarm Stack for Physical Replication of PostgreSQL

Read this in [Russian language](README.ru.md)

## Database Stack

### [The PostgreSql image](https://hub.docker.com/repository/docker/dbulashev/postgres-replication/general) is based on the official [Postgres](https://hub.docker.com/_/postgres) image with the following additions:
- Configurations for physical replication;
- Extension [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html) (dependency of exporter [pg_scv](https://github.com/lesovsky/pgscv));
- Extension [pg_buffercache](https://www.postgresql.org/docs/current/pgbuffercache.html) (dependency of exporter pg_scv);
- Extension [pg_profile](https://github.com/zubkov-andrei/pg_profile);
- Extension [dblink](https://www.postgresql.org/docs/current/dblink.html) (dependency of the extension pg_profile);
- Extension [pgstattuple](https://www.postgresql.org/docs/current/pgstattuple.html) (dependency of the extension pg_csv);
- Extension [pg_stat_kcache](https://github.com/powa-team/pg_stat_kcache) (dependency of the extension pg_profile);
- cron (for periodic sampling by the pg_profile extension, backup target purposes);
- rsyslogd (for collecting logs from cron and exporting to /dev/stdout in the container).

Environment variables of the image:

- `DB_ROLE` can take values primary or secondary;
- `PRIMARY_HOST` specifies the service name with the primary role;
- `REPLICA_SLOT` the name of the replication slot, default replica;
- other variables, from the base image, are described in the [documentation](https://github.com/docker-library/docs/blob/master/postgres/README.md#environment-variables).

Scripts for managing the stack:
- `db0[12]_replication_status.sh` - status of slots and replication;
- `exec_db0[12].sh` - executing a command in the container of services `db01`, `db02`;
- `exec_manage_db01.sh` - executing a command in the `manage_db01` container;
- `logs_db0[12].sh` - logs of services `db01`, `db02`.

Building the image:

* `images/postgres` - image [dbulashev/postgres-replication](https://hub.docker.com/repository/docker/dbulashev/postgres-replication/general) for the database stack.

### Preparing to run the database stack
Specify the variables `POSTGRES_PASSWORD` and `ICU_LOCALE` in the `.env` file.

Create a swarm on two or three nodes.
Add SSH key authorization.

Assign labels `db-host-01` and `db-host-02` on different nodes:

    docker node update --label-add db-host-01=true NODE_1
    docker node update --label-add db-host-02=true NODE_2


On the node labeled `db-host-01` create the `pgdata-db01` directory:

    mkdir /docker-compose/pgdata-db01


On the node labeled `db-host-02` create the `pgdata-db02` directory:

    mkdir /docker-compose/pgdata-db02


Deploy the stack with the following command:

    ./stack-deploy.sh


The node labeled `db-host-01` will act as the primary, and the node labeled `db-host-02` will act as the secondary.

To switch roles, that is, to make the `db02` service primary and the `db01` service secondary, execute the following two commands sequentially:

    ./promote-db02.sh
    ./swithover_db01.sh


## Monitoring Stack

Event notifications are sent to the Telegram chat. Grafana is accessible on port 3999.

- Grafana;
- VictoriaMetrics;
- vmagent (metrics collection);
- Alertmanager (sending notifications to Telegram chat);
- pg_scv agent;
- pg_exporter agent.

Alerts:
- Awesome [Prometheus alerts / postgres-exporter](https://raw.githubusercontent.com/samber/awesome-prometheus-alerts/master/dist/rules/postgresql/postgres-exporter.yml);
- a set by VictoriaMetrics ([alerts-vmagent](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/deployment/docker/alerts-vmagent.yml), [alerts-vmalert](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/deployment/docker/alerts-vmalert.yml), [alerts-vmhealth](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/deployment/docker/alerts-health.yml), [alerts-vmsingle](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/deployment/docker/alerts.yml));
- Other alerts based on postgres-exporter metrics and the book [Lesovsky A. V. Monitoring PostgreSQL](https://postgrespro.ru/education/books/monitoring).

Dashboards:
- Lock tree based on the query [postgres.ai Lock tree](https://postgres.ai/blog/20211018-postgresql-lock-trees);
- [Consolidated report](https://github.com/dataegret/pg-utils/blob/master/sql/global_reports/query_stat_total_13.sql) by Data Erget based on pg_stat_statements;
- Using pgSCV metrics based on [pgSCV: PostgreSQL (https://grafana.com/grafana/dashboards/14540-pgscv-postgresql/), [postgresql-monitoring-book/unofficial/dashboards](https://github.com/lesovsky/postgresql-monitoring-book/blob/main/playground/grafana/provisioning/dashboards/unofficial/pgSCV.json);
- [PostgreSQL Exporter](https://grafana.com/grafana/dashboards/12485-postgresql-exporter/);
- pg_profile io/summary/visualization/waits [dashboards v4.3](https://github.com/zubkov-andrei/pg_profile/releases);
- [VictoriaMetrics - vmalert](https://grafana.com/grafana/dashboards/14950-victoriametrics-vmalert/);
- [VictoriaMetrics - vmagent](https://grafana.com/grafana/dashboards/12683-victoriametrics-vmagent/);
- [VictoriaMetrics - single-node](https://grafana.com/grafana/dashboards/10229-victoriametrics-single-node/).


### Deploying Monitoring Stack

Specify the `GRAFANA_PASSWORD` variable in the `.env` file.
Specify the bot token (`bot_token`) and Telegram chat ID (`chat_id`) in the `alertmanager/alertmanager.yml` file.

Deploy the stack using the command:

`./stack-deploy-monitoring.sh`

## Cron Stack

Used for sampling by the pg_profile extension (every 30 minutes).

Deploy the stack using the command:

`./stack-deploy-cron.sh`

