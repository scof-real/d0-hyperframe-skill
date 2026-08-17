#!/usr/bin/env bash
set -euo pipefail

project_dir="${1:-.}"
mode="${2:-}"
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
skill_root="$(CDPATH= cd -- "${script_dir}/.." && pwd)"

mkdir -p "${project_dir}"

if [[ "${mode}" != "--assets-only" ]]; then
  if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
    printf 'Node.js 18+ and npx are required. Install Node.js, then rerun.\n' >&2
    exit 1
  fi

  node_major="$(node -p 'Number(process.versions.node.split(".")[0])')"
  if [[ "${node_major}" -lt 18 ]]; then
    printf 'Node.js 18+ is required; found %s.\n' "$(node --version)" >&2
    exit 1
  fi

  (
    cd "${project_dir}"
    HYPERFRAMES_SKIP_SKILLS=1 npx hyperframes@latest init . --non-interactive --example blank --skill=d0-hyperframe
  )
fi

mkdir -p "${project_dir}/assets" "${project_dir}/fonts"
cp "${skill_root}/assets/brand/d0-logo.png" "${project_dir}/assets/d0-logo.png"
cp "${skill_root}/assets/brand/d0-avatar.jpg" "${project_dir}/assets/d0-avatar.jpg"
cp "${skill_root}/assets/fonts/"*.woff2 "${project_dir}/fonts/"

printf 'D0 project assets are ready in %s\n' "$(CDPATH= cd -- "${project_dir}" && pwd)"
