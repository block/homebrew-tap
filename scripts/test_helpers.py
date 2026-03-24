from __future__ import annotations

import pathlib


def install_fake_git(fake_bin: pathlib.Path, *, changed_path: str) -> None:
    fake_git = fake_bin / "git"
    fake_git.write_text(
        "#!/usr/bin/env bash\n"
        "set -euo pipefail\n"
        "echo \"git $*\" >> \"$COMMAND_LOG\"\n"
        "case \"${1:-}\" in\n"
        "  status)\n"
        "    if [[ \"${2:-}\" == \"--porcelain\" ]]; then\n"
        "      if [[ \"${FAKE_GIT_HAS_CHANGES:-true}\" == \"true\" ]]; then\n"
        f"        printf ' M {changed_path}\\n'\n"
        "      fi\n"
        "      exit 0\n"
        "    fi\n"
        "    ;;\n"
        "  config|checkout|add|commit|push)\n"
        "    exit 0\n"
        "    ;;\n"
        "esac\n"
        "echo \"unexpected git invocation: $*\" >&2\n"
        "exit 1\n"
    )
    fake_git.chmod(0o755)


def install_fake_gh(fake_bin: pathlib.Path) -> None:
    fake_gh = fake_bin / "gh"
    fake_gh.write_text(
        "#!/usr/bin/env bash\n"
        "set -euo pipefail\n"
        "echo \"gh $*\" >> \"$COMMAND_LOG\"\n"
        "capture_body() {\n"
        "  local body_file=\"\"\n"
        "  local i=1\n"
        "  while [[ $i -le $# ]]; do\n"
        "    local arg=\"${!i}\"\n"
        "    if [[ \"$arg\" == \"--body-file\" ]]; then\n"
        "      i=$((i + 1))\n"
        "      body_file=\"${!i}\"\n"
        "      break\n"
        "    fi\n"
        "    i=$((i + 1))\n"
        "  done\n"
        "  if [[ -n \"$body_file\" ]]; then\n"
        "    {\n"
        "      echo \"PR_BODY_START\"\n"
        "      cat \"$body_file\"\n"
        "      echo \"PR_BODY_END\"\n"
        "    } >> \"$PR_BODY_LOG\"\n"
        "  fi\n"
        "}\n"
        "if [[ \"${1:-}\" == \"pr\" && \"${2:-}\" == \"list\" ]]; then\n"
        "  printf '%s\\n' \"${FAKE_EXISTING_PR_URL:-null}\"\n"
        "  exit 0\n"
        "fi\n"
        "if [[ \"${1:-}\" == \"pr\" && \"${2:-}\" == \"edit\" ]]; then\n"
        "  capture_body \"$@\"\n"
        "  exit 0\n"
        "fi\n"
        "if [[ \"${1:-}\" == \"pr\" && \"${2:-}\" == \"create\" ]]; then\n"
        "  capture_body \"$@\"\n"
        "  printf '%s\\n' \"${FAKE_CREATED_PR_URL:-}\"\n"
        "  exit 0\n"
        "fi\n"
        "echo \"unexpected gh invocation: $*\" >&2\n"
        "exit 1\n"
    )
    fake_gh.chmod(0o755)
