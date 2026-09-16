# kache monitor while a build runs in a third worktree.
# Runs after demo.tape.

Output ../monitor.gif
Output ../monitor.webm

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
Type `cd "$KACHE_DEMO_ROOT/demo-app" && git worktree add ../demo-app-3 HEAD >/dev/null 2>&1; (sleep 3 && cd ../demo-app-3 && cargo build --locked >/dev/null 2>&1) & clear`
Enter
Wait
Show

Type "kache monitor --since 1h"
Enter
Sleep 8s
Type "2"
Sleep 3500ms
Type "3"
Sleep 3500ms
Type "4"
Sleep 3500ms
Type "q"
Sleep 800ms
