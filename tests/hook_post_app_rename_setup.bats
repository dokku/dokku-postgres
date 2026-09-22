#!/usr/bin/env bats
load test_helper

setup() {
  dokku apps:create my-app
  dokku "$PLUGIN_COMMAND_PREFIX:create" ls
  dokku "$PLUGIN_COMMAND_PREFIX:link" ls my-app >&2
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" ls renamed-app >&2 || true
  clear_links ls
  dokku "$PLUGIN_COMMAND_PREFIX:destroy" ls -f || true
  dokku apps:destroy my-app --force || true
  dokku apps:destroy renamed-app --force || true
}

# this trigger only adds the new name. The old one goes when the rename destroys
# the app it belonged to, since that fires the pre-delete this plugin installs,
# so it takes both halves for the service to end up linked to the app that is
# actually there. --skip-deploy keeps a never deployed app from rebuilding.
@test "($PLUGIN_COMMAND_PREFIX:hook:post-app-rename-setup) moves the link onto the new name" {
  dokku apps:rename --skip-deploy my-app renamed-app

  run sudo cat "$PLUGIN_DATA_ROOT/ls/LINKS"
  echo "output: $output"
  echo "status: $status"
  assert_contains "${lines[*]}" "renamed-app"
  assert_not_contains "${lines[*]}" "my-app"

  run dokku "$PLUGIN_COMMAND_PREFIX:links" ls
  echo "output: $output"
  echo "status: $status"
  assert_success
  assert_contains "${lines[*]}" "renamed-app"
  assert_not_contains "${lines[*]}" "my-app"
}
