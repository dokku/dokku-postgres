#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
  dokku apps:create my_app >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm -rf "$DOKKU_ROOT/my_app"
}

@test "($PLUGIN_COMMAND_PREFIX:create-database) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create-database" l d
  assert_contains "${lines[*]}" "database created: l"
}
