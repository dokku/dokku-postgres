#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:connect) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:connect) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:connect) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect" l
  assert_output 'docker exec -i -t dokku.postgres.l psql -h localhost -U postgres l'
}

