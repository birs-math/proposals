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

if [ ! -e /usr/local/rvm/gems/ruby-2.7.7 ]; then
  echo
  echo "Create gemset..."
  gpg --keyserver keys.openpgp.org --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  /usr/bin/curl -sSL https://get.rvm.io | bash -s stable
  bash -lc 'rvm --default use ruby-2.7.7'
  /usr/local/rvm/bin/rvm gemset create ruby-2.7.7
  /usr/local/rvm/bin/rvm gemset use ruby-2.7.7@global
  /usr/local/rvm/bin/rvm cleanup all
  /usr/local/rvm/bin/rvm reload
fi

echo
echo "Ruby version:"
ruby -v

echo
echo "Node version:"
node --version

echo
echo "Yarn version:"
yarn --version

#echo
#echo "Installing latest bundler..."
#/usr/local/rvm/bin/rvm-exec 2.7.7 gem install bundler

if [ ! -e /usr/local/rvm/gems/ruby-2.7.7/gems/rails-6.1.4.1 ]; then
  echo
  echo "Installing Rails 6.1.4.1..."
  #su - app -c "cd /home/app/proposals; /usr/local/rvm/bin/rvm-exec 2.7.7 gem install rails -v 6.1.4.1"
fi

if [ ! -e /home/app/proposals/bin ]; then
  echo
  echo "Starting new rails app..."
  su - app -c "cd /home/app; rails new proposals"
fi

#echo
#echo "Bundle install..."
#su - app -c "cd /home/app/proposals; /usr/local/rvm/gems/default/bin/bundle install"

#echo
#echo "Bundle update..."
#su - app -c "cd /home/app/proposals; /usr/local/rvm/gems/default/bin/bundle update"

root_owned_files=`find /usr/local/rvm/gems -user root -print`
if [ -z "$root_owned_files" ]; then
  echo
  echo "Changing gems to non-root file permissions..."
  chown app:app -R /usr/local/rvm/gems
fi

if [ -e /home/app/proposals/db/migrate ]; then
  echo
  echo "Running migrations..."
  echo "this in prod migrations section"
  cd /home/app/proposals
  SECRET_KEY_BASE=token DB_USER=$DB_USER DB_PASS=$DB_PASS
  rake db:migrate RAILS_ENV=production
  rake db:migrate RAILS_ENV=development
  rake db:migrate RAILS_ENV=test
fi

if [ ! -e /home/app/proposals/config/webpacker.yml ]; then
  echo "Installing Webpacker..."
  su - app -c "cd /home/app/proposals; SECRET_KEY_BASE=token bundle exec rails webpacker:install"

  echo
  echo "Turbo install..."
  su - app -c "cd /home/app/proposals; SECRET_KEY_BASE=token bundle exec rails turbo:install"
  echo "Done!"
  echo
fi

if [ ! -e /home/app/proposals/app/assets/stylesheets/actiontext.scss ]; then
  echo "Setting up ActionText..."
  su - app -c "cd /home/app/proposals; bin/rails action_text:install"
  echo
  echo "Done!"
fi

if [ "$RAILS_ENV" == "production" ]; then
  echo
  echo "Updating file permissions..."
  chown app:app -R /home/app/proposals
fi

echo
echo "Compiling Assets..."
chmod 755 /home/app/proposals/node_modules
su - app -c "cd /home/app/proposals; yarn install"

if [ "$RAILS_ENV" == "production" ]; then
  echo "this in prod rails section"
  su - app -c "cd /home/app/proposals; RAILS_ENV=production SECRET_KEY_BASE=token bundle exec rake assets:precompile --trace"
  su - app -c "cd /home/app/proposals; yarn"

  # Update release tag
  rake birs:release_tag
fi

echo
echo "Running: webpack --verbose --progress..."
su - app -c "cd /home/app/proposals; bin/webpack --verbose --progress"
echo
echo "Done compiling assets!"

if [ "$APPLICATION_HOST" == "localhost" ]; then
  echo
  echo "Launching webpack-dev-server..."
  su - app -c "cd /home/app/proposals; RAILS_ENV=development SECRET_KEY_BASE=token bundle exec bin/webpack-dev-server &"
fi

echo
echo "Starting web server..."
bundle exec passenger start
