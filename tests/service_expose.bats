#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:expose) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:expose) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:expose) success when not providing a custom port" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" l
  [[ "${lines[*]}" =~ exposed\ on\ port\(s\)\ [[:digit:]]+ ]]
}

@test "($PLUGIN_COMMAND_PREFIX:expose) success when providing a custom port" {
  run dokku "$PLUGIN_COMMAND_PREFIX:expose" l 4242
  assert_contains "${lines[*]}" "exposed on port(s) 4242"
}
