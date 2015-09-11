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

@test "($PLUGIN_COMMAND_PREFIX:clone) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:clone"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:clone) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:clone" not_existing_service new_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:clone) error when new service isn't provided" {
  run dokku "$PLUGIN_COMMAND_PREFIX:clone" l
  assert_contains "${lines[*]}" "Please specify a name for the new service"
}

@test "($PLUGIN_COMMAND_PREFIX:clone) error when new service already exists" {
  dokku "$PLUGIN_COMMAND_PREFIX:create" new_service
  run dokku "$PLUGIN_COMMAND_PREFIX:clone" l new_service
  assert_contains "${lines[*]}" "service new_service already exists"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" new_service
}

@test "($PLUGIN_COMMAND_PREFIX:clone) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:clone" l new_service
  [[ -f $PLUGIN_DATA_ROOT/new_service/ID ]]
  assert_contains "${lines[*]}" "Copying data from l to new_service"
  assert_contains "${lines[*]}" "Done"
}

