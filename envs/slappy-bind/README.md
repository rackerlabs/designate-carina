slappy-bind
-----------

This runs Designate with:

- one each of api, central pool manager, mdns,
- two binds, with the [slappy](https://github.com/rackerlabs/slappy) agent

To get going, move to the top-level directory and do:

    docker-compose -f dockerfiles/slappy-bind/docker-compose.yml
