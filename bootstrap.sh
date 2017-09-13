#!/bin/sh -x

# This script is for bootstrapping puppet on a Blimpy machine

export PATH=/var/lib/gems/1.8/bin:$PATH

function provision_ubuntu() {
    which puppet

    if [ $? -ne 0 ]; then
        deb="puppetlabs-release-precise.deb"
        wget "http://apt.puppetlabs.com/${deb}"
        dpkg -i ./${deb}
        apt-get update
        apt-get install -y puppet
    fi
}

function provision_rhel() {
    which puppet

    if [ $? -ne 0 ]; then
        rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
        yum install -y puppet
    fi

}

function provision_rabbitmq () {
  rabbitmqadmin declare queue --vhost="/" name=Listing durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=PAYMENT_ENGINE_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=iOS_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=PAYMENT_ENGINE durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=iOS durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=TestListenerVerticle_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=TestVerticle_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=Email_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=ApiBulkQueue durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=ApiServerResponseQueue durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=Notification durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=Email durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=Android_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=Health_Check durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=MASS_DATA durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=ApiServerRequestQueue durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=Windows durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=TestVerticle durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=Android durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=TestListenerVerticle durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="/" name=ResourceMessageDispatch durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=Listing durable=true -u guest -p guest name=Notification durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=PAYMENT_ENGINE_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=iOS_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=PAYMENT_ENGINE durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=iOS durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=TestListenerVerticle_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=TestVerticle_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=Email_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=ApiBulkQueue durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=ApiServerResponseQueue durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=Notification durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=Email durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=Android_Retry_Later durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=Health_Check durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=MASS_DATA durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=ApiServerRequestQueue durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=Windows durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=TestVerticle durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=Android durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=TestListenerVerticle durable=true -u guest -p guest
  rabbitmqadmin declare queue --vhost="vertx" name=ResourceMessageDispatch durable=true -u guest -p guest
}

grep -i "ubuntu" /etc/issue
if [ $? -eq 0 ]; then
    provision_ubuntu;
fi;

grep -i "red hat" /etc/issue
if [ $? -eq 0 ]; then
    provision_rhel
fi;

# Install all our stupid dependencies
for module in "stdlib" "apt" "java"; do
    ls /etc/puppet/modules | grep $module

    if [ $? -ne 0 ]; then
        # Didn't find the module, install it!
        puppet module install puppetlabs/${module}
    else
        echo ">> ${module} already installed"
    fi;
done;

platform=`facter lsbdistid`

# Set up a symbolic link to make sure we can include our $PWD as the "jenkins"
# module for `puppet apply`
ln -s $PWD /etc/puppet/modules/jenkins

echo "Setting up RabbitMQ"
provision_rabbitmq

echo ">> Provision for ${platform}"
puppet apply --verbose --modulepath=/etc/puppet/modules tests/${platform}.pp
