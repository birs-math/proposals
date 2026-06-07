# See: https://github.com/phusion/passenger-docker
# Latest image versions:
# https://github.com/phusion/passenger-docker/blob/master/CHANGELOG.md
FROM phusion/passenger-ruby27:2.4.1

ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Yarn package
# The old gh-pages pubkey URL no longer carries Yarn's current signing key (62D54FD4003F6525),
# so `apt-get update` fails ("NO_PUBKEY ... dl.yarnpkg.com ... is not signed") on a from-scratch
# build. Fetch the canonical key into a keyring and pin the repo to it with signed-by.
# (Same class of infra rot as the phusion repo below, not related to the Ruby/Rails bump.)
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarnkey.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list

# Postgres
RUN curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Needed packages
# The phusion passenger apt repo's signing key (D870AB033FB45BD1) has rotated/expired, so
# `apt-get update` fails ("NO_PUBKEY ... passenger focal Release is not signed") on any
# from-scratch build. Passenger is baked into the base image and never apt-installed here, so
# drop the broken repo. (Pre-existing infra rot, not related to the Ruby/Rails bump.)
RUN rm -f /etc/apt/sources.list.d/passenger.list
RUN apt-get update
RUN apt-get install --yes --fix-missing pkg-config apt-utils build-essential \
              cmake automake tzdata locales curl git gnupg ca-certificates \
              libpq-dev wget libxrender1 libxext6 libsodium23 libsodium-dev \
              netcat postgresql-client shared-mime-info texlive \
              texlive-latex-extra texlive-extra-utils

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install --yes --fix-missing nodejs yarn

# Cleanup
RUN apt-get clean && apt-get autoremove --yes \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use en_CA.utf8 as our locale
RUN locale-gen en_CA.utf8
ENV LANG en_CA.utf8
ENV LANGUAGE en_CA:en
ENV LC_ALL en_CA.utf8

# Match deployment userid
RUN /usr/sbin/usermod -u 40130 app

ENV APP_HOME /home/app/proposals
COPY --chown=app . $APP_HOME
WORKDIR $APP_HOME

# Base image ships only Ruby 2.7.7; install 2.7.8 on the proven 2.4.1 base
# (minimal change vs swapping the whole base image — same idiom as workshops).
RUN /bin/bash -lc "rvm install 2.7.8 && rvm --default use 2.7.8 && rvm cleanup all"
RUN /usr/local/rvm/bin/rvm-exec 2.7.8 gem install bundler -v 2.4.22
RUN bundle install --jobs=3 --retry=3
RUN chown app:app -R /usr/local/rvm/gems

RUN yarn install
RUN chown app:app -R /home/app/proposals/node_modules
RUN chmod -R 755 /home/app/proposals/node_modules

RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
EXPOSE 80 443
COPY entrypoint.sh /sbin/
RUN chmod 755 /sbin/entrypoint.sh
RUN mkdir -p /etc/my_init.d
RUN ln -s /sbin/entrypoint.sh /etc/my_init.d/entrypoint.sh
RUN echo 'export PATH=./bin:$PATH:/usr/local/rvm/rubies/ruby-2.7.8/bin' >> /root/.bashrc
RUN echo 'export PATH=./bin:$PATH:/usr/local/rvm/rubies/ruby-2.7.8/bin' >> /home/app/.bashrc
RUN echo 'alias rspec="bundle exec rspec"' >> /root/.bashrc
RUN echo 'alias rspec="bundle exec rspec"' >> /home/app/.bashrc
RUN echo 'alias restart="passenger-config restart-app /home/app/proposals & tail -f log/production.log"' >> /root/.bashrc
RUN echo 'alias restart="passenger-config restart-app /home/app/proposals & tail -f log/production.log"' >> /home/app/.bashrc
ENTRYPOINT ["/sbin/entrypoint.sh"]
