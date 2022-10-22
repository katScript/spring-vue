FROM node:16

RUN npm install -g @vue/cli

RUN mkdir -p /etc/nginx/html /var/www/html /var/www/html/views /sock \
  && chown -R node:node /etc/nginx /var/www /sock

USER node:node

VOLUME /var/www

WORKDIR /var/www/html/views
EXPOSE 9001