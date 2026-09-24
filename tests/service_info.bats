#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" l -f
}

@test "($PLUGIN_COMMAND_PREFIX:info) reports every service when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info"
  assert_success
  assert_contains "${lines[*]}" "$PLUGIN_DATA_ROOT/l"
}

@test "($PLUGIN_COMMAND_PREFIX:info) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:info) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info" l
  local password="$(sudo cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  assert_contains "${lines[*]}" "postgres://postgres:$password@dokku-postgres-l:5432/l"
}

@test "($PLUGIN_COMMAND_PREFIX:info) replaces underscores by dash in hostname" {
  dokku "$PLUGIN_COMMAND_PREFIX:create" test_with_underscores
  run dokku "$PLUGIN_COMMAND_PREFIX:info" test_with_underscores
  local password="$(sudo cat "$PLUGIN_DATA_ROOT/test_with_underscores/PASSWORD")"
  assert_contains "${lines[*]}" "postgres://postgres:$password@dokku-postgres-test-with-underscores:5432/test_with_underscores"
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" test_with_underscores -f
}

@test "($PLUGIN_COMMAND_PREFIX:info) success with flag" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --dsn
  local password="$(sudo cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  assert_output "postgres://postgres:$password@dokku-postgres-l:5432/l"

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --config-dir
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --data-dir
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --dsn
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --exposed-ports
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --id
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --internal-ip
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --links
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --service-root
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --status
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --version
  assert_success
}

@test "($PLUGIN_COMMAND_PREFIX:info) error when invalid flag" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --invalid-flag
  assert_failure
}
