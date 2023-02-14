#!/bin/sh
 
# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.
#
# If you have user-specific configurations you would like
# to apply, you may also create user-customizations.sh,
# which will be run after this script.
 
sudo apt-get update && \
    apt-get install -y \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    # git \
    # libicu-dev \
    # libpng-dev \
    # libpq-dev \
    # libzip-dev \
    php-bcmath \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-mysql \
    php-pgsql \
    php-sqlite3 \
    php-xml \
    php-zip \
    unzip
 
# Set up MySQL
mysql -u homestead -psecret -e "create database bitpanda_testing;"
mysql -u homestead -psecret -e "create database operation_rules_testing;"
mysql -u homestead -psecret -e "SET GLOBAL explicit_defaults_for_timestamp = 1;"
mysql -u homestead -psecret -e "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));"
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u homestead -psecret mysql
 
# Set up PostgreSQL
sudo systemctl start postgresql.service
sudo -u postgres psql -c "create user admin_api with encrypted password 'admin_api';"
sudo -u postgres psql -c "create database admin_api;"
sudo -u postgres psql -c "alter database admin_api owner to admin_api;"
 
# Run migrations
(cd ~/code/flywaydb; for i in sql/*; do echo "Running" $i; mysql -u homestead -psecret bitpanda_testing < $i; done)
(cd ~/code/operation-rules; php artisan migrate)
 
# Install Kafka & Redis
sudo pecl install rdkafka redis
sudo apt-get install -y php-rdkafka php-redis
 
# If these tests pass, all others should pass too
echo "Verifying setup..."
cd ~/code/admin-api
./vendor/bin/phpunit tests/Feature/ApproveFiatWalletTransaction/Test.php
./vendor/bin/phpunit tests/Feature/ListOperationRulesFiltered/Test.php
