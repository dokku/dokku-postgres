#!/usr/bin/env bats
load test_helper

setup() {
  export ECHO_DOCKER_COMMAND="false"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  export ECHO_DOCKER_COMMAND="false"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:logs) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:logs"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:logs) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:logs" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:logs) success when not tailing" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:logs" l
  assert_output "docker logs --tail 100 testid"
}

@test "($PLUGIN_COMMAND_PREFIX:logs) success when tailing" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:logs" l -t
  assert_output "docker logs --follow testid"
}
