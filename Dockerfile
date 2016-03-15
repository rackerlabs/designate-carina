FROM ubuntu:14.04

COPY mysql/debconf_selections debconf_selections
RUN debconf-set-selections -v debconf_selections

RUN apt-get update && apt-get install -y \
    python-pip \
    python-virtualenv \
    git \
    mysql-server \
    rabbitmq-server \
    bind9

RUN apt-get build-dep -y python-lxml

RUN pip install pymysql dnspython pymemcache

RUN mkdir /code
RUN git clone https://github.com/openstack/designate.git code

WORKDIR /code
RUN pip install -e .

# Get rabbit sorted
RUN /etc/init.d/rabbitmq-server start && \
    rabbitmqctl add_user designate designate && \
    rabbitmqctl set_permissions -p "/" designate ".*" ".*" ".*"

# Get our bind sorted
COPY dev/named.conf.options /etc/bind/named.conf.options
RUN touch /etc/apparmor.d/disable/usr.sbin.named
RUN chown -R bind:bind /var/cache/bind
RUN chown bind:bind /etc/bind/rndc.key
