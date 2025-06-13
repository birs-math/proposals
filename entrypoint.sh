#\!/bin/bash
set -e

echo "Setting system timezone..."
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
echo "tzdata tzdata/Areas select America" > /tmp/tz.txt
if [ "$STAGING_SERVER" == "true" ]; then
  echo "tzdata tzdata/Zones/America select Edmonton" >> /tmp/tz.txt
else
  echo "tzdata tzdata/Zones/America select Vancouver" >> /tmp/tz.txt
fi
debconf-set-selections /tmp/tz.txt
rm -f /etc/timezone
rm -f /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

echo "Starting Rails application..."

cd /home/app/proposals

# Set environment variables
export PATH=/usr/local/rvm/rubies/ruby-2.7.7/bin:$PATH
export RAILS_ENV=development

# Install gems without cache
bundle config set --local cache_path /dev/null
bundle install --no-cache

# Run Rails server
exec bundle exec rails server -b 0.0.0.0 -p 3000