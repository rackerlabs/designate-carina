#!/bin/bash

/etc/init.d/mysql start
/etc/init.d/rabbitmq-server start
designate-central --config-file /etc/designate/local-mysql.conf &
sleep 5
designate-manage --config-file /etc/designate/local-mysql.conf \
    pool update --file /etc/designate/pools.yml
