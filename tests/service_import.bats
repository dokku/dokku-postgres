#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
  echo "data" | tee "/tmp/fake.dump"
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
  rm -f "/tmp/fake.dump"
}

@test "($PLUGIN_COMMAND_PREFIX:import) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:import"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:import) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:import" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:import) error when data is not provided" {
  if [[ -n "$GITHUB_WORKFLOW" ]]; then
    skip "No tty is available on Github Actions"
  fi
  run dokku "$PLUGIN_COMMAND_PREFIX:import" l
  assert_contains "${lines[*]}" "No data provided on stdin"
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:import) success" {
  skip "The fake dump is hard to work with in tests"
  run dokku "$PLUGIN_COMMAND_PREFIX:import" l <"/tmp/fake.dump"
  echo "output: $output"
  echo "status: $status"
  assert_success
}
