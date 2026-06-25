#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:reset) success with --force" {
  run dokku --force "$PLUGIN_COMMAND_PREFIX:reset" l
  assert_contains "${lines[*]}" "All l data deleted"
  assert_success
}

@test "($PLUGIN_COMMAND_PREFIX:reset) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:reset"
  assert_contains "${lines[*]}" "Please specify a name for the service"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:reset) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:reset" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
  assert_failure
}
