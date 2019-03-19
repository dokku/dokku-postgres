#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:logs) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:logs"
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:logs) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:logs" not_existing_service
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:logs) success when not tailing" {
  skip "This may fail if there is no log output"
  run dokku "$PLUGIN_COMMAND_PREFIX:logs" l
  echo "output: $output"
  echo "status: $status"
  assert_success
}

@test "($PLUGIN_COMMAND_PREFIX:logs) success when tailing" {
  skip "This will hang as it waits for log output"
  run dokku "$PLUGIN_COMMAND_PREFIX:logs" l -t
  echo "output: $output"
  echo "status: $status"
  assert_success
}
