#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" ls
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" ls
}

@test "($PLUGIN_COMMAND_PREFIX:expose) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose"
  echo "output: $output"
  echo "status: $status"
  assert_failure
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:expose) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" not_existing_service
  echo "output: $output"
  echo "status: $status"
  assert_failure
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:expose) error when already exposed" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" ls
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:expose" ls
  echo "output: $output"
  echo "status: $status"
  assert_failure
  assert_contains "${lines[*]}" "Service ls already exposed on port(s)"

  run sudo rm "$PLUGIN_DATA_ROOT/ls/PORT"
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:expose" ls
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_contains "${lines[*]}" "Service ls has an untracked expose container, removing"
}

@test "($PLUGIN_COMMAND_PREFIX:expose) success when not providing custom ports" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" ls
  echo "output: $output"
  echo "status: $status"
  assert_success
  [[ "${lines[*]}" =~ exposed\ on\ port\(s\)\ \[container\-\>host\]\:\ [[:digit:]]+ ]]
}

@test "($PLUGIN_COMMAND_PREFIX:expose) success when providing custom ports" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" ls 4242
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_contains "${lines[*]}" "exposed on port(s) [container->host]: 5432->4242"
}
