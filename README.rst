=====================
 Designate on Carina
=====================

This repo is a set of tools to get OpenStack Designate up and running
on Carina!


Getting Started
===============

If you don't have carina installed, you can run ``make bootstrap`` and
it will try to install the carina client via brew. This is still a
work in progress, so if you run into problems take a look at the
bootstrap target and follow the steps!

Next up you want to ``make cluster-create``. Again see the Makefile for
info. To verify it is up and ready, you can run ``make cluster-info``.

Finally, you can run ``make all``! That will:

- run ``make cluster-creds`` to setup the cluster credentials
- run ``make build-containers`` to build the image(s)
- run ``make start`` to start designate

Hopefully the targets are reasonably self explanatory. The high level
process is to use docker-compose to build the containers based on the
Dockerfile in this repo. ``docker-compose`` will be used to build and
start the services. The ``migrate-db`` task simply sets up the database
schema.

Once things are up, you can run ``make ps`` to see what is running.
To see real-time logs from all services, you can run ``make logs``.


Use the Makefile!
=================

The Makefile is the entry point, but please use it to follow the
links. The information is in the Makefile to help you configure your
shell to use your carina swarm.
