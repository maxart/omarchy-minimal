#!/bin/bash
# Register this local theme and its GTK integration; --apply also selects it.
set -euo pipefail
theme_source=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
theme_target="$HOME/.config/omarchy/themes/minimal"
hook_target="$HOME/.config/omarchy/hooks/theme-set.d/minimal-gtk"
action=${1:-install}
if (( $# > 1 )) || [[ $action != install && $action != --apply && $action != --uninstall ]]; then
  echo "Usage: $0 [--apply | --uninstall]" >&2
  exit 2
fi

if [[ $action == --uninstall ]]; then
  if [[ $(readlink -f -- "$theme_target" 2>/dev/null || true) != "$theme_source" ]]; then
    echo "Theme registration does not point to this directory; leaving it untouched." >&2
    exit 1
  fi
  if [[ $(omarchy theme current | tr '[:upper:]' '[:lower:]' | tr ' ' '-') == minimal ]]; then
    echo "Select another Omarchy theme before uninstalling Minimal." >&2
    exit 1
  fi
  python3 "$theme_source/scripts/update-gtk.py" remove
  if [[ -f $hook_target ]] && cmp -s "$hook_target" "$theme_source/scripts/minimal-gtk"; then
    rm -- "$hook_target"
  fi
  [[ ! -L $theme_target ]] || rm -- "$theme_target"
  echo "Minimal unregistered. Source files and GTK backups retained."
  exit
fi

command -v omarchy >/dev/null
command -v python3 >/dev/null
if [[ -e $theme_target || -L $theme_target ]]; then
  if [[ ! -L $theme_target || $(readlink -f -- "$theme_target") != "$theme_source" ]]; then
    echo "Already exists: $theme_target; move it aside before installing." >&2
    exit 1
  fi
fi
if [[ -e $hook_target ]] && ! cmp -s "$hook_target" "$theme_source/scripts/minimal-gtk"; then
  echo "An existing hook uses $hook_target; move it aside before installing." >&2
  exit 1
fi
mkdir -p -- "$(dirname -- "$theme_target")"
[[ -L $theme_target ]] || ln -s -- "$theme_source" "$theme_target"
omarchy hook install theme-set "$theme_source/scripts/minimal-gtk"
if [[ $action == --apply ]]; then
  omarchy theme set minimal
  hyprctl reload
  config_errors=$(hyprctl configerrors)
  if [[ -n $config_errors && $config_errors != ok ]]; then
    printf '%s\n' "$config_errors" >&2
    exit 1
  fi
  echo "Minimal applied. Reopen GTK apps to load their new stylesheet."
else
  echo 'Minimal installed. Apply with: omarchy theme set minimal'
fi
