# See: https://github.com/phusion/passenger-docker
# Latest image versions:
# https://github.com/phusion/passenger-docker/blob/master/CHANGELOG.md
FROM phusion/passenger-ruby27:2.4.1

ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Yarn package
RUN curl -sS https://raw.githubusercontent.com/yarnpkg/releases/gh-pages/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Postgres
RUN curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Needed packages
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

USER app

ENV APP_HOME /home/app/proposals
# disabled because we mount host directory in $APP_HOME
COPY --chown=app . $APP_HOME
WORKDIR $APP_HOME
RUN /usr/local/rvm/bin/rvm --default use 2.7.7
RUN /usr/local/rvm/bin/rvm-exec 2.7.7 gem install bundler
RUN bundle install
RUN yarn install
RUN --chown=app -R /usr/local/rvm/gems
RUN --chown=app -R /home/app/proposals/node_modules
RUN chmod 755 /home/app/proposals/node_modules

RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
EXPOSE 80 443
COPY entrypoint.sh /sbin/
RUN chmod 755 /sbin/entrypoint.sh
RUN mkdir -p /etc/my_init.d
RUN ln -s /sbin/entrypoint.sh /etc/my_init.d/entrypoint.sh
RUN echo 'export PATH=./bin:$PATH:/usr/local/rvm/rubies/ruby-2.7.7/bin' >> /root/.bashrc
RUN echo 'export PATH=./bin:$PATH:/usr/local/rvm/rubies/ruby-2.7.7/bin' >> /home/app/.bashrc
RUN echo 'alias rspec="bundle exec rspec"' >> /root/.bashrc
RUN echo 'alias rspec="bundle exec rspec"' >> /home/app/.bashrc
RUN echo 'alias restart="passenger-config restart-app /home/app/proposals & tail -f log/production.log"' >> /root/.bashrc
RUN echo 'alias restart="passenger-config restart-app /home/app/proposals & tail -f log/production.log"' >> /home/app/.bashrc
ENTRYPOINT ["/sbin/entrypoint.sh"]
