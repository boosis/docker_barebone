FROM phusion/baseimage:0.9.16

# Ensure UTF-8
RUN locale-gen en_US.UTF-8

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV HOME /root

CMD ["/sbin/my_init"]

RUN apt-get update -y
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim curl wget build-essential python-software-properties
RUN add-apt-repository -y ppa:nginx/stable
RUN add-apt-repository -y ppa:ondrej/php5
RUN apt-get update -y
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes php5-cli php5-fpm php5-curl php5-gd php5-mcrypt php5-intl php5-dev php-pear
RUN no ""|pecl install mongo-alpha
RUN echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini && cd /etc/php5/cli/conf.d && ln -s ../../mods-available/mongo.ini 20-mongo.ini && cd /etc/php5/fpm/conf.d && ln -s ../../mods-available/mongo.ini 20-mongo.ini
RUN pecl install xdebug
ADD xdebug.ini /etc/php5/mods-available/xdebug.ini
RUN cd /etc/php5/cli/conf.d && ln -s ../../mods-available/xdebug.ini 20-xdebug.ini && cd /etc/php5/fpm/conf.d && ln -s ../../mods-available/xdebug.ini 20-xdebug.ini

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -qq nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf

RUN sed -i "0,/;error_log =.*/s//error_log = \/var\/log\/php_errors.log/" /etc/php5/fpm/php.ini
RUN sed -i "0,/;error_log =.*/s//error_log = \/var\/log\/php_errors.log/" /etc/php5/cli/php.ini

RUN usermod -u 1000 www-data
RUN usermod -G staff www-data

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
