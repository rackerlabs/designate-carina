slappy-bind
-----------

This runs Designate with:

- one each of api, central, pool manager, mdns,
- two binds, with the [slappy](https://github.com/rackerlabs/slappy) agent

To get going, move to the top-level directory and do:

    ENV='envs/slappy-bind'
    docker-compose -f base.yml -f "$ENV/designate.yml" -f "$ENV/bind.yml" build
    docker-compose -f base.yml -f "$ENV/designate.yml" -f "$ENV/bind.yml" up -d
