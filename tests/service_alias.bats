#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:alias) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:alias"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:alias) error when alias is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:alias" l
  assert_contains "${lines[*]}" "Please specify an alias for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:alias) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:alias" not_existing_service MY_ALIAS
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:alias) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:alias" l MY_ALIAS
  new_alias=$(cat "$PLUGIN_DATA_ROOT/l/ALIAS")
  [[ $new_alias == "MY_ALIAS" ]]
}

