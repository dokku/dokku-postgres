#!/usr/bin/env bash
export DOKKU_LIB_ROOT="/var/lib/dokku"
export DOKKU_ROOT="${DOKKU_ROOT:-/home/dokku}"
source "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")/config"

flunk() {
  {
    if [ "$#" -eq 0 ]; then
      cat -
    else
      echo "$*"
    fi
  }
  return 1
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    {
      echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

# ShellCheck doesn't know about $status from Bats
# shellcheck disable=SC2154
assert_exit_status() {
  assert_equal "$1" "$status"
}

# ShellCheck doesn't know about $status from Bats
# shellcheck disable=SC2154
# shellcheck disable=SC2120
assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [[ "$status" -eq 0 ]]; then
    flunk "expected failed exit status"
  elif [[ "$#" -gt 0 ]]; then
    assert_output "$1"
  fi
}

assert_exists() {
  if [ ! -f "$1" ]; then
    flunk "expected file to exist: $1"
  fi
}

# delete_app_without_unlinking removes an app the way it disappears when this
# plugin cannot see it go: disabled at the time, or removed outside dokku. The
# link is left naming an app that is not there.
delete_app_without_unlinking() {
  sudo rm -rf "${DOKKU_ROOT:?}/${1:?}"
}

# clear_links removes a service's links file. A link naming an app that was
# deleted out from under dokku blocks destroy, so a test that arranges one has
# to be able to tear it down even on a build where the behaviour it asserts is
# missing. Without this, one failing test leaves a service no later test can
# create.
clear_links() {
  sudo rm -f "$PLUGIN_DATA_ROOT/${1:?}/LINKS"
}

assert_not_exists() {
  if [ -e "$1" ]; then
    flunk "expected file not to exist: $1"
  fi
}

assert_contains() {
  if [[ "$1" != *"$2"* ]]; then
    flunk "expected $2 to be in: $1"
  fi
}

assert_not_contains() {
  if [[ "$1" == *"$2"* ]]; then
    flunk "expected $2 to not be in: $1"
  fi
}

# ShellCheck doesn't know about $output from Bats
# shellcheck disable=SC2154
assert_output() {
  local expected
  if [ $# -eq 0 ]; then
    expected="$(cat -)"
  else
    expected="$1"
  fi
  assert_equal "$expected" "$output"
}

# ShellCheck doesn't know about $output from Bats
# shellcheck disable=SC2154
assert_output_contains() {
  local input="$output"
  local expected="$1"
  local count="${2:-1}"
  local found=0
  until [ "${input/$expected/}" = "$input" ]; do
    input="${input/$expected/}"
    found=$((found + 1))
  done
  assert_equal "$count" "$found"
}
