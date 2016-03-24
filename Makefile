SHELL := /bin/bash

VENV := .venv
CARINA_CREDS_YML := .creds.yml
CARINA_CLUSTER_NAME := designate
WITH_CLUSTER := eval `$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina env $(CARINA_CLUSTER_NAME)`
CONTAINER_NAME := designate

help:
	@echo "help               - show help"
	@echo "bootstrap          - setup carina cli, venv, withenv"
	@echo "cluster-create     - create the carina cluster ($(CARINA_CLUSTER_NAME))"
	@echo "cluster-info       - show the carina cluster ($(CARINA_CLUSTER_NAME))"
	@echo "cluster-creds      - download the cluster credentials ($(CARINA_CLUSTER_NAME))"
	@echo "build-containers   - build the designate containers"
	@echo "start              - start all of the designate containers"
	@echo "start-foreground   - same as start, but in the foreground"
	@echo "ps                 - list the containers"
	@echo "ports              - list url:port for the api and bind"

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

build-containers:
	$(WITH_CLUSTER) && docker-compose build

start-foreground:
	$(WITH_CLUSTER) && docker-compose up

start:
	$(WITH_CLUSTER) && docker-compose up -d

all: cluster-creds build-containers start
	@echo 'Everything should be running! Take a look at this Makefile to see '
	@echo 'how to get your credentials working in order to use docker compose '
	@echo 'and swarm together.'

ps:
	$(WITH_CLUSTER) && docker-compose ps

ports:
	@$(WITH_CLUSTER) && echo "API='`docker-compose port api 9001`'"
	@$(WITH_CLUSTER) && echo "BIND_UDP='`docker-compose port --protocol=udp bind 53`'"
	@$(WITH_CLUSTER) && echo "BIND_TCP='`docker-compose port --protocol=tcp bind 53`'"
