#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" l -f
}

@test "($PLUGIN_COMMAND_PREFIX:list) with no exposed ports, no linked apps" {
  run dokku --quiet "$PLUGIN_COMMAND_PREFIX:list"
  assert_output "l"
}

@test "($PLUGIN_COMMAND_PREFIX:list) when there are no services" {
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" l -f
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_output "${lines[*]}" "There are no $PLUGIN_SERVICE services"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}
