#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:export) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:export"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:export) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:export" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:export) success with SSH_TTY" {
  if [[ -n "$GITHUB_WORKFLOW" ]]; then
    skip "No tty is available on Github Actions"
  fi
  export SSH_TTY=$(tty)
  run dokku "$PLUGIN_COMMAND_PREFIX:export" l
  echo "output: $output"
  echo "status: $status"
  assert_exit_status 0
}

@test "($PLUGIN_COMMAND_PREFIX:export) success without SSH_TTY" {
  unset SSH_TTY
  run dokku "$PLUGIN_COMMAND_PREFIX:export" l
  echo "output: $output"
  echo "status: $status"
  assert_exit_status 0
}
