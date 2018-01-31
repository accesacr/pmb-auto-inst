# # Select perl as the base image
#FROM perl:5.20
FROM debian:wheezy

RUN mkdir -p /home/perl

WORKDIR /home/perl/

COPY ./custom_install_scripts/install-site.sh .
COPY ./custom_install_scripts/site-specific-install.sh .
COPY ./custom_install_scripts/install-as-user .

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential locales apt-transport-https
#libpq-dev postgresql-client git apache2 apache2-doc apache2-utils

ENV VERSION_OVERRIDE=master 

RUN sh install-site.sh --default fixmystreet pormibarrio 127.0.0.1.xip.io
