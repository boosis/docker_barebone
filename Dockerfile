FROM phusion/baseimage:0.9.16

# Ensure UTF-8
RUN locale-gen en_US.UTF-8

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV HOME /root

CMD ["/sbin/my_init"]

ADD xdebug.ini /etc/php5/mods-available/xdebug.ini
RUN apt-get update -y && \
    apt-get install -y vim curl wget build-essential python-software-properties && \
    add-apt-repository -y ppa:nginx/stable && \
    add-apt-repository -y ppa:ondrej/php5-5.6 && \
    apt-get update -y && \
    apt-get install -y --force-yes nginx php5-cli php5-fpm php5-curl php5-gd php5-mcrypt php5-intl php5-dev php-pear php5-mysql php5-xdebug && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    no ""|pecl install mongo-alpha && \
    echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini && \
    cd /etc/php5/cli/conf.d && \
    ln -s ../../mods-available/mongo.ini 20-mongo.ini && \
    cd /etc/php5/fpm/conf.d && \
    ln -s ../../mods-available/mongo.ini 20-mongo.ini && \
    sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini && \
    sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
    touch /var/log/php_errors.log && \
    chmod 777 /var/log/php_errors.log && \
    sed -i "0,/;error_log =.*/s//error_log = \/var\/log\/php_errors.log/" /etc/php5/fpm/php.ini && \
    sed -i "0,/;error_log =.*/s//error_log = \/var\/log\/php_errors.log/" /etc/php5/cli/php.ini && \
    usermod -u 1000 www-data && usermod -G staff www-data && \
    cd /etc/php5/cli/conf.d && \
    ln -s ../../mods-available/xdebug.ini 20-xdebug.ini && \
    cd /etc/php5/fpm/conf.d && \
    ln -s ../../mods-available/xdebug.ini 20-xdebug.ini