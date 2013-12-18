# Base Fedora 19 Image
FROM mattdm/fedora:f19

MAINTAINER Todd Sanders "tsanders@redhat.com"

# Install Pulp Yum Repository 
RUN cd /etc/yum.repos.d && wget http://repos.fedorapeople.org/repos/pulp/pulp/fedora-pulp.repo

# Install mongo first so it has more time to initialize
RUN yum install -y mongodb-server mongodb pymongo
RUN chkconfig mongod on
RUN service mongod start

RUN sed -i "s/^url: tcp://localhost:5672.*/url: tcp://${HOSTNAME}:5672/" /etc/pulp/server.conf
RUN sed -i "s/^host = localhost.localdomain/host = ${HOSTNAME}/" /etc/pulp/admin/admin.conf

# Get QPIDD Running & autostart
RUN chkconfig qpidd on
RUN service qpidd start

# Wait for Mongodb to initiatize
RUN bash -c 'waitfor "grep 'waiting for connections on port 27017' /var/log/mongodb/mongodb.log" "Waiting for mongodb to finish initialization" 10 30'

# Upgrade Pulp
RUN pulp-manage-db

# Get Apache Running & autostart
RUN chkconfig httpd on
RUN service httpd start

# Expose required Ports
EXPOSE 80 443 5672
