FROM nginx:1.18
MAINTAINER Tunq <katforscript@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
RUN export DEBIAN_FRONTEND

RUN groupadd -g 1000 app \
 && useradd -g 1000 -u 1000 -d /var/www -s /bin/bash app

RUN touch /var/run/nginx.pid

RUN mkdir /sock

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    curl \
    git \
    wget \
    gzip \
    libbz2-dev \
    libfreetype6-dev \
    libicu-dev \
    libmcrypt-dev \
    libpng-dev \
    libssh2-1-dev \
    libxslt1-dev \
    libzip-dev \
    lsof \
    default-mysql-client \
    vim \
    procps \
    zip

RUN mkdir -p /usr/share/man/man1  \
    && apt-get install -y default-jre default-jdk

RUN wget https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -P /tmp \
    && tar xf /tmp/apache-maven-*.tar.gz -C /opt && rm /tmp/apache-maven-*.tar.gz \
    && ln -s /opt/apache-maven-* /opt/maven

ENV M2_HOME /opt/maven
ENV MAVEN_HOME /opt/maven
ENV SPRING_JAR_NAME springboot-service

RUN export M2_HOME
RUN export MAVEN_HOME
RUN export SPRING_JAR_NAME

ENV PATH ${M2_HOME}/bin:${PATH}

RUN export PATH

RUN mkdir /etc/nginx/certs /etc/nginx/certs/site /etc/nginx/certs/api \
  && echo -e "\n\n\n\n\n\n\n" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/site/nginx.key -out /etc/nginx/certs/site/nginx.crt \
  && echo -e "\n\n\n\n\n\n\n" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/api/nginx.key -out /etc/nginx/certs/api/nginx.crt

RUN mkdir /tmp/springboot-service
COPY ./env/springboot.sh /tmp/springboot-service/

RUN ( \
  cd /usr/local/bin/ \
  && curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 -o mkcert \
  && chmod +x mkcert \
  )

COPY ./conf/nginx.conf /etc/nginx/
COPY ./conf/default.conf /etc/nginx/conf.d/

RUN mkdir -p /etc/nginx/includes
COPY conf/nodejs/nginx.nodejs.conf /etc/nginx/includes/
COPY conf/api/nginx.api.conf /etc/nginx/includes/

RUN mkdir -p /etc/nginx/html /var/www/html \
  && chown -R app:app /etc/nginx /var/www /var/cache/nginx /var/run/nginx.pid /sock

EXPOSE 8443

USER app:app

VOLUME /var/www

WORKDIR /var/www/html
