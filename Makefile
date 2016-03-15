VENV := .venv
CARINA_CREDS_YML := .creds.yml
CARINA_CLUSTER_NAME := 'designate'
WITH_CLUSTER := eval `$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina env $(CARINA_CLUSTER_NAME)`
CONTAINER_NAME := 'designate'

bootstrap:
	brew install carina
	virtualenv $(VENV)
	$(VENV)/bin/pip install withenv

create_cluster:
	$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina create $(CARINA_CLUSTER_NAME)


cluster_info:
	$(VENV)/bin/we -e $(CARINA_CREDS_YML) carina get $(CARINA_CLUSTER_NAME)


build_container:
	$(WITH_CLUSTER) && docker build -t $(CONTAINER_NAME) .
