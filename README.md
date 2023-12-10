# Docker Swarm Stack for Physical Replication of PostgreSQL

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


---

* `images/postgres` - building the image [dbulashev/postgres-replication](https://hub.docker.com/repository/docker/dbulashev/postgres-replication/general) for the stack
* `db0[12]_replication_status.sh` - slot status and replication
* `exec_db0[12].sh` - script to run a command inside the db01, db02 services container
* `exec_manage_db01.sh` - script to run a command inside the manage_db01 container
* `logs_db0[12].sh` - logs for the db01, db02 services