#!/usr/bin/env bash
# Record the docs GIFs: assets/quickstart.gif, monitor.gif and clean.gif.
# Needs kache, cargo, python3, asciinema 3 and agg on PATH. Run it on Linux.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
out=$(cd "$here/.." && pwd)
real_home=$HOME

# A short path keeps the daemon socket under the Unix socket length limit.
root=$(mktemp -d /tmp/kache-demo.XXXXXX)
export HOME=$root/dev
export CARGO_HOME=$HOME/.cargo
export RUSTUP_HOME=${RUSTUP_HOME:-$real_home/.rustup}
export SHELL=/bin/bash TERM=xterm-256color
unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME RUSTC_WRAPPER
export PS1='\[\e[1;34m\]\W\[\e[0m\] \[\e[1;32m\]$\[\e[0m\] '

mkdir -p "$HOME"
cp -R "$here/fixtures/hello-kache" "$HOME/"
(cd "$HOME/hello-kache" && cargo fetch -q)

# Containers usually have no user systemd. Stub systemctl so the service
# prompt in `kache init` succeeds, and start the daemon ourselves.
if ! systemctl --user show-environment >/dev/null 2>&1; then
  mkdir -p "$root/bin"
  printf '#!/bin/sh\nexit 0\n' >"$root/bin/systemctl"
  chmod +x "$root/bin/systemctl"
  export PATH=$root/bin:$PATH
  kache daemon start >/dev/null
fi

record() { # scene cols x rows, font size, working directory
  (cd "$4" && asciinema rec --headless --quiet --overwrite --window-size "$2" \
    -c "python3 $here/drive.py $1" "$root/$1.cast")
  agg --theme dracula --font-size "$3" --idle-time-limit 3 --last-frame-duration 5 \
    "$root/$1.cast" "$out/$1.gif" >/dev/null
}

record quickstart 96x30 18 "$HOME/hello-kache"

cp -a "$HOME/hello-kache" "$HOME/web-app"
cp -a "$HOME/hello-kache" "$HOME/worker"
# Builds for the monitor to show while it is open.
(
  sleep 5
  cd "$HOME/web-app" && cargo clean -q && cargo build -q
  sleep 3
  cd "$HOME/worker" && cargo clean -q && cargo build -q
) >/dev/null 2>&1 &
record monitor 120x34 16 "$HOME/hello-kache"
wait

record clean 96x30 18 "$HOME"

kache daemon stop >/dev/null 2>&1 || true
rm -rf "$root"
echo "Wrote $out/quickstart.gif, $out/monitor.gif and $out/clean.gif"
