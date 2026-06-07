#!/usr/bin/env bash

set -euo pipefail

readonly backend_root="${BACKEND_ROOT:-/workspace/backend}"
readonly backend_solution="${BACKEND_SOLUTION:-${backend_root}/ModernWMS.sln}"
readonly backend_build_configuration="${BACKEND_BUILD_CONFIGURATION:-Debug}"
readonly backend_project_name="${BACKEND_PROJECT_NAME:-ModernWMS}"
readonly backend_project_dir="${BACKEND_PROJECT_DIR:-${backend_root}/${backend_project_name}}"
readonly backend_enable_coverage="${BACKEND_ENABLE_COVERAGE:-false}"
readonly coverage_output="${BACKEND_COVERAGE_OUTPUT:-/workspace/e2e-tests/build/coverage/backend.cobertura.xml}"
readonly coverage_report_dir="${BACKEND_COVERAGE_REPORT_DIR:-/workspace/e2e-tests/build/reports/backend-coverage}"
readonly coverage_report_title="${BACKEND_COVERAGE_REPORT_TITLE:-ModernWMS Backend Coverage}"

app_pid=""

log() {
  local level="$1"
  local color="$2"
  shift 2
  printf '\033[%sm[%s]\033[0m %s\n' "${color}" "${level}" "$*"
}

prepare_coverage_artifacts() {
  if [[ "${backend_enable_coverage}" != "true" ]]; then
    return
  fi

  mkdir -p "$(dirname "${coverage_output}")"
  rm -f "${coverage_output}"
  rm -rf "${coverage_report_dir}"
}

build_backend() {
  log INFO "34" "Restoring backend solution"
  dotnet restore "${backend_solution}" --verbosity minimal

  log INFO "34" "Cleaning backend solution"
  dotnet clean "${backend_solution}" --configuration "${backend_build_configuration}" --verbosity minimal

  log INFO "34" "Building backend solution"
  dotnet build "${backend_solution}" --no-restore --configuration "${backend_build_configuration}" --verbosity minimal
}

locate_backend_dll() {
  local dll_path
  dll_path="$(find "${backend_project_dir}/bin/${backend_build_configuration}" -maxdepth 2 -type f -name "${backend_project_name}.dll" | head -n 1)"

  if [[ -z "${dll_path}" ]]; then
    log ERROR "31" "Unable to locate ${backend_project_name}.dll under ${backend_project_dir}"
    exit 1
  fi

  printf '%s\n' "${dll_path}"
}

stop_coverage_target() {
  if [[ -z "${app_pid}" ]] || ! kill -0 "${app_pid}" 2>/dev/null; then
    return
  fi

  local child_pids
  child_pids="$(ps -eo pid=,ppid= | awk -v parent_pid="${app_pid}" '$2 == parent_pid { print $1 }')"

  if [[ -z "${child_pids}" ]]; then
    return
  fi

  while IFS= read -r child_pid; do
    if [[ -n "${child_pid}" ]]; then
      kill -TERM "${child_pid}" 2>/dev/null || true
    fi
  done <<< "${child_pids}"
}

generate_html_report() {
  if [[ "${backend_enable_coverage}" != "true" ]]; then
    return
  fi

  if [[ ! -f "${coverage_output}" ]]; then
    log ERROR "31" "Coverage output was not generated: ${coverage_output}"
    exit 1
  fi

  log INFO "34" "Generating HTML coverage report"
  reportgenerator \
    "-reports:${coverage_output}" \
    "-targetdir:${coverage_report_dir}" \
    "-reporttypes:Html" \
    "-assemblyfilters:+ModernWMS*" \
    "-title:${coverage_report_title}"
}

stop_backend() {
  local exit_code="${1:-0}"

  if [[ -n "${app_pid}" ]] && kill -0 "${app_pid}" 2>/dev/null; then
    if [[ "${backend_enable_coverage}" == "true" ]]; then
      stop_coverage_target
    else
      kill -TERM "${app_pid}" 2>/dev/null || true
    fi
    wait "${app_pid}" || exit_code=$?
  fi

  generate_html_report
  exit "${exit_code}"
}

trap 'stop_backend 0' TERM INT

prepare_coverage_artifacts
build_backend

backend_dll="$(locate_backend_dll)"
log INFO "34" "Starting backend from ${backend_dll}"

if [[ "${backend_enable_coverage}" == "true" ]]; then
  log INFO "34" "Collecting backend coverage into ${coverage_output}"
  dotnet-coverage collect \
    dotnet "${backend_dll}" --contentRoot "${backend_project_dir}" \
    -f cobertura \
    -o "${coverage_output}" &
  app_pid="$!"
else
  dotnet "${backend_dll}" --contentRoot "${backend_project_dir}" &
  app_pid="$!"
fi

wait "${app_pid}"
stop_backend $?
