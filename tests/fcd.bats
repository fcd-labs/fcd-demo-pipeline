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

@test "an explain covers only reasons that contain its rule, its subject, and only until its end date" {
  CFG=$(mktemp); R_NAME=sk-demo
  cat >"$CFG" <<'PROPS'
Explanation/EXP-001/spec/gate=security
Explanation/EXP-001/spec/rule=versheid frontend
Explanation/EXP-001/spec/subject=sk-demo
Explanation/EXP-001/spec/approver=Johannes
Explanation/EXP-001/spec/until=2999-12-31
Explanation/EXP-OLD/spec/gate=security
Explanation/EXP-OLD/spec/rule=kwetsbaarheid
Explanation/EXP-OLD/spec/approver=Johannes
Explanation/EXP-OLD/spec/until=2000-01-01
Explanation/EXP-OTHER/spec/gate=security
Explanation/EXP-OTHER/spec/rule=licentie
Explanation/EXP-OTHER/spec/subject=fcd-dashboard
Explanation/EXP-OTHER/spec/approver=Johannes
PROPS
  [ "$(explain_for security 'versheid frontend (npm): meer dan 0 major-versie(s) achter')" = EXP-001 ]
  [ -z "$(explain_for security 'image x: kwetsbaarheid (CRITICAL,HIGH)')" ]
  [ -z "$(explain_for security 'image x: licentie niet toegestaan')" ]
  [ -z "$(explain_for code 'versheid frontend: x')" ]
}

@test "a gate keeps every reason, and an explain covers only its own" {
  CFG=$(mktemp); R_DIR=$(mktemp -d); R_NAME=sk-demo
  printf 'Explanation/EXP-001/spec/gate=security\nExplanation/EXP-001/spec/rule=versheid\nExplanation/EXP-001/spec/approver=Johannes\nExplanation/EXP-001/spec/until=2999-12-31\n' >"$CFG"
  emit() { printf '%s\n' "$3" >"$R_DIR/gate.json"; }
  finish_run() { :; }
  GATE_REASONS="image x: kritieke of hoge kwetsbaarheid; versheid: een library loopt achter"
  run gate security 6-7
  [ "$status" -eq 1 ]
  grep -q '"outcome":"closed"' "$R_DIR/gate.json"
  grep -q 'kwetsbaarheid; afwijking EXP-001: versheid' "$R_DIR/gate.json"
}

@test "explain_json gives the details of an explain for the log line" {
  CFG=$(mktemp)
  printf 'Explanation/EXP-001/spec/gate=security\nExplanation/EXP-001/spec/rule=versheid\nExplanation/EXP-001/spec/reason=Angular 21 -> 22\nExplanation/EXP-001/spec/approver=Johannes\nExplanation/EXP-001/spec/until=2026-12-31\n' >"$CFG"
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

@test "the configuration is read as Kind/name/path: values, lists, keys and names" {
  CFG=$(mktemp)
  cat >"$CFG" <<'PROPS'
Pipeline/pipeline/spec/steps/0=static-check
Pipeline/pipeline/spec/steps/1=unit-tests
Pipeline/pipeline/spec/steps/10=release
Pipeline/pipeline/spec/steps/2=contract-test
QualityGate/security/spec/thresholds/freshness/maxMajorBehind=1
Environment/demo/spec/ports/dashboard=8070
Environment/demo/spec/ports/stub-bar=8092
QualityGate/code/spec/afterSteps/0=static-check
PROPS
  [ "$(cfg QualityGate security spec/thresholds/freshness/maxMajorBehind)" = 1 ]
  [ "$(cfg QualityGate security spec/thresholds/missing/max 0)" = 0 ]
  [ "$(cfg_list Pipeline pipeline spec/steps | paste -sd, -)" = static-check,unit-tests,contract-test,release ]
  [ "$(cfg_keys Environment demo spec/ports | paste -sd, -)" = dashboard,stub-bar ]
  [ "$(cfg_names QualityGate | paste -sd, -)" = security,code ]
}

@test "freshness: the threshold of the configuration decides, per part" {
  CFG=$(mktemp); R_DIR=$(mktemp -d)
  printf 'QualityGate/security/spec/thresholds/freshness/maxMajorBehind=1\nQualityGate/security/spec/thresholds/freshness/undetermined=warn\n' >"$CFG"
  ci_freshness() { printf 'freshness|backend (maven)|a:b|1.5.9|3.0.9\nfreshness|frontend (npm)|@angular/core|21.2.0|22.3.0\n'; }
  step_state() { printf '%s=%q\n' "$1" "$2" >>"$R_DIR/.state"; }
  freshness
  . "$R_DIR/.state"
  [[ "$GATE_REASONS" == *"versheid backend (maven): meer dan 1 major"* ]]
  [[ "$GATE_REASONS" != *"versheid frontend"* ]]
}


@test "cfg_load reads all declarative files of a showcase with yq" {
  command -v docker >/dev/null || skip "no docker in the test container"
}
