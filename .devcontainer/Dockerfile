FROM dokku/dokku:latest

RUN apt-get update
RUN apt-get install --no-install-recommends -y build-essential file nano && \
  apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /mnt/dokku/home/dokku /mnt/dokku/var/lib/dokku/config /mnt/dokku/var/lib/dokku/data /mnt/dokku/var/lib/dokku/services && \
  chown -R dokku:dokku /mnt/dokku/home/dokku /mnt/dokku/var/lib/dokku/config /mnt/dokku/var/lib/dokku/data /mnt/dokku/var/lib/dokku/services && \
  echo "dokku.me" > /home/dokku/VHOST

ADD https://raw.githubusercontent.com/dokku/dokku/master/tests/dhparam.pem /mnt/dokku/etc/nginx/dhparam.pem

COPY .devcontainer/20_init_plugin /etc/my_init.d/20_init_plugin
COPY .devcontainer/bin/ /usr/local/bin/

COPY . .

RUN source /tmp/config && \
  echo "export ${PLUGIN_DISABLE_PULL_VARIABLE}=true" > /tmp/.env && \
  echo "export PLUGIN_NAME=${PLUGIN_COMMAND_PREFIX}" >> /tmp/.env && \
  echo "export PLUGIN_VARIABLE=${PLUGIN_VARIABLE}" >> /tmp/.env

RUN source /tmp/.env && \
  dokku plugin:install file:///tmp --name $PLUGIN_NAME && \
  make ci-dependencies
