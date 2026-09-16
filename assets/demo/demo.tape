# First cache hit: the demo crate is built cold off screen, then the same
# commit is built in a second worktree with an empty target directory.
# See prepare.sh for the workspace; KACHE_DEMO_ROOT selects where it lives.

Output ../demo.gif
Output ../demo.webm

Set Shell "bash"
Set FontSize 16
Set Width 1000
Set Height 640
Set Theme "Catppuccin Mocha"
Set Padding 16
Set TypingSpeed 30ms
Set Framerate 24

Hide
Type 'export KACHE_DEMO_ROOT="${KACHE_DEMO_ROOT:-$([ "$(uname)" = Darwin ] && echo /Users/Shared/kache-demo || echo /tmp/kache-demo)}"'
Enter
Type 'export PATH="$KACHE_DEMO_ROOT/bin:$HOME/.cargo/bin:$PATH" KACHE_CACHE_DIR=$KACHE_DEMO_ROOT/store KACHE_RUNTIME_DIR=$KACHE_DEMO_ROOT/runtime KACHE_CONFIG=$KACHE_DEMO_ROOT/kache.toml RUSTC_WRAPPER=$KACHE_DEMO_ROOT/bin/kache CARGO_TERM_COLOR=always'
Enter
Type `cd "$KACHE_DEMO_ROOT/demo-app" && cargo build --locked >/dev/null 2>&1 && kache stats >/dev/null 2>&1 && clear`
Enter
Wait
Show

Type "# the same commit in a second worktree, empty target directory"
Enter
Sleep 800ms
Type "git worktree add ../demo-app-2 HEAD && cd ../demo-app-2"
Enter
Wait
Sleep 800ms
Type "KACHE_PROGRESS=hits cargo build --locked"
Enter
Wait
Sleep 2500ms
Type "clear && kache report --last-build | head -12"
Enter
Wait
Sleep 6s
