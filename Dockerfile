FROM alpine:edge
MAINTAINER Joris Berthelot <admin@eexit.net>

RUN apk --update add \
  nginx \
  php-fpm \
  php-json \
  php-openssl \
  php-mcrypt \
  php-ctype \
  php-iconv \
  php-posix \
  php-curl \
  php-xml \
  php-zlib \
  supervisor

# PHP-FPM logs destination
RUN mkdir /var/log/php-fpm

# Avoid FastCGI to guess the requested file
RUN sed -ie 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/php.ini

# Do not expose PHP version!
RUN sed -ie 's/expose_php = On/expose_php = Off/g' /etc/php/php.ini

COPY conf/nginx-supervisor.ini /etc/supervisor.d/nginx-supervisor.ini
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/php-fpm.conf /etc/php/php-fpm.conf

COPY vhosts /etc/nginx/sites-enabled/
COPY htdocs /var/www/localhost/htdocs/

EXPOSE 80
CMD ["/usr/bin/supervisord"]
