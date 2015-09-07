#!/usr/bin/env bats
load test_helper

@test "(service) dokku" {
  dokku $PLUGIN_COMMAND_PREFIX:create l
  assert_success

  dokku $PLUGIN_COMMAND_PREFIX:info l
  assert_success

  dokku $PLUGIN_COMMAND_PREFIX:stop l
  assert_success

  dokku $PLUGIN_COMMAND_PREFIX:stop l
  assert_success

  dokku $PLUGIN_COMMAND_PREFIX:expose l
  assert_success

  dokku $PLUGIN_COMMAND_PREFIX:restart l
  assert_success

  dokku $PLUGIN_COMMAND_PREFIX:info l
  assert_success

  dokku --force $PLUGIN_COMMAND_PREFIX:destroy l
  assert_success
}
