# # Select perl as the base image
FROM perl:5.26

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client

# Define where our application will live inside the image
ENV PMB_ROOT /home/pormibarrio

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p /home/tmp/pids

# Set our working directory inside the image
WORKDIR /home

# Copy the PMB application into place
COPY . .

# Define where our application will live inside the image
WORKDIR $PMB_ROOT

# Manually modify official repo packages list and install
RUN cp conf/packages.debian-jessie conf/packages.debian-jessie-pmbcr
#RUN sed -i '/postgresql-server-dev/d' ./conf/packages.debian-jessie-pmbcr
RUN sed -i '/postgresql/d' ./conf/packages.debian-jessie-pmbcr

RUN xargs -a conf/packages.debian-jessie-pmbcr apt-get -y install


# Manually set perl env variables
RUN PATH='/home/pormibarrio/bin:/home/pormibarrio/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games'
RUN PERL5LIB='/home/pormibarrio/perllib:/home/pormibarrio/commonlib/perllib:/home/pormibarrio/local/lib/perl5'
RUN PERL_LOCAL_LIB_ROOT='/home/pormibarrio/local'
RUN PERL_MB_OPT='--install_base "/home/pormibarrio/local"'
RUN PERL_MM_OPT='INSTALL_BASE=/home/pormibarrio/local'
RUN PS1="(fms) $PS1"

#RUN eval `perl setenv.pl`

# Install perl dependencies
RUN bin/install_perl_modules
RUN bin/cpanm Module::Pluggable
RUN bin/cpanm Geo::JSON
RUN bin/make_css




# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
#CMD [ "config/containers/app_cmd.sh" ]
#CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
