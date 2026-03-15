#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:localip) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:localip"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:localip) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:localip" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:localip) success" {
  local expected_ip
  expected_ip="$(docker inspect "dokku.$PLUGIN_COMMAND_PREFIX.l" -f '{{ .NetworkSettings.IPAddress }}')"
  if [[ -z "$expected_ip" ]]; then
    expected_ip="$(docker inspect "dokku.$PLUGIN_COMMAND_PREFIX.l" -f '{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' | awk 'NF { print; exit }')"
  fi

  run dokku "$PLUGIN_COMMAND_PREFIX:localip" l
  assert_success
  assert_output "$expected_ip"
}
