#\!/bin/bash
set -e

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