#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
  dokku apps:create my_app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm "$DOKKU_ROOT/my_app" -rf
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l
  assert_contains "${lines[*]}" "Please specify an app to run the command on"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l not_existing_app
  assert_contains "${lines[*]}" "App not_existing_app does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" not_existing_service my_app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service is already promoted" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  assert_contains "${lines[*]}" "already promoted as DATABASE_URL"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) changes DATABASE_URL" {
  password="$(cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  dokku config:set my_app "DATABASE_URL=postgres://u:p@host:5432/db" "DOKKU_POSTGRES_BLUE_URL=postgres://postgres:$password@dokku-postgres-l:5432/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app DATABASE_URL)
  assert_equal "$url" "postgres://postgres:$password@dokku-postgres-l:5432/l"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) creates new config url when needed" {
  password="$(cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  dokku config:set my_app "DATABASE_URL=postgres://u:p@host:5432/db" "DOKKU_POSTGRES_BLUE_URL=postgres://postgres:$password@dokku-postgres-l:5432/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  run dokku config my_app
  assert_contains "${lines[*]}" "DOKKU_POSTGRES_"
}
@test "($PLUGIN_COMMAND_PREFIX:promote) uses POSTGRES_DATABASE_SCHEME variable" {
  password="$(cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  dokku config:set my_app "POSTGRES_DATABASE_SCHEME=postgres2" "DATABASE_URL=postgres://u:p@host:5432/db" "DOKKU_POSTGRES_BLUE_URL=postgres2://postgres:$password@dokku-postgres-l:5432/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app DATABASE_URL)
  assert_contains "$url" "postgres2://postgres:$password@dokku-postgres-l:5432/l"
}
