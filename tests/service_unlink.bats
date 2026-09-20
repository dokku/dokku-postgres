#!/usr/bin/env bats
load test_helper

setup() {
  dokku apps:create my-app
  dokku "$PLUGIN_COMMAND_PREFIX:create" ls
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" ls -f
  dokku apps:destroy my-app --force
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls
  assert_contains "${lines[*]}" "Please specify an app to run the command on"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when the app does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls not_existing_app
  assert_contains "${lines[*]}" "App not_existing_app does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when the service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" not_existing_service my-app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) error when service not linked to app" {
  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
  assert_contains "${lines[*]}" "Not linked to app my-app"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) removes link from docker-options" {
  link_option="--link dokku.$PLUGIN_COMMAND_PREFIX.ls:dokku-$PLUGIN_COMMAND_PREFIX-ls"

  # the run phase is asked for by name rather than the whole report as json,
  # because a report format is a newer dokku than this suite runs against
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app >&2
  options=$(dokku docker-options:report my-app --docker-options-run)
  assert_contains "$options" "$link_option"

  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
  options=$(dokku docker-options:report my-app --docker-options-run)
  assert_not_contains "$options" "$link_option"
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) unsets config url from app" {
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
  config=$(dokku config:get my-app DATABASE_URL || true)
  assert_equal "$config" ""
}

@test "($PLUGIN_COMMAND_PREFIX:unlink) respects --no-restart" {
  run dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app
  echo "output: $output"
  echo "status: $status"
  assert_output_contains "Skipping restart of linked app" 0
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app --no-restart
  echo "output: $output"
  echo "status: $status"
  assert_output_contains "Skipping restart of linked app"
  assert_success
}
