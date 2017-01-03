#!/bin/bash

CONTAINER_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
CONTAINER_NAME=$(echo $HOSTNAME)

echo $CONTAINER_IP "  " $CONTAINER_NAME $CONTAINER_NAME".localdomain" > /etc/hosts
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1 localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "fe00::0 ip6-localnet" >> /etc/hosts
echo "ff00::0 ip6-mcastprefix" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts

# Setup Drupal settings
/bin/cp "/opt/ci/templates/settings.php" "/var/www/sites/default/settings.php"
/bin/chmod 444 "/var/www/sites/default/settings.php"
/bin/chown www-data:1000 "/var/www/sites/default/settings.php"

/bin/cp "/opt/ci/templates/settings.$DRUPAL8_REF.php" "/var/www/sites/default/settings.$DRUPAL8_REF.php"
/bin/chmod 444 "/var/www/sites/default/settings.$DRUPAL8_REF.php"
/bin/chown www-data:1000 "/var/www/sites/default/settings.$DRUPAL8_REF.php"

/bin/chmod +x /opt/ci/*.sh
/bin/chmod +x /opt/ci/releases/*.sh

# Start the crontab
/bin/cp /opt/ci/crontab /etc/cron.d/drupal
/bin/chmod 644 /etc/cron.d/drupal
/bin/chmod +x /opt/ci/cron.sh
/usr/bin/crontab /etc/cron.d/drupal

service_index=$(curl -s http://rancher-metadata/2015-12-19/self/container/service_index)

# Run deploy script on the first service instance only (useful for running
# database commands on a cloud environment).
if [ "$service_index" == "1" ]; then
  /opt/ci/_run_once.sh
fi

# Run deploy script on every service instance.
/opt/ci/_run.sh
