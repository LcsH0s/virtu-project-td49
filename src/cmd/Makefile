CWD := $(shell pwd)

.PHONY: pre-run build start run

all: create-volumes create-networks build run

create-networks:
		docker network create --driver=bridge cats-or-dogs-network --subnet=172.20.0.0/24 || true

create-volumes:
		docker volume create db-data

build:
		docker build -t samlotus/virtu-vote:cmd ./vote/
		docker build -t samlotus/virtu-seed-data:cmd ./seed-data/
		docker build -t samlotus/virtu-result:cmd ./result/
		docker build -t samlotus/virtu-worker:cmd ./worker/

# Creating the containers
run: run-vote run-db run-redis run-result run-worker run-seed-data

run-vote:
		docker rm vote || true
		docker run \
				--network=cats-or-dogs-network \
				--ip 172.20.0.2 \
				--name vote \
				-v "$(CWD)/vote:/usr/local/app" \
				-p 5002:80 \
				-d \
				samlotus/virtu-vote:cmd

run-db:
		docker rm db || true
		docker run \
				--network=cats-or-dogs-network \
				--ip 172.20.0.3 \
				--name db \
				-v db-data:/var/lib/postgresql/data \
				-v "$(CWD)/healthchecks:/healthchecks" \
				--health-cmd="/healthchecks/postgres.sh" \
				--health-interval="5s" \
				-e POSTGRES_PASSWORD=postgres \
				-p 5432:5432 \
				-d \
				postgres:15-alpine

run-redis:
		docker rm redis || true
		docker run \
				--network=cats-or-dogs-network \
				--ip 172.20.0.4 \
				--name redis \
				-v "$(CWD)/healthchecks:/healthchecks" \
				--health-cmd="/healthchecks/redis.sh" \
				--health-interval="5s" \
				-p 6379:6379 \
				-d \
				redis

run-result:
		docker rm result || true
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

run-worker:
		docker rm worker || true
		docker run \
				--network=cats-or-dogs-network \
				--ip 172.20.0.6 \
				--name worker \
				-d \
				samlotus/virtu-worker:cmd

run-seed-data:
		docker rm seed-data || true
		sleep 2
		docker run \
				--network=cats-or-dogs-network \
				--ip 172.20.0.7 \
				--name seed-data \
				-d \
				samlotus/virtu-seed-data:cmd

stop:
		docker stop db redis result vote worker

cleanup:
		docker rm -f vote db redis seed-data result worker || true
		docker volume rm db-data || true
		docker network rm cats-or-dogs-network || true
