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

WORKDIR /code
RUN pip install -r requirements.txt
RUN pip install -e .

WORKDIR /

# Copy over our designate config
COPY etc/designate /etc/designate

# Get rabbit sorted
RUN /etc/init.d/rabbitmq-server start && \
    rabbitmqctl add_user designate designate && \
    rabbitmqctl set_permissions -p "/" designate ".*" ".*" ".*"

# Get our bind sorted
COPY bind/named.conf.options /etc/bind/named.conf.options
RUN touch /etc/apparmor.d/disable/usr.sbin.named
RUN chown -R bind:bind /var/cache/bind
RUN chown bind:bind /etc/bind/rndc.key

# Get mysql setup
COPY mysql/bind_host.cnf /etc/mysql/conf.d/bind_host.cnf
COPY mysql/setup_databases.sql setup_databases.sql

# NOTE: A new password can be included in the setup_databases.sql
RUN /etc/init.d/mysql start && mysql -u root --password=password < setup_databases.sql
