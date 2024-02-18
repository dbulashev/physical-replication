# Docker Swarm стек физической репликации PostgreSQL и мониторинга

## Стек баз данных

### [Образ PostgreSql](https://hub.docker.com/repository/docker/dbulashev/postgres-replication/general) основан на официальном образе [Postgres](https://hub.docker.com/_/postgres) с дополнениями:
- Настройки для физической репликации.
- Расширение [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html) (зависимость экспортера [pg_scv](https://github.com/lesovsky/pgscv))
- Расширение [pg_buffercache](https://www.postgresql.org/docs/current/pgbuffercache.html) (зависимость экспортера pg_scv)
- Расширение [pg_profile](https://github.com/zubkov-andrei/pg_profile)
- Расширение [dblink](https://www.postgresql.org/docs/current/dblink.html) (зависимость расширения pg_profile)
- Расширение [pgstattuple](https://www.postgresql.org/docs/current/pgstattuple.html) (зависимость расширения pg_csv)
- Расширение [pg_stat_kcache](https://github.com/powa-team/pg_stat_kcache) (зависимость расширения pg_profile)
- cron (для периодического сбора сэмплов расширением pg_profile, целей резервного копирования)
- rsyslogd (для сбора логов от cron и экспорта в /dev/stdout контейнера)

Переменные окружения образа:

- `DB_ROLE` может принимать значения `primary` или `secondary`
- `PRIMARY_HOST` указывает имя сервиса с ролью `primary`
- `REPLICA_SLOT` имя слота репликации, по умолчанию `replica`
- остальные переменные, от базового образа описаны в [документации](https://github.com/docker-library/docs/blob/master/postgres/README.md#environment-variables)

Скрипты для обслуживания стека:
- `db0[12]_replication_status.sh` - статус слотов и репликации
- `exec_db0[12].sh` - запуск команды в контейнере сервисов `db01`, `db02`
- `exec_manage_db01.sh` - запуск команды в контейнере `manage_db01`
- `logs_db0[12].sh` - логи сервисов `db01`, `db02`

Сборка образа:

* `images/postgres` - образ [dbulashev/postgres-replication](https://hub.docker.com/repository/docker/dbulashev/postgres-replication/general) для стека баз данных.

### Подготовка к запуску стека базы данных
В файле `.env` укажите переменные `POSTGRES_PASSWORD` и `ICU_LOCALE`.

Создайте swarm на двух или трех нодах.
Добавьте авторизацию по ssh ключу.

Проставьте метки `db-host-01` и `db-host-02` на разных нодах:

    docker node update --label-add db-host-01=true NODE_1
    docker node update --label-add db-host-02=true NODE_2

На ноде с меткой `db-host-01` создайте `pgdata-db01` каталог

`mkdir /docker-compose/pgdata-db01`

На ноде с меткой `db-host-02` создайте `pgdata-02` каталог

`mkdir /docker-compose/pgdata-db02`

Задеплойте стек командой 

`./stack-deploy.sh`

Нода с меткой `db-host-01` будет ведущей, с меткой `db-host-02` ведомой.

Чтобы поменять роли местами, т.е. сделать сервис db02 ведущим, а db01 ведомым, выполните последовательно две команды:

    ./promote-db02.sh
    ./swithover_db01.sh

## Стек мониторинга

Уведомления о событиях приходят в Telegram chat. Grafana доступна на порту 3999.

- Grafana;
- VictoriaMetrics;
- vmagent (сбор метрик);
- Alertmanager (отправка уведомлений в Telegram chat);
- агент pg_scv;
- агент pg_exporter.  

**Алерты:**
- [Awesome Prometheus alerts / postgres-exporter](https://raw.githubusercontent.com/samber/awesome-prometheus-alerts/master/dist/rules/postgresql/postgres-exporter.yml)
- комплект от VictoriaMetrics ([alerts-vmagent](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/deployment/docker/alerts-vmagent.yml), [alerts-vmalert](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/deployment/docker/alerts-vmalert.yml), [alerts-vmhealth](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/deployment/docker/alerts-health.yml), [alerts-vmsingle](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/deployment/docker/alerts.yml));
- Другие алерты, основанные на метриках postgres-exporter и книги [Лесовский А. В. Мониторинг PostgreSQL](https://postgrespro.ru/education/books/monitoring)

**Дашборды:**
- Дерево блокировок на основе запроса [postgres.ai Lock tree](https://postgres.ai/blog/20211018-postgresql-lock-trees);
- [Сводный отчёт](https://github.com/dataegret/pg-utils/blob/master/sql/global_reports/query_stat_total_13.sql) от Data Erget на основе pg_stat_statements;
- По метрикам pgSCV на основе [pgSCV: PostgreSQL](https://grafana.com/grafana/dashboards/14540-pgscv-postgresql/), [postgresql-monitoring-book/unofficial/dashboards](https://github.com/lesovsky/postgresql-monitoring-book/blob/main/playground/grafana/provisioning/dashboards/unofficial/pgSCV.json);
- [PostgreSQL Exporter](https://grafana.com/grafana/dashboards/12485-postgresql-exporter/);
- pg_profile io/summary/visualization/waits [dashboards v4.3](https://github.com/zubkov-andrei/pg_profile/releases);
- [VictoriaMetrics - vmalert](https://grafana.com/grafana/dashboards/14950-victoriametrics-vmalert/);
- [VictoriaMetrics - vmagent](https://grafana.com/grafana/dashboards/12683-victoriametrics-vmagent/);
- [VictoriaMetrics - single-node](https://grafana.com/grafana/dashboards/10229-victoriametrics-single-node/);


### Деплой стека мониторинга

В файле `.env` укажите переменную `GRAFANA_PASSWORD`.
В файле `alertmanager/alertmanager.yml` укажите токен боте (`bot_token`) и идентификатор чата (`chat_id`) Telegram.

Задеплойте стек командой 

`./stack-deploy-monitoring.sh`

## Стек cron

Используется для сбора сэмплов расширения pg_profile (каждые 30 минут).

Задеплойте стек командой

`./stack-deploy-cron.sh`

