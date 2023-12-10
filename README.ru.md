# Docker Swarm Стек физической репликации PostgreSQL

Создайте swarm на двух или трех нодах.
Добавьте авторизацию по ssh ключу.

Проставьте метки `db-host-01` и `db-host-02` на разных нодах:

    docker node update --label-add db-host-01=true NODE_1
    docker node update --label-add db-host-02=true NODE_2

На ноде с меткой `db-host-01` создайте `pgdata-db01` каталог

`mkdir /docker-compose/pgdata-db01`

На ноде с меткой `db-host-02` создайте `pgdata-02` каталог

`mkdir /docker-compose/pgdata-db02`

Нода с меткой `db-host-01` будет ведущей, с меткой `db-host-02` ведомой.

Чтобы поменять роли местами, т.е. сделать сервис db02 ведущим, а db01 ведомым, выполните последовательно две команды:

    ./promote-db02.sh
    ./swithover_db01.sh

---

* `images/postgres` - сборка образа [dbulashev/postgres-replication](https://hub.docker.com/repository/docker/dbulashev/postgres-replication/general) для стека
* `db0[12]_replication_status.sh` - статус слотов и репликации
* `exec_db0[12].sh` - скрипт запуска команды в контейнере сервисов `db01`, `db02`
* `exec_manage_db01.sh` - скрипт запуска команды в контейнере `manage_db01`
* `logs_db0[12].sh` - логи сервисов `db01`, `db02`
