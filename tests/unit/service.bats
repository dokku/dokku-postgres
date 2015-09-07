#!/usr/bin/env bats
export SERVICE=postgres

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$*"
    fi
  }
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

@test "(service) dokku" {
  dokku $SERVICE:create l
  assert_success

  dokku $SERVICE:info l
  assert_success

  dokku $SERVICE:stop l
  assert_success

  dokku $SERVICE:stop l
  assert_success

  dokku $SERVICE:expose l
  assert_success

  dokku $SERVICE:restart l
  assert_success

  dokku $SERVICE:info l
  assert_success

  dokku --force $SERVICE:destroy l
  assert_success
}
