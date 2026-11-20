# shellcheck shell=bash
# CI configuration of the sub-product Pipeline, read by `fcd ci`.
# The Pipeline is a bash script on the host, not a container: build, deploy and e2e do not apply.
ci_lint() {
  bash -n "$R_REPO/fcd"
  docker run --rm -v "$R_REPO":/mnt:ro "$TOOL_SHELLCHECK" -x -S warning /mnt/fcd /mnt/ci/steps.sh
}
ci_unit() {
  mkdir -p "$R_DIR/reports/unit"
  docker build -q -t fcd-tmp/pipeline-tests "$R_REPO/tests" >/dev/null
  docker run --rm -v "$R_REPO":/code:ro -v "$R_DIR/reports/unit":/reports -w /code fcd-tmp/pipeline-tests \
    --report-formatter junit --output /reports tests || true
}
