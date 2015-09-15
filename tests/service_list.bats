#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:list) with no exposed ports" {
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l, postgres:9.4.4 (running)"
}

@test "($PLUGIN_COMMAND_PREFIX:list) with exposed ports" {
  dokku "$PLUGIN_COMMAND_PREFIX:expose" l 4242
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l, postgres:9.4.4 (running), exposed port(s): 5432->4242"
}

@test "($PLUGIN_COMMAND_PREFIX:list) when there are no services" {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "There are no Postgres services"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}
