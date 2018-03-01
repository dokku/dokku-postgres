#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
  dokku "$PLUGIN_COMMAND_PREFIX:create-database" l d >&2
  dokku apps:create my_app >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm -rf "$DOKKU_ROOT/my_app"
}

@test "($PLUGIN_COMMAND_PREFIX:destroy-database) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:destroy-database" l d
  assert_contains "${lines[*]}" "database deleted: d"
}

@test "($PLUGIN_COMMAND_PREFIX:destroy-database) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:destroy-database"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:destroy-database) error when there is only one argument" {
  run dokku "$PLUGIN_COMMAND_PREFIX:destroy-database" l
  assert_contains "${lines[*]}" "Please specify a name for the database"
}
