#!/usr/bin/env bash
# Replace the live config with symlinks into this repo, for `link`-tagged paths
# only. `copy`-tagged paths are left as real files — see README.
#
# The original is moved to .backup/<timestamp>/ before each link is made.
#
#   ./link.sh            link the `link` tier
#   ./link.sh --dry-run  show what would change, touch nothing
#   ./link.sh --all      also link the `copy` tier (read the README first)
#   ./link.sh --unlink   put real files back, undoing the above

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$REPO/.backup/$(date +%Y%m%d-%H%M%S)"
DRY=0 ALL=0 UNLINK=0

for arg in "$@"; do
    case $arg in
        --dry-run) DRY=1 ;;
        --all)     ALL=1 ;;
        --unlink)  UNLINK=1 ;;
        *) printf 'unknown option: %s\n' "$arg" >&2; exit 2 ;;
    esac
done

linked=0 skipped=0 missing=0

while read -r tag path; do
    [[ -z ${tag:-} || $tag == \#* ]] && continue
    [[ $tag == copy && $ALL -eq 0 ]] && continue

    src="$REPO/$path"
    dst="$HOME/$path"

    if [[ ! -e $src ]]; then
        printf '  missing in repo  %s\n' "$path"
        (( ++missing ))
        continue
    fi

    if (( UNLINK )); then
        if [[ -L $dst && $(readlink -f "$dst") == "$src" ]]; then
            printf '  unlink   %s\n' "$path"
            if (( ! DRY )); then
                rm "$dst"
                cp -a "$src" "$dst"
            fi
            (( ++linked ))
        else
            (( ++skipped ))
        fi
        continue
    fi

    # Already pointing at the repo.
    if [[ -L $dst && $(readlink -f "$dst") == "$src" ]]; then
        (( ++skipped ))
        continue
    fi

    printf '  link     %s\n' "$path"
    if (( ! DRY )); then
        mkdir -p "$(dirname "$dst")"
        if [[ -e $dst || -L $dst ]]; then
            mkdir -p "$(dirname "$BACKUP/$path")"
            mv "$dst" "$BACKUP/$path"
        fi
        ln -s "$src" "$dst"
    fi
    (( ++linked ))
done < <(grep -v '^\s*#' "$REPO/manifest.txt" | grep -v '^\s*$')

verb=$( (( UNLINK )) && echo unlinked || echo linked )
printf '\n%d %s, %d already correct, %d missing\n' "$linked" "$verb" "$skipped" "$missing"
if (( linked && ! DRY && ! UNLINK )); then
    printf 'originals backed up to %s\n' "${BACKUP/#$HOME/\~}"
fi
(( DRY )) && printf '(dry run — nothing written)\n'
exit 0
