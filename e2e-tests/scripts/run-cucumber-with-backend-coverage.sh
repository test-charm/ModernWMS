#!/usr/bin/env bash

set -euo pipefail

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly e2e_dir="$(cd "${script_dir}/.." && pwd)"
readonly repo_root="$(cd "${e2e_dir}/.." && pwd)"
readonly coverage_dir="${e2e_dir}/build/coverage"
readonly coverage_xml="${coverage_dir}/backend.cobertura.xml"
readonly coverage_html_dir="${e2e_dir}/build/reports/backend-coverage"
readonly backend_url="http://127.0.0.1:10085/"
stack_started=false

log() {
  local level="$1"
  local color="$2"
  shift 2
  printf '\033[%sm[%s]\033[0m %s\n' "${color}" "${level}" "$*"
}

cleanup() {
  if [[ "${stack_started}" != "true" ]]; then
    return
  fi

  log INFO "34" "Stopping docker compose stack"
  (cd "${repo_root}" && docker compose down --remove-orphans) >/dev/null 2>&1 || true
}

trap cleanup EXIT

log INFO "34" "Cleaning previous backend coverage artifacts"
rm -rf "${coverage_dir}" "${coverage_html_dir}"
mkdir -p "${coverage_dir}"

log INFO "34" "Starting mysql and dotnet containers"
(cd "${repo_root}" && BACKEND_ENABLE_COVERAGE=true docker compose up -d --build) >/dev/null
stack_started=true

log INFO "34" "Waiting for backend to become ready at ${backend_url}"
for attempt in $(seq 1 180); do
  if curl -fsS "${backend_url}" >/dev/null 2>&1; then
    break
  fi

  if [[ "${attempt}" -eq 180 ]]; then
    log ERROR "31" "Backend did not become ready in time"
    (cd "${repo_root}" && docker compose logs dotnet --tail 120) || true
    exit 1
  fi

  sleep 2
done

log INFO "34" "Running cucumber scenarios"
test_exit=0
java \
  -Dfile.encoding=UTF-8 \
  -Dsun.jnu.encoding=utf-8 \
  -Dspring.profiles.active="${SPRING_PROFILES_ACTIVE:-test}" \
  -cp "${CUCUMBER_CLASSPATH}" \
  io.cucumber.core.cli.Main \
  --plugin pretty \
  --glue org.testcharmtraining \
  --glue org.testcharm \
  --tags "${CUCUMBER_TAGS:-not @known-bug}" \
  "${CUCUMBER_TARGET:-src/test/resources/features}" || test_exit=$?

cleanup
trap - EXIT

if [[ "${test_exit}" -ne 0 ]]; then
  exit "${test_exit}"
fi

log INFO "34" "Verifying backend coverage artifacts"
if [[ ! -f "${coverage_xml}" ]]; then
  log ERROR "31" "Missing backend coverage XML: ${coverage_xml}"
  exit 1
fi

if [[ ! -f "${coverage_html_dir}/index.html" ]]; then
  log ERROR "31" "Missing backend coverage HTML report: ${coverage_html_dir}/index.html"
  exit 1
fi

log INFO "32" "Backend coverage artifacts are ready"
