#!/usr/bin/env bats
load test_helper

@test "($PLUGIN_COMMAND_PREFIX:create) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" l
  assert_contains "${lines[*]}" "container created: l"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:create) service with dashes" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" service-with-dashes
  assert_contains "${lines[*]}" "container created: service-with-dashes"
  assert_contains "${lines[*]}" "dokku-$PLUGIN_COMMAND_PREFIX-service-with-dashes"
  assert_contains "${lines[*]}" "service_with_dashes"

  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" service-with-dashes
}

@test "($PLUGIN_COMMAND_PREFIX:create) service with changed shm size" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" foobar-256 --shm-size="256m"
  run docker exec -it dokku.postgres.foobar-256 df -h /dev/shm
  assert_contains "${lines[*]}" "shm"
  assert_contains "${lines[*]}" "256M"

  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" foobar-256
}

@test "($PLUGIN_COMMAND_PREFIX:create) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:create) error when there is an invalid name specified" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" d.erp
  assert_failure
}
