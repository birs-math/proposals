#!/bin/bash
set -e

echo
echo "Welcome to OS:"
uname -v
cat /etc/issue

echo
echo "Setting system timezone..."
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
echo "tzdata tzdata/Areas select America" > /tmp/tz.txt
if [ "$STAGING_SERVER" == "true" ]; then
  echo "tzdata tzdata/Zones/America select Edmonton" >> /tmp/tz.txt
else
  echo "tzdata tzdata/Zones/America select Vancouver" >> /tmp/tz.txt
fi

debconf-set-selections /tmp/tz.txt
rm /etc/timezone
rm /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

echo
echo "Ruby version:"
ruby -v

echo
echo "Node version:"
node --version

echo
echo "Yarn version:"
yarn --version

root_owned_files=`find /usr/local/rvm/gems -user root -print`
if [ "$root_owned_files" ]; then
  echo
  echo "Changing gems to non-root file permissions..."
  chown app:app -R /usr/local/rvm/gems
fi

if [ -e /home/app/proposals/db/migrate ]; then
  echo
  echo "Running migrations..."
  bundle exec rails db:migrate
fi

if [ $RAILS_ENV == "production" ]; then
  echo
  echo "Compiling Assets..."
  su - app -c "SECRET_KEY_BASE=$SECRET_KEY_BASE bundle exec rails assets:precompile --trace"
  # Update release tag
  rake birs:release_tag
fi

echo
echo "Running: webpack --verbose --progress..."
su - app -c "bin/webpack --verbose --progress"
echo
echo "Done compiling assets!"

if [ $RAILS_ENV == "development" ]; then
  echo
  echo "Launching webpack-dev-server..."
  su - app -c "SECRET_KEY_BASE=$SECRET_KEY_BASE bundle exec bin/webpack-dev-server &"
fi

echo
echo "Starting web server..."
bundle exec passenger start
