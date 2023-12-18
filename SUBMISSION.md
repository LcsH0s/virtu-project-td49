
#  App Deployment Guide

  

This guide provides step-by-step instructions to deploy two versions of your app: the CMD version, using only docker commands, and the COMP version, using a docker-compose.yml file.
> These two versions will be addressed and CMD and COMP versions though this guide.

## Images
All custom images used in this repository can be found on Docker Hub :
- [vote image](https://hub.docker.com/repository/docker/samlotus/virtu-vote/general)
- [worker image](https://hub.docker.com/repository/docker/samlotus/virtu-worker/general)
- [result image](https://hub.docker.com/repository/docker/samlotus/virtu-result/general)
- [seed-data image](https://hub.docker.com/repository/docker/samlotus/virtu-seed-data/generall)

##  CMD Version Deployment

###  Prerequisites

- Ensure that the docker engine is installed on your system. See [here](https://docs.docker.com/engine/install/) for instructions.

###  Run (using Makefile)

1. Clone the repository:

```bash
git clone https://github.com/LcsH0s/virtu-project-td49.git
cd virtu-project-td49/src/cmd/
```

2. Build and run containers:
```bash
make
```

### Run (Manually)
1. Clone the repository:
```bash
git clone https://github.com/LcsH0s/virtu-project-td49.git
cd virtu-project-td49/src/cmd/
```

2. Create database volume:
```bash
docker volume create db-data
```

3. Create docker network:
```bash
docker network create --driver=bridge cats-or-dogs-network --subnet=172.20.0.0/24
```

4. Build images (skip if you wish to use Docker Hub images):
```bash
docker build -t samlotus/virtu-vote:cmd ./vote/
docker build -t samlotus/virtu-seed-data:cmd ./seed-data/
docker build -t samlotus/virtu-result:cmd ./result/
docker build -t samlotus/virtu-worker:cmd ./worker/
```

5. Start db container:
```bash
docker run \
	--network=cats-or-dogs-network \
	--ip 172.20.0.3 \
	--name db \
	-v db-data:/var/lib/postgresql/data \
	-v "$(pwd)/healthchecks:/healthchecks" \
	--health-cmd="/healthchecks/postgres.sh" \
	--health-interval="5s" \
	-e POSTGRES_PASSWORD=postgres \
	-p 5432:5432 \
	-d \
	postgres:15-alpine
```

6. Start redis container:
```bash
docker run \
	--network=cats-or-dogs-network \
	--ip 172.20.0.4 \
	--name redis \
	-v "$(pwd)/healthchecks:/healthchecks" \
	--health-cmd="/healthchecks/redis.sh" \
	--health-interval="5s" \
	-p 6379:6379 \
	-d \
	redis
```

7. Start vote container:
```bash
docker run \
	--network=cats-or-dogs-network \
	--ip 172.20.0.2 \
	--name vote \
	-v "$(pwd)/vote:/usr/local/app" \
	-p 5002:80 \
	-d \
	samlotus/virtu-vote:cmd
```

8. Start worker container:
```bash
docker run \
	--network=cats-or-dogs-network \
	--ip 172.20.0.6 \
	--name worker \
	-d \
	samlotus/virtu-worker:cmd
```

9. Start result container:
```bash
docker run \
	--network=cats-or-dogs-network \
	--ip 172.20.0.5 \
	--name result \
	--health-cmd="curl -f http://localhost/ || exit 1" \
	--health-interval="30s" \
	-p 5001:80 \
	-p 127.0.0.1:9229:9229 \
	-d \
	samlotus/virtu-result:cmd
```

10. Start seed-data container:
```bash
docker run \
	--network=cats-or-dogs-network \
	--ip 172.20.0.7 \
	--name seed-data \
	-d \
	samlotus/virtu-seed-data:cmd
```

### Stop containers
##### Using Makefile
```bash
make stop
```

##### Manually
```bash
docker stop db redis result vote worker
```

### Cleanup
#### Using Makefile
```bash
make cleanup
```

#### Manually
```bash
docker rm -f vote db redis seed-data result worker
docker volume rm db-data
docker network rm cats-or-dogs-network
```

##  COMP Version Deployment

###  Prerequisites

- Ensure that the docker engine is installed on your system. See [here](https://docs.docker.com/engine/install/) for instructions.

- Ensure that docker compose is installed on your system.

###  Run 

1. Clone the repository:

```bash
git clone https://github.com/LcsH0s/virtu-project-td49.git
cd virtu-project-td49/src/comp/
```

2. Compose build and run containers:
```bash
# This command can take a few minutes to complete. Please don't interrupt.
docker compose up --buid -d
```

### Stop containers
#### Manually
```bash
docker compose down
```


##  Accessing the App

Once the deployment is complete, wait a few moments for the containers to startup. You can access your app here :
- **Vote page :** http://\<docker-host\>:5002
- **Results page :** http://\<docker-host\>:5001
 
