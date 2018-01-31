# # Select perl as the base image
#FROM perl:5.20
FROM debian:wheezy

RUN mkdir -p /home/perl

WORKDIR /home/perl/

COPY ./custom_install_scripts/install-site.sh .
COPY ./custom_install_scripts/site-specific-install.sh .
COPY ./custom_install_scripts/install-as-user .
COPY ./auto-executed-within-container-when-starting.sh .

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential locales apt-transport-https
#libpq-dev postgresql-client git apache2 apache2-doc apache2-utils

ENV VERSION_OVERRIDE=master 

RUN sh install-site.sh --default fixmystreet pormibarrio 127.0.0.1.xip.io

# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD ["sh", "/home/perl/auto-executed-within-container-when-starting.sh"]
