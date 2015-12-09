# Alpine-Nginx-PHP-FPM

Inspired by [dydx/alpine-nginx-phpfpm](https://github.com/dydx/alpine-nginx-phpfpm), I updated the configuration in order to fit my needs.

It works out of the box: clone, paste your code, change 2-3 settings, builds and you're set.

## Features

### Logs

Logs are managed/rotated by [Supervisor](http://supervisord.org/) and are in:

- Nginx: `/var/log/nginx/[access|error].log`
- PHP: `var/log/php-fpm/error.log`
- Supervisor: `/var/log/supervisord.log`

### Nginx

- Expires headers on most common static MIME types
- Access denied for all dot-files/directories
- Access granted for `/robot.txt`
- Gzip enabled
- Hidden server token

### PHP

Based on the production-ready [configuration file](), I just set these new settings:

#### 1. `/etc/php/php.ini`

- `cgi.fix_pathinfo = 1` → `cgi.fix_pathinfo = 0`
- `expose_php = On` → `expose_php = Off`

#### 2. `/etc/php/php-fpm.conf`

- `error_log = /var/log/php-fpm.log` → `error_log = /dev/stderr`
- `daemonize = yes` → `daemonize = no`
- `listen = 127.0.0.1:9000` → `listen = [::]:9000`
- `catch_workers_output = no` → `catch_workers_output = yes`

## Usage

Let's suppose I want to run my [resume](https://github.com/eexit/joris.me):

    $ git clone git@github.com:eexit/alpine-nginx-phpfpm.git resume
    $ cd resume/htdocs
    $ git clone git@github.com:eexit/joris.me.git .

### Nginx configuration

Now, you might want to tweak the `vhost/default.conf` file to reflect what you need. It's already pretty standard but if you have extra rules to add...

Typically, if your project public-facing directory is a sub-directory of `htdocs`, you might want to append your public-facing directory to the `root` setting of `vhost/default.conf`:

    root /var/www/localhost/htdocs/public;

#### Extra virtual hosts

For my Websites, I usually try to keep a single entry point by either redirecting the `www.` sub-domain to the non `www.` or the opposite. That's the reason why I added the `vhost/redirect.conf` server configuration.

Edit the `vhost/redirect.conf` file if you have redirection rules for your projects. For instance, I want `www.joris.me` to be redirected to `joris.me` and even more, any sub-domains:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name *.joris.me;
    return 301 $scheme://joris.me$request_uri;
}
```
You can add as many `.conf` files in the `vhosts` directory and they will all be  copied into the `/etc/nginx/sites-enabled` directory of the container.

### Run the container

    $ docker build -t joris.me .
    $ docker run -dp 80:80 --name=joris.me joris.me
    
That's it.

    $ http --headers $(docker-machine ip default)
    HTTP/1.1 200 OK
    Cache-Control: public, max-age=5184000, s-maxage=5184000, must-revalidate, proxy-revalidate
    Connection: keep-alive
    Content-Encoding: gzip
    Content-Type: text/html;charset=UTF-8
    Date: Wed, 09 Dec 2015 19:02:25 GMT
    Expires: Sun, 07 Feb 2016 20:02:25 +0100
    Last-Modified: Wed, 09 Dec 2015 19:52:14 +0100
    Pragma: public
    Server: nginx
    Transfer-Encoding: chunked