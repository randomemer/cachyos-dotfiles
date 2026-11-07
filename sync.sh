#!/usr/bin/env bash
# Pull the live config on this machine into the repo.
#
# Safe to re-run. Paths already symlinked back out (see link.sh) are skipped —
# for those the live file *is* the repo file, so there is nothing to copy.
#
#   ./sync.sh            copy live -> repo
#   ./sync.sh --dry-run  show what would change, touch nothing

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0
[[ ${1:-} == "--dry-run" ]] && DRY=1

copied=0 skipped=0 missing=0

while read -r tag path; do
    [[ -z ${tag:-} || $tag == \#* ]] && continue

    src="$HOME/$path"
    dst="$REPO/$path"

    if [[ ! -e $src ]]; then
        printf '  missing  %s\n' "$path"
        (( ++missing ))
        continue
    fi

    # Already linked out of the repo — copying would be a no-op onto itself.
    if [[ -L $src && $(readlink -f "$src") == "$dst" ]]; then
        (( ++skipped ))
        continue
    fi

    if [[ -f $dst ]] && cmp -s "$src" "$dst"; then
        (( ++skipped ))
        continue
    fi

    printf '  copy     %s\n' "$path"
    if (( ! DRY )); then
        mkdir -p "$(dirname "$dst")"
        cp -a "$src" "$dst"
    fi
    (( ++copied ))
done < <(grep -v '^\s*#' "$REPO/manifest.txt" | grep -v '^\s*$')

printf '\n%d copied, %d unchanged/linked, %d missing\n' "$copied" "$skipped" "$missing"
(( DRY )) && printf '(dry run — nothing written)\n'
exit 0
