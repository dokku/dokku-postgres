#!/usr/bin/env bats
load test_helper

@test "($PLUGIN_COMMAND_PREFIX:destroy) success with --force" {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
  run dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
  assert_contains "${lines[*]}" "container deleted: l"
}

@test "($PLUGIN_COMMAND_PREFIX:destroy) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:destroy"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:destroy) error when container does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:destroy" non_existing_container
  assert_contains "${lines[*]}" "service non_existing_container does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:destroy) error when container is linked to an app" {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
  dokku apps:create app
  dokku "$PLUGIN_COMMAND_PREFIX:link" l app
  run dokku "$PLUGIN_COMMAND_PREFIX:destroy" l
  assert_contains "${lines[*]}" "Cannot delete linked service"
  rm "$DOKKU_ROOT/app" -rf
}
