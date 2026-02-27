#!/usr/bin/env bash
set -euo pipefail
# Scan for GitHub Actions "::set-output" uses and optionally convert them
# to the recommended environment file approach (`$GITHUB_OUTPUT`).

usage() {
  cat <<EOF
Usage: $0 [--apply] [--include-ignored]

Options:
  --apply             Actually modify files (creates backups with .bak)
  --include-ignored   Include files ignored by git/gitattributes
  -h, --help          Show this help
EOF
  exit 1
}

APPLY=false
INCLUDE_IGNORED=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --apply) APPLY=true; shift;;
    --include-ignored) INCLUDE_IGNORED=true; shift;;
    -h|--help) usage;;
    *) echo "Unknown arg: $1"; usage;;
  esac
done

GREP_OPTS=(--no-color -n)
if $INCLUDE_IGNORED; then
  GREP_OPTS+=(--no-ignore)
fi

FILES=$(git grep -l "::set-output" "${GREP_OPTS[@]}" || true)
if [[ -z "$FILES" ]]; then
  echo "No files using ::set-output found."
  exit 0
fi

echo "Found ::set-output in these files:"
echo "$FILES"
echo

for f in $FILES; do
  echo "--- $f ---"
  if ! $APPLY; then
    echo "Dry run: occurrences:";
    grep --color=always -n "::set-output" "$f" || true
    echo
    echo "Suggested replacements (examples):"
    echo "  Old: echo \"echo "MYVAR=some value\""" >> $GITHUB_OUTPUT
    echo "  New (bash): echo \"MYVAR=some value\" >> \$GITHUB_OUTPUT"
    echo "  New (powershell): Add-Content -Path \$env:GITHUB_OUTPUT -Value 'MYVAR=some value'"
  else
    cp "$f" "$f.bak"
    # Replace common bash echo patterns
    sed -E -e 's#echo[[:space:]]+"::set-output name=([^:]+)::(.*)"#echo "\1=\2" >> "\$GITHUB_OUTPUT"#g' \
             -e "s#echo[[:space:]]+'::set-output name=([^:]+)::(.*)'#echo \"\\1=\\2\" >> \"\$GITHUB_OUTPUT\"#g" \
             -i "$f"

    # For PowerShell scripts inside workflows, replace common single-line set-output usages
    sed -E -e "s#Write-Host '\:\:set-output name=([^:]+)::([^']*)'#Add-Content -Path \$env:GITHUB_OUTPUT -Value '\1=\2'#g" -i "$f" || true

    echo "Applied changes to $f (backup: $f.bak)"
  fi
  echo
done

echo "Done."

