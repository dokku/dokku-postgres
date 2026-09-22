#!/usr/bin/env bats
load test_helper

setup() {
  dokku apps:create my-app
  dokku "$PLUGIN_COMMAND_PREFIX:create" ls
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app >&2
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls my-app >&2 || true
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls cloned-app >&2 || true
  clear_links ls
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" ls -f || true
  dokku apps:destroy my-app --force || true
  dokku apps:destroy cloned-app --force || true
}

# a clone leaves two apps where there was one, and the clone is handed the config
# that points at the service, so both names belong in the links file
@test "($PLUGIN_COMMAND_PREFIX:hook:post-app-clone-setup) links the clone as well as the original" {
  dokku apps:clone --skip-deploy my-app cloned-app

  run sudo cat "$PLUGIN_DATA_ROOT/ls/LINKS"
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "my-app"
  assert_contains "${lines[*]}" "cloned-app"
}
