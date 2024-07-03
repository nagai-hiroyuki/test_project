FROM nginx:1.25-alpine as production

RUN apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/conf.d/default-production.conf /etc/nginx/conf.d/default.conf
COPY ./conf/conf.d/ssl/ /etc/nginx/conf.d/ssl/

WORKDIR /var/www/

FROM production as local

COPY ./conf/conf.d/default-local.conf /etc/nginx/conf.d/default.conf
