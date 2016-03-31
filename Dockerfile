FROM ubuntu:14.04

COPY mysql/debconf_selections debconf_selections

RUN debconf-set-selections -v debconf_selections

RUN apt-get update && apt-get install -y \
    python-dev \
    git \
    mysql-server \
    rabbitmq-server \
    wget \
    bind9

RUN apt-get build-dep -y python-lxml

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

RUN pip install --upgrade setuptools

ENV PATH=/venv/bin;$PATH

RUN pip install pymysql dnspython pymemcache pytz

RUN mkdir /code
RUN git clone https://github.com/openstack/designate.git code

# Select version of the code
WORKDIR /code
RUN git reset --hard ${DESIGNATE_VERSION:-6aa43088033393878be0533ab246e86c45e17915}
RUN pip install -r requirements.txt
RUN pip install -e .

WORKDIR /

# Get rabbit sorted
RUN /etc/init.d/rabbitmq-server start && \
    rabbitmqctl add_user designate designate && \
    rabbitmqctl set_permissions -p "/" designate ".*" ".*" ".*"

# Get our bind sorted
COPY bind/named.conf.options /etc/bind/named.conf.options
RUN touch /etc/apparmor.d/disable/usr.sbin.named
RUN chown -R bind:bind /var/cache/bind /etc/bind

# Get slappy sorted
RUN mkdir -p /etc/slappy
COPY bind/slappy /usr/bin/slappy
COPY bind/run-bind-with-agent.sh /usr/bin/run-bind-with-agent.sh
COPY bind/slappy.conf /etc/slappy/slappy.conf

# Get mysql setup
COPY mysql/bind_host.cnf /etc/mysql/conf.d/bind_host.cnf
COPY mysql/setup_databases.sql setup_databases.sql

# Copy over our designate config
COPY etc/designate /etc/designate

# Allow us to specify a custom designate.conf at container build time
ARG DESIGNATE_CONF
COPY ${DESIGNATE_CONF:-etc/designate/designate.conf} /etc/designate/designate.conf

# add a separate designate.conf with localhost for the db connection so we can
# use designate-manage to sync the db even if `mysql` is not in /etc/hosts
RUN sed "s/@mysql/@127.0.0.1/g" /etc/designate/designate.conf > /etc/designate/local-mysql.conf

# NOTE: A new password can be included in the setup_databases.sql
RUN /etc/init.d/mysql start && \
    mysql -u root --password=password < setup_databases.sql && \
    designate-manage --config-file /etc/designate/local-mysql.conf database sync
