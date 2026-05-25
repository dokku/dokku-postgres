#!/usr/bin/env bash
set -eo pipefail
[[ $TRACE ]] && set -x
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 762E3157
echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -

sudo mkdir -p /etc/nginx
sudo curl https://raw.githubusercontent.com/dokku/dokku/master/tests/dhparam.pem -o /etc/nginx/dhparam.pem

echo "dokku dokku/skip_key_file boolean true" | sudo debconf-set-selections
wget https://raw.githubusercontent.com/dokku/dokku/master/bootstrap.sh
if [[ "$DOKKU_VERSION" == "master" ]]; then
  sudo bash bootstrap.sh
else
  sudo DOKKU_TAG="$DOKKU_VERSION" bash bootstrap.sh
fi
echo "Dokku version $DOKKU_VERSION"

export DOKKU_LIB_ROOT="/var/lib/dokku"
export DOKKU_PLUGINS_ROOT="$DOKKU_LIB_ROOT/plugins/available"
PROJECT_ROOT="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
pushd "$PROJECT_ROOT" >/dev/null
source "config"
popd >/dev/null
sudo rm -f "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX"
sudo ln -s "$PROJECT_ROOT" "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX"
sudo mkdir -p "$PLUGIN_CONFIG_ROOT" "$PLUGIN_DATA_ROOT"
sudo dokku plugin:enable "$PLUGIN_COMMAND_PREFIX"
sudo dokku plugin:install
