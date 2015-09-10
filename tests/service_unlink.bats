#!/usr/bin/env bats
load test_helper

setup() {
  dokku apps:create my_app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm "$DOKKU_ROOT/my_app" -rf
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" l
  assert_contains "${lines[*]}" "Please specify an app to run the command on"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when the app does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" l not_existing_app
  assert_contains "${lines[*]}" "App not_existing_app does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when the service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" not_existing_service my_app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) success" {
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app >&2
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  links=$(cat "$PLUGIN_DATA_ROOT/l/LINKS")
  assert_equal "$links" ""
}
