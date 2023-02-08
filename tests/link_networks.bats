#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" ls
  dokku network:create custom-network
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" ls || true
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" lsa || true
  dokku network:destroy --force custom-network
}

@test "($PLUGIN_COMMAND_PREFIX:set) set initial-network" {
  run dokku "$PLUGIN_COMMAND_PREFIX:set" ls initial-network custom-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" ls --initial-network
  echo "output: $output"
  echo "status: $status"
  assert_output "custom-network"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:set" ls initial-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" ls --initial-network
  echo "output: $output"
  echo "status: $status"
  assert_output ""
  assert_success

  run docker inspect dokku.$PLUGIN_COMMAND_PREFIX.ls -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains bridge
  assert_output_contains custom-network 0

  run dokku "$PLUGIN_COMMAND_PREFIX:stop" ls
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:start" ls
  echo "output: $output"
  echo "status: $status"
  assert_success

  run docker inspect dokku.$PLUGIN_COMMAND_PREFIX.ls -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains bridge 0
  assert_output_contains custom-network
}

@test "($PLUGIN_COMMAND_PREFIX:set) set post-create-network" {
  run dokku "$PLUGIN_COMMAND_PREFIX:set" ls post-create-network custom-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" ls --post-create-network
  echo "output: $output"
  echo "status: $status"
  assert_output "custom-network"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:set" ls post-create-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" ls --post-create-network
  echo "output: $output"
  echo "status: $status"
  assert_output ""
  assert_success

  run docker inspect dokku.$PLUGIN_COMMAND_PREFIX.ls -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains bridge
  assert_output_contains custom-network 0

  run dokku "$PLUGIN_COMMAND_PREFIX:stop" ls
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:start" ls
  echo "output: $output"
  echo "status: $status"
  assert_success

  run docker inspect dokku.$PLUGIN_COMMAND_PREFIX.ls -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains custom-network
  assert_output_contains bridge
}

@test "($PLUGIN_COMMAND_PREFIX:set) set an post-start-network" {
  run dokku "$PLUGIN_COMMAND_PREFIX:set" ls post-start-network custom-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" ls --post-start-network
  echo "output: $output"
  echo "status: $status"
  assert_output "custom-network"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:set" ls post-start-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" ls --post-start-network
  echo "output: $output"
  echo "status: $status"
  assert_output ""
  assert_success

  run docker inspect dokku.$PLUGIN_COMMAND_PREFIX.ls -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains bridge
  assert_output_contains custom-network 0

  run dokku "$PLUGIN_COMMAND_PREFIX:stop" ls
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:start" ls
  echo "output: $output"
  echo "status: $status"
  assert_success

  run docker inspect dokku.$PLUGIN_COMMAND_PREFIX.ls -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains bridge
  assert_output_contains custom-network
}

@test "($PLUGIN_COMMAND_PREFIX:create) flags" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" lsa --initial-network custom-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run docker inspect "dokku.$PLUGIN_COMMAND_PREFIX.lsa" -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains bridge 0
  assert_output_contains custom-network

  run dokku "$PLUGIN_COMMAND_PREFIX:destroy" lsa --force
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:create" lsa --post-create-network custom-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run docker inspect "dokku.$PLUGIN_COMMAND_PREFIX.lsa" -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains bridge
  assert_output_contains custom-network

  run dokku "$PLUGIN_COMMAND_PREFIX:destroy" lsa --force
  echo "output: $output"
  echo "status: $status"
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:create" lsa --post-start-network custom-network
  echo "output: $output"
  echo "status: $status"
  assert_success

  run docker inspect "dokku.$PLUGIN_COMMAND_PREFIX.lsa" -f '{{range $net,$v := .NetworkSettings.Networks}}{{printf "%s\n" $net}}{{end}}'
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_output_contains bridge
  assert_output_contains custom-network

  run dokku "$PLUGIN_COMMAND_PREFIX:destroy" lsa --force
  echo "output: $output"
  echo "status: $status"
  assert_success
}
