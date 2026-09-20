#!/usr/bin/env bats
load test_helper

@test "($PLUGIN_COMMAND_PREFIX:create) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" l
  assert_contains "${lines[*]}" "container created: l"
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" l -f
}

@test "($PLUGIN_COMMAND_PREFIX:create) service with dashes" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" service-with-dashes
  assert_contains "${lines[*]}" "container created: service-with-dashes"
  assert_contains "${lines[*]}" "dokku-$PLUGIN_COMMAND_PREFIX-service-with-dashes"
  assert_contains "${lines[*]}" "service_with_dashes"

  dokku "$PLUGIN_COMMAND_PREFIX:destroy" service-with-dashes -f
}

@test "($PLUGIN_COMMAND_PREFIX:create) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:create) error when there is an invalid name specified" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" d.erp
  assert_failure
}
