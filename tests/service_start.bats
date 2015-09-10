#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:start) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:start"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:start) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:start" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:start) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:start" l
  assert_success
}

