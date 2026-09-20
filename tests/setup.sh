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
pushd "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")" >/dev/null
source "config"
popd >/dev/null
sudo rm -rf "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX"
sudo mkdir -p "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX" "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX/subcommands" "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX/scripts" "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX/templates"
sudo find ./ -maxdepth 1 -type f -exec cp '{}' "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX" \;
[[ -d "./scripts" ]] && sudo find ./scripts -maxdepth 1 -type f -exec cp '{}' "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX/scripts" \;
[[ -d "./subcommands" ]] && sudo find ./subcommands -maxdepth 1 -type f -exec cp '{}' "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX/subcommands" \;
[[ -d "./templates" ]] && sudo find ./templates -maxdepth 1 -type f -exec cp '{}' "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX/templates" \;
# recursive rather than the flat copies above, because a definition is a tree: it
# has a rootfs and a bin below it. Without this the plugin's own definitions are
# missing under test and the embedded ones answer instead, so an override would
# work in production and quietly vanish here.
[[ -d "./datastore" ]] && sudo cp -R ./datastore "$DOKKU_PLUGINS_ROOT/$PLUGIN_COMMAND_PREFIX/"
sudo mkdir -p "$PLUGIN_CONFIG_ROOT" "$PLUGIN_DATA_ROOT"
sudo dokku plugin:enable "$PLUGIN_COMMAND_PREFIX"

# stage a locally built dokku-datastore so that an unreleased build can be
# tested against this plugin, rather than the version pinned in config
if [[ -n "$DOKKU_DATASTORE_BINARY" ]]; then
  echo "Staging dokku-datastore from $DOKKU_DATASTORE_BINARY"
  sudo mkdir -p "$DOKKU_LIB_ROOT/data/$PLUGIN_COMMAND_PREFIX"
  sudo cp "$DOKKU_DATASTORE_BINARY" "$DOKKU_LIB_ROOT/data/$PLUGIN_COMMAND_PREFIX/dokku-datastore.local"
  sudo chmod +x "$DOKKU_LIB_ROOT/data/$PLUGIN_COMMAND_PREFIX/dokku-datastore.local"
fi

sudo dokku plugin:install
