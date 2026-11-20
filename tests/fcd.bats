#!/usr/bin/env bats
# Unit tests of the helper functions in fcd (sourced without running a command).

setup() {
  export FCD_PIPELINE_DIR=/code
  # shellcheck disable=SC1091
  source <(sed '/^case "${1:-}" in/,$d' /code/fcd | sed 's/^set -euo pipefail//')
}

@test "ver_gt compares semantic versions" {
  ver_gt 0.2.0 0.1.9
  ver_gt 1.0.0 0.9.9
  ! ver_gt 0.1.0 0.1.0
  ! ver_gt 0.1.0 0.1.1
}

@test "bump_ver raises major, minor and patch" {
  [ "$(bump_ver 0.1.0 patch)" = 0.1.1 ]
  [ "$(bump_ver 0.1.3 minor)" = 0.2.0 ]
  [ "$(bump_ver 0.4.3 major)" = 1.0.0 ]
}

@test "json_str escapes quotes, backslashes and newlines" {
  [ "$(json_str 'a"b\c')" = '"a\"b\\c"' ]
  [ "$(json_str $'x\ny')" = '"x\ny"' ]
}

@test "container_var maps a container to its version variable" {
  [ "$(container_var bestellen-frontend)" = BESTELLEN_FRONTEND_VERSION ]
}

@test "junit_counts sums all test suites" {
  d=$(mktemp -d)
  printf '<testsuites><testsuite name="a" tests="3" failures="1" errors="0" skipped="1" time="1.5"></testsuite>\n<testsuite name="b" tests="2" failures="0" errors="1" skipped="0" time="0.5"></testsuite></testsuites>\n' >"$d/TEST-x.xml"
  [ "$(junit_counts "$d")" = "5 2 1 2.0" ]
}
