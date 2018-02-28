#!/usr/bin/env bats
load test_helper

setup() {
  export ECHO_DOCKER_COMMAND="false"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
  dokku apps:create my_app >&2
}

teardown() {
  export ECHO_DOCKER_COMMAND="false"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm -rf "$DOKKU_ROOT/my_app"
}

@test "($PLUGIN_COMMAND_PREFIX:create-database) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create-database" l d
  assert_contains "${lines[*]}" "database created: d"
}

@test "($PLUGIN_COMMAND_PREFIX:create-database) error when there is only one argument" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create-database" l
  assert_contains "${lines[*]}" "Please specify a name for the database"
}

@test "($PLUGIN_COMMAND_PREFIX:create-database) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create-database"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}