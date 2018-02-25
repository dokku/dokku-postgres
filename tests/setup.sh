#!/usr/bin/env bash
set -eo pipefail; [[ $DOKKU_TRACE ]] && set -x
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test_helper.bash"

BIN_STUBS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bin"

if [[ ! -d $DOKKU_ROOT ]]; then
  git clone https://github.com/progrium/dokku.git $DOKKU_ROOT > /dev/null
fi

cd $DOKKU_ROOT
echo "Dokku version $DOKKU_VERSION"
git checkout $DOKKU_VERSION > /dev/null
if grep go-build Makefile > /dev/null; then
  mv "$BIN_STUBS/docker" "$BIN_STUBS/docker-stub"
  make go-build
  mv "$BIN_STUBS/docker-stub" "$BIN_STUBS/docker"
fi
cd -

source "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")/config"
rm -rf $DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX
mkdir -p $DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX $DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX/subcommands $DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX/scripts
find ./ -maxdepth 1 -type f -exec cp '{}' $DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX \;
find ./subcommands -maxdepth 1 -type f -exec cp '{}' $DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX/subcommands \;
find ./scripts -maxdepth 1 -type f -exec cp '{}' $DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX/scripts \;
echo "$DOKKU_VERSION" > $DOKKU_ROOT/VERSION

if [[ ! -f $BIN_STUBS/plugn ]]; then
  wget -O- "$PLUGN_URL" | tar xzf - -C "$BIN_STUBS"
  plugn init
  find "$DOKKU_ROOT/plugins" -mindepth 1 -maxdepth 1 -type d ! -name 'available' ! -name 'enabled' -exec ln -s {} "$DOKKU_ROOT/plugins/available" \;
  find "$DOKKU_ROOT/plugins" -mindepth 1 -maxdepth 1 -type d ! -name 'available' ! -name 'enabled' -exec ln -s {} "$DOKKU_ROOT/plugins/enabled" \;
fi
