#!/usr/bin/env bash
set -euo pipefail

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
codex_root="${CODEX_HOME:-${HOME}/.codex}"
skills_root="${1:-${codex_root}/skills}"
backup_stamp="$(date +%Y%m%d-%H%M%S)"
backup_root="${skills_root}/.d0-skill-backups/${backup_stamp}"

install_skill() {
  skill_name="$1"
  source_dir="${repo_root}/skills/${skill_name}"
  destination_dir="${skills_root}/${skill_name}"

  if [[ ! -f "${source_dir}/SKILL.md" ]]; then
    printf 'Missing required source: %s\n' "${source_dir}/SKILL.md" >&2
    exit 1
  fi

  if [[ -d "${destination_dir}" ]]; then
    mkdir -p "${backup_root}"
    cp -R "${destination_dir}" "${backup_root}/${skill_name}"
    printf 'Backed up %s to %s\n' "${skill_name}" "${backup_root}/${skill_name}"
  fi

  mkdir -p "${destination_dir}"
  cp -R "${source_dir}/." "${destination_dir}/"
  printf 'Installed %s -> %s\n' "${skill_name}" "${destination_dir}"
}

install_skill d0-brand
install_skill d0-hyperframe

python3 "${repo_root}/scripts/validate.py" --installed-root "${skills_root}"

printf '\nReady. Restart Codex, then ask: 使用 d0-hyperframe 做一个 D0 视频。\n'
