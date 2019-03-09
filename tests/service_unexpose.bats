#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:unexpose) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unexpose"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:unexpose) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unexpose" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:unexpose) success" {
  dokku "$PLUGIN_COMMAND_PREFIX:expose" l
  run dokku "$PLUGIN_COMMAND_PREFIX:unexpose" l
  [[ ! -f $PLUGIN_DATA_ROOT/PORT ]]
  assert_contains "${lines[*]}" "Service l unexposed"
}

