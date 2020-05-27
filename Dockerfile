FROM wyveo/nginx-php-fpm:latest as base

# Set up code
WORKDIR /usr/share/nginx/html
COPY . .

# install dependencies and configure php
RUN ./scripts/setup

FROM base as worker

CMD ["php", "artisan", "queue:work", "--daemon"]

FROM worker as web
# nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# self-signed ssl certificate for https support
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=GB/ST=London/L=London/O=NA/CN=localhost" \
    && openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 \
    && mkdir /etc/nginx/snippets
COPY self-signed.conf /etc/nginx/snippets/self-signed.conf
COPY ssl-params.conf /etc/nginx/snippets/ssl-params.conf

# Starting nginx server
CMD ["/start.sh"]