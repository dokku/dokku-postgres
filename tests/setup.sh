#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test_helper.bash"

if [[ ! -d $DOKKU_ROOT ]]; then
  git clone https://github.com/progrium/dokku.git $DOKKU_ROOT > /dev/null
fi

cd $DOKKU_ROOT
echo "Dokku version $DOKKU_VERSION"
git checkout $DOKKU_VERSION > /dev/null
cd -

rm -rf $DOKKU_ROOT/plugins/service
mkdir -p $DOKKU_ROOT/plugins/service
find ./ -maxdepth 1 -type f -exec cp '{}' $DOKKU_ROOT/plugins/service \;
