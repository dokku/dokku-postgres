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

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when service not linked to app" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  assert_contains "${lines[*]}" "Not linked to app my_app"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) removes link from docker-options" {
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  options=$(dokku docker-options my_app | xargs)
  check_value=""
  [[ "$(dokku version)" == "master" ]] && check_value="Deploy options: --restart=on-failure:10"
  [[ "$(at-least-version 0.7.0 "$(dokku version)")" == "true" ]] && check_value="Deploy options: --restart=on-failure:10"
  assert_equal "$options" "$check_value"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) unsets config url from app" {
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  config=$(dokku config:get my_app DATABASE_URL)
  assert_equal "$config" ""
}
