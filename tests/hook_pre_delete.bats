#!/usr/bin/env bats
load test_helper

setup() {
  dokku apps:create my-app
  dokku "$PLUGIN_COMMAND_PREFIX:create" ls
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app >&2
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app >&2
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" ls
  dokku --force apps:destroy my-app
}

@test "($PLUGIN_COMMAND_PREFIX:hook:pre-delete) removes app from links file when destroying app" {
  [[ -n $(<"$PLUGIN_DATA_ROOT/ls/LINKS") ]]
  dokku --force apps:destroy my-app
  [[ -z $(<"$PLUGIN_DATA_ROOT/ls/LINKS") ]]
}
