VENV := .venv
CARINA_CREDS_YML := .creds.yml
CARINA_CLUSTER_NAME := 'designate'
WITH_CLUSTER := eval `$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina env $(CARINA_CLUSTER_NAME)`
CONTAINER_NAME := 'designate'

bootstrap:
	brew install carina
	virtualenv $(VENV)
	$(VENV)/bin/pip install withenv

create-cluster:
	$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina create $(CARINA_CLUSTER_NAME)


cluster-info:
	$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina get $(CARINA_CLUSTER_NAME)

build-containers:
	$(WITH_CLUSTER) && docker-compose build


start-backend:
	$(WITH_CLUSTER) && docker-compose start bind mysql rabbit memcached zookeeper

migrate-db:
	$(WITH_CLUSTER) && docker-compose run central designate-manage database sync
	$(WITH_CLUSTER) && docker-compose run central designate-manage pool-manager-cache sync

start-designate-foreground:
	$(WITH_CLUSTER) && docker-compose up api central mdns poolmanager zonemanager

start-designate:
	$(WITH_CLUSTER) && docker-compose start api central mdns poolmanager zonemanager

all: build-containers start-backend migrate-db start-designate
	@echo 'Everything should be running! Take a look at this Makefile to see '
	@echo 'how to get your credentials working in order to use docker compose '
	@echo 'and swarm together.'

ps:
	$(WITH_CLUSTER) && docker-compose ps

ports:
	@echo "API: `docker-compose port api 9001`"
	@echo "BIND (udp): `docker-compose port --protocol=udp bind 53`"
	@echo "BIND (tcp): `docker-compose port --protocol=tcp bind 53`"
