# See: https://github.com/phusion/passenger-docker
# Latest image versions:
# https://github.com/phusion/passenger-docker/blob/master/CHANGELOG.md
FROM phusion/passenger-ruby27:1.0.12

ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Yarn package
RUN curl -sS https://raw.githubusercontent.com/yarnpkg/releases/gh-pages/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Postgres
RUN curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update -qq && apt-get dist-upgrade --yes && \
  apt-get install --yes pkg-config apt-utils build-essential cmake automake \
  && apt-get upgrade --fix-missing --yes --allow-remove-essential \
  -o Dpkg::Options::="--force-confold"

RUN apt-get install --yes tzdata udev locales curl git gnupg ca-certificates \
    libpq-dev wget libxrender1 libxext6 libsodium23 libsodium-dev nc

# NodeJS 10
RUN curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install --yes nodejs yarn

# Cleanup
RUN apt-get clean && apt-get autoremove --yes \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use en_CA.utf8 as our locale
RUN locale-gen en_CA.utf8
ENV LANG en_CA.utf8
ENV LANGUAGE en_CA:en
ENV LC_ALL en_CA.utf8



# Container uses 999 for docker user
RUN /usr/sbin/usermod -u 999 app

#ADD rails-env.conf /etc/nginx/main.d/rails-env.conf
#RUN chmod 644 /etc/nginx/main.d/rails-env.conf
ENV APP_HOME /home/app/proposals
# disabled because we mount host directory in $APP_HOME
ADD . $APP_HOME
WORKDIR $APP_HOME
RUN /usr/local/rvm/bin/rvm-exec 2.7.2 gem install bundler
RUN bundle install
RUN RAILS_ENV=development bundle exec rails webpacker:install
RUN RAILS_ENV=development bundle exec rails turbo:install
RUN yarn install
RUN chown app:app -R /usr/local/rvm/gems
RUN chown app:app -R /home/app/proposals

RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
EXPOSE 80 443
ADD entrypoint.sh /sbin/
RUN chmod 755 /sbin/entrypoint.sh
RUN mkdir -p /etc/my_init.d
RUN ln -s /sbin/entrypoint.sh /etc/my_init.d/entrypoint.sh
RUN echo 'export PATH=./bin:$PATH:/usr/local/rvm/rubies/ruby-2.7.2/bin' >> /root/.bashrc
RUN echo 'export PATH=./bin:$PATH:/usr/local/rvm/rubies/ruby-2.7.2/bin' >> /home/app/.bashrc
RUN echo 'alias rspec="bundle exec rspec"' >> /root/.bashrc
RUN echo 'alias rspec="bundle exec rspec"' >> /home/app/.bashrc
RUN echo 'alias restart="passenger-config restart-app /home/app/proposals"' >> /root/.bashrc
RUN echo 'alias restart="passenger-config restart-app /home/app/proposals"' >> /home/app/.bashrc
ENTRYPOINT ["/sbin/entrypoint.sh"]
