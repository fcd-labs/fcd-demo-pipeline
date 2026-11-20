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

@test "an explain covers only reasons that contain its rule, and only until its end date" {
  R_REPO=$(mktemp -d)
  cat >"$R_REPO/explains.yaml" <<'YAML'
- id: EXP-001
  gate: security
  rule: "versheid"
  reason: "test"
  approver: Johannes
  until: 2999-12-31
- id: EXP-OLD
  gate: security
  rule: "kwetsbaarheid"
  approver: Johannes
  until: 2000-01-01
YAML
  [ "$(explain_for security 'versheid: een library loopt een major-versie achter')" = EXP-001 ]
  [ -z "$(explain_for security 'image x: kritieke of hoge kwetsbaarheid')" ]
  [ -z "$(explain_for code 'versheid: x')" ]
}

@test "a gate keeps every reason, and an explain covers only its own" {
  R_REPO=$(mktemp -d); R_DIR=$(mktemp -d)
  printf -- '- id: EXP-001\n  gate: security\n  rule: "versheid"\n  approver: Johannes\n  until: 2999-12-31\n' >"$R_REPO/explains.yaml"
  emit() { printf '%s\n' "$3" >"$R_DIR/gate.json"; }
  finish_run() { :; }
  GATE_REASONS="image x: kritieke of hoge kwetsbaarheid; versheid: een library loopt achter"
  run gate security 6-7
  [ "$status" -eq 1 ]
  grep -q '"outcome":"closed"' "$R_DIR/gate.json"
  grep -q 'kwetsbaarheid; afwijking EXP-001: versheid' "$R_DIR/gate.json"
}

@test "explain_json gives the details of an explain for the log line" {
  R_REPO=$(mktemp -d)
  printf -- '- id: EXP-001\n  gate: security\n  rule: "versheid"\n  reason: "Angular 21 -> 22"\n  approver: Johannes\n  until: 2026-12-31\n' >"$R_REPO/explains.yaml"
  [ "$(explain_json EXP-001)" = '{"id":"EXP-001","gate":"security","rule":"versheid","reason":"Angular 21 -> 22","approver":"Johannes","until":"2026-12-31"}' ]
}

@test "bump raises the sub-product version once per change, compared with main" {
  d=$(mktemp -d); cd "$d"
  git init -q -b main origin.git --bare 2>/dev/null || git init -q --bare origin.git
  git clone -q origin.git work 2>/dev/null; cd work
  git config user.email t@example.com; git config user.name t
  printf 'SUBPRODUCT=x\nSUBPRODUCT_VERSION=0.3.0\nX_BACKEND_VERSION=0.3.0\n' >versions.env
  git add versions.env; git commit -qm one; git push -q origin HEAD:main
  run cmd_bump . x-backend minor
  [ "$(ver_get . SUBPRODUCT_VERSION)" = 0.4.0 ]
  [ "$(ver_get . X_BACKEND_VERSION)" = 0.4.0 ]
  run cmd_bump . x-backend patch
  [ "$(ver_get . SUBPRODUCT_VERSION)" = 0.4.0 ]
  [ "$(ver_get . X_BACKEND_VERSION)" = 0.4.1 ]
}
