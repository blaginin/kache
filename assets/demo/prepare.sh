#!/usr/bin/env bash
# Build the workspace the tapes in this directory record against.
#
#   assets/demo/prepare.sh [path/to/kache]     # defaults to `kache` on PATH
#   cd assets/demo && vhs demo.tape && vhs why-miss.tape && vhs monitor.tape && vhs clean.tape
#
# Everything lives under $KACHE_DEMO_ROOT (default /Users/Shared/kache-demo on
# macOS, where `kache clean` skips /private, and /tmp/kache-demo elsewhere): a
# scratch store and config, so the
# recordings never touch your own cache, and a small crate with a lockfile
# committed to a git repository. `demo.tape` builds it cold off screen, then
# records the second worktree; the later tapes build on that state, so run
# them in the order above. Re-run this script to start over.
set -euo pipefail
kache_bin="$(command -v "${1:-kache}")"
root="${KACHE_DEMO_ROOT:-$([ "$(uname)" = Darwin ] && echo /Users/Shared/kache-demo || echo /tmp/kache-demo)}"
rm -rf "$root"
mkdir -p "$root/bin" "$root/store" "$root/runtime"
ln -s "$kache_bin" "$root/bin/kache"
printf '# scratch configuration for the recordings\n' > "$root/kache.toml"

cargo new -q "$root/demo-app"
cd "$root/demo-app"
cat > Cargo.toml <<'TOML'
[package]
name = "demo-app"
version = "0.1.0"
edition = "2021"

[dependencies]
anyhow = "1"
clap = { version = "4", features = ["derive"] }
regex = "1"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
sha2 = "0.10"
walkdir = "2"
TOML
cat > src/main.rs <<'RS'
use anyhow::Result;
use clap::Parser;
use serde::Serialize;
use sha2::{Digest, Sha256};
use std::path::PathBuf;
use walkdir::WalkDir;

/// Hash every file below a directory and print the digests as JSON.
#[derive(Parser)]
struct Args {
    /// Directory to scan
    root: PathBuf,
    /// Only files whose name matches this pattern
    #[arg(long)]
    name: Option<String>,
}

#[derive(Serialize)]
struct Entry {
    path: String,
    sha256: String,
}

fn main() -> Result<()> {
    let args = Args::parse();
    let filter = args.name.as_deref().map(regex::Regex::new).transpose()?;
    let mut entries = Vec::new();
    for file in WalkDir::new(&args.root).into_iter().filter_map(Result::ok) {
        if !file.file_type().is_file() {
            continue;
        }
        let name = file.file_name().to_string_lossy();
        if filter.as_ref().is_some_and(|re| !re.is_match(&name)) {
            continue;
        }
        let bytes = std::fs::read(file.path())?;
        entries.push(Entry {
            path: file.path().display().to_string(),
            sha256: format!("{:x}", Sha256::digest(&bytes)),
        });
    }
    println!("{}", serde_json::to_string_pretty(&entries)?);
    Ok(())
}
RS
printf 'target\n' > .gitignore
cargo generate-lockfile -q
git init -q
git add -A
git -c user.name=demo -c user.email=demo@example.com commit -q -m "demo app"
echo "ready: $root (kache: $kache_bin)"
