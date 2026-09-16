# kache clean: target directories under the current tree, and how much of
# each is already in the store. Runs after demo.tape.

Output ../clean.gif
Output ../clean.webm

Set Shell "bash"
Set FontSize 16
Set Width 1000
Set Height 640
Set Theme "Catppuccin Mocha"
Set Padding 16
Set TypingSpeed 30ms
Set Framerate 24

Hide
Type "source env.sh"
Enter
Type `cd "$KACHE_DEMO_ROOT" && clear`
Enter
Wait
Show

Type "kache clean"
Enter
Sleep 7s
Type "q"
Sleep 800ms
