# os
FROM php:7.2.2-apache

# about us
MAINTAINER Ney Frota <ney@frota.net>
LABEL version="0.1"
LABEL description="frota.net filerun implementation"

# copy our files
COPY app /app

# build
RUN ["/bin/bash", "/app/bin/docker/build.sh"]

# expose ports
EXPOSE 80
EXPOSE 443

# make it rain
ENTRYPOINT ["/app/bin/docker/entrypoint.sh"]
