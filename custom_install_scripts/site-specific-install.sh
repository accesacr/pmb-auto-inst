#!/bin/sh

# Set this to the version we want to check out
VERSION=${VERSION_OVERRIDE:-v1.3}

PARENT_SCRIPT_URL=https://github.com/mysociety/commonlib/blob/master/bin/install-site.sh

misuse() {
  echo The variable $1 was not defined, and it should be.
  echo This script should not be run directly - instead, please run:
  echo   $PARENT_SCRIPT_URL
  exit 1
}

# Strictly speaking we don't need to check all of these, but it might
# catch some errors made when changing install-site.sh

[ -z "$DIRECTORY" ] && misuse DIRECTORY
[ -z "$UNIX_USER" ] && misuse UNIX_USER
[ -z "$REPOSITORY" ] && misuse REPOSITORY
[ -z "$REPOSITORY_URL" ] && misuse REPOSITORY_URL
[ -z "$BRANCH" ] && misuse BRANCH
[ -z "$SITE" ] && misuse SITE
[ -z "$DEFAULT_SERVER" ] && misuse DEFAULT_SERVER
[ -z "$HOST" ] && misuse HOST
[ -z "$DISTRIBUTION" ] && misuse DISTRIBUTION
[ -z "$VERSION" ] && misuse VERSION
[ -z "$DEVELOPMENT_INSTALL" ] && misuse DEVELOPMENT_INSTALL

#add_locale cy_GB
#add_locale nb_NO
#add_locale de_CH

install_postfix

if [ ! "$DEVELOPMENT_INSTALL" = true ]; then
    echo 'inside nginx'
    install_nginx
    add_website_to_nginx
    # Check out the current released version
    su -l -c "cd '$REPOSITORY' && git checkout '$VERSION' && git submodule update" "$UNIX_USER"
fi
echo "before install_website_packages"
install_website_packages
echo "before su"
su -l -c "touch '$DIRECTORY/admin-htpasswd'" "$UNIX_USER"
echo "before add_postgres_user"
add_postgresql_user
echo "before DEVELOPMENT_INSTALL"
export DEVELOPMENT_INSTALL
$REPOSITORY/bin/cpanm Catalyst::ScriptRunner
$REPOSITORY/bin/cpanm Geo::JSON
su -c "$REPOSITORY/bin/install-as-user '$UNIX_USER' '$HOST' '$DIRECTORY'" "$UNIX_USER"
echo "before if DEV INSTALL sysv"
if [ ! "$DEVELOPMENT_INSTALL" = true ]; then
    echo "inside install_sysvinit_script"
    #install_sysvinit_script
fi
echo "before if DEFAULT INSTALL ec2"
if [ $DEFAULT_SERVER = true ] && [ x != x$EC2_HOSTNAME ]
then
    echo "inside dev install ec2"
    # If we're setting up as the default on an EC2 instance,
    # make sure the ec2-rewrite-conf script is called from
    # /etc/rc.local
    # overwrite_rc_local
fi
echo 'END of site-specific-install.sh'
# Tell the user what to do next:

echo Installation complete - you should now be able to view the site at:
echo   http://$HOST/
echo Or you can run the tests by switching to the "'$UNIX_USER'" user and
echo running: $REPOSITORY/bin/cron-wrapper prove -r t
