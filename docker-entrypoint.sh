#!/bin/bash
set -e

if [ ! -f /etc/nginx/certs/dhparam.pem ]; then
	mkdir -p /etc/nginx/certs
    openssl dhparam -out /etc/nginx/certs/dhparam.pem 2048
fi

if [ "$1" = 'nginx' ]; then

    # fix permissions and ownership of /var/cache/pagespeed
    mkdir -p -m 755 /var/cache/tmp
    chown -R nginx:nginx /var/cache/tmp
    chown -R nginx:nginx /var/cache/nginx/client_temp

    exec "$@"
fi

exec "$@"

