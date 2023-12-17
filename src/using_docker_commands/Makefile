.PHONY: pre-run build create start

# Pre-Run
# TODO: ajouter create-networks a la fin
pre-run: create-volumes build create start

create-networks: check-front-tier check-back-tier check-cats-or-dogs-network

check-front-tier:
		@if [ -z "$$(docker network ls --filter name=front-tier -q)" ]; then \
				echo "Creating Docker network: front-tier"; \
				docker network create --driver=bridge front-tier --subnet=172.19.0.0/24; \
		else \
				echo "Docker network front-tier already exists"; \
		fi

check-back-tier:
		@if [ -z "$$(docker network ls --filter name=back-tier -q)" ]; then \
				echo "Creating Docker network: back-tier"; \
				docker network create --driver=bridge back-tier --subnet=172.19.1.0/24; \
		else \
				echo "Docker network back-tier already exists"; \
		fi

check-cats-or-dogs-network:
		@if [ -z "$$(docker network ls --filter name=cats-or-dogs-network -q)" ]; then \
				echo "Creating Docker network: cats-or-dogs-network"; \
				docker network create --driver=bridge cats-or-dogs-network --subnet=172.19.2.0/24; \
		else \
				echo "Docker network cats-or-dogs-network already exists"; \
		fi


create-volumes:
		docker volume create db-data

build:
		docker build -t vote:latest ./vote/
		docker build -t seed-data:latest ./seed-data/
		docker build -t result:latest ./result/
		docker build -t worker:latest ./worker/

# Creating the containers
create: cleanup create-vote create-db create-redis create-result create-worker

cleanup:
		docker rm -f vote db redis seed-data result worker || true
		docker volume rm db-data

create-vote:
		docker rm vote || true
		docker create --name vote -v "/root/virtu-project-td49/src/vote:/usr/local/app" -p 5002:80 --network=cats-or-dogs-network vote

create-db:
		docker create \
				--network=cats-or-dogs-network \
				--name db \
				-v db-data:/var/lib/postgresql/data \
				-v "/root/virtu-project-td49/src/healthchecks:/healthchecks" \
				--health-cmd="/healthchecks/postgres.sh" \
				--health-interval="5s" \
				-e POSTGRES_PASSWORD=postgres \
				-p 5432:5432 \
				postgres:15-alpine

create-redis:
		docker create \
				--network=cats-or-dogs-network \
				--name redis \
				-v "/root/virtu-project-td49/src/healthchecks:/healthchecks" \
				--health-cmd="/healthchecks/redis.sh" \
				--health-interval="5s" \
				-p 6379:6379 \
				redis

create-result:
		docker create \
				--name result \
				--health-cmd="curl -f http://localhost/ || exit 1" \
				--health-interval="30s" \
				-v /root/virtu-project-td49/src/result:/usr/local/app \
				-p 5001:80 \
				-p 127.0.0.1:9229:9229 \
				--network=cats-or-dogs-network \
				result:latest

create-worker:
		docker create \
				--network=cats-or-dogs-network \
				--name worker \
				worker:latest

run-seed-data:
		docker rm seed-data || true
		docker run \
				--network=cats-or-dogs-network \
				--name seed-data \
				seed-data:latest


# Starting the containers
start: start-vote start-db start-redis start-worker start-result

start-vote:
		docker start vote

start-db:
		docker start db

start-redis:
		docker start redis

start-worker:
		docker start worker

start-result:
		docker start result

stop:
		docker stop db redis result vote worker

