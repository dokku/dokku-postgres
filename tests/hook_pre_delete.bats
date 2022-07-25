#!/usr/bin/env bats
load test_helper

setup() {
  dokku apps:create my-app
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my-app >&2
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my-app >&2
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:hook:pre-delete) removes app from links file when destroying app" {
  [[ -n $(<"$PLUGIN_DATA_ROOT/l/LINKS") ]]
  dokku --force apps:destroy my-app
  [[ -z $(<"$PLUGIN_DATA_ROOT/l/LINKS") ]]
}
