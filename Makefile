SHELL := /bin/bash

VENV := .venv
CARINA_CREDS_YML := .creds.yml
CARINA_CLUSTER_NAME := designate
# use WITH_CLUSTER := true, to run containers locally rather than on carina
WITH_CLUSTER := eval `$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina env $(CARINA_CLUSTER_NAME)`
COMPOSE_FILES := -f base.yml -f envs/slappy-bind/designate.yml -f envs/slappy-bind/bind.yml

help:
	@echo "help               - show help"
	@echo "bootstrap          - setup carina cli, venv, withenv"
	@echo "cluster-create     - create the carina cluster ($(CARINA_CLUSTER_NAME))"
	@echo "cluster-info       - show the carina cluster ($(CARINA_CLUSTER_NAME))"
	@echo "cluster-creds      - download the cluster credentials ($(CARINA_CLUSTER_NAME))"
	@echo "docker-info        - show node info about your cluster"
	@echo "build-containers   - build the designate containers"
	@echo "start              - start all of the designate containers"
	@echo "start-foreground   - same as start, but in the foreground"
	@echo "stop               - stop all of the designate containers"
	@echo "rm                 - remove stopped containers"
	@echo "ps                 - list the containers"
	@echo "logs               - display logs from all containers"
	@echo "ports              - list url:port for the api"

bootstrap:
	brew install carina
	virtualenv $(VENV)
	$(VENV)/bin/pip install withenv

cluster-create:
	$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina create --wait $(CARINA_CLUSTER_NAME)

cluster-info:
	$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina get $(CARINA_CLUSTER_NAME)

cluster-creds:
	$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina credentials $(CARINA_CLUSTER_NAME)

docker-info:
	$(WITH_CLUSTER) && docker info

build-containers:
	$(WITH_CLUSTER) && docker-compose $(COMPOSE_FILES) build

start-foreground:
	$(WITH_CLUSTER) && docker-compose $(COMPOSE_FILES) up

start:
	$(WITH_CLUSTER) && docker-compose $(COMPOSE_FILES) up -d

logs:
	$(WITH_CLUSTER) && docker-compose $(COMPOSE_FILES) logs

stop:
	$(WITH_CLUSTER) && docker-compose $(COMPOSE_FILES) down

rm:
	$(WITH_CLUSTER) && docker-compose $(COMPOSE_FILES) rm

all: cluster-creds build-containers start
	@echo 'Everything should be running! Take a look at this Makefile to see '
	@echo 'how to get your credentials working in order to use docker compose '
	@echo 'and swarm together.'

ps:
	$(WITH_CLUSTER) && docker-compose $(COMPOSE_FILES) ps

ports:
	@$(WITH_CLUSTER) && echo "API='`docker-compose port api 9001`'"
