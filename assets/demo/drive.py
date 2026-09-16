"""Type scripted terminal sessions for the docs GIFs.

Runs an interactive bash in a pty, types each scene's commands at human
speed, and copies the output to stdout for asciinema to record.
Usage: python3 drive.py <scene>
"""

import fcntl, os, pty, random, re, select, struct, sys, termios, time

SCENES = {
    "quickstart": [
        ("sleep", 1.0),
        ("type", "kache init"), ("enter",),
        ("wait", r"\[Y/n\] "), ("sleep", 1.2), ("enter",),
        ("wait", r"\[Y/n\] "), ("sleep", 1.2), ("enter",),
        ("wait", r"\[Y/n\] "), ("sleep", 1.2), ("enter",),
        ("wait", r"kache doctor to check"), ("sleep", 3.5),
        ("type", "clear"), ("enter",), ("sleep", 0.6),
        ("type", "cargo build"), ("enter",),
        ("wait", r"Finished"), ("sleep", 2.5),
        ("type", "cargo clean"), ("enter",),
        ("wait", r"Removed"), ("sleep", 1.2),
        ("type", "cargo build"), ("enter",),
        ("wait", r"Finished"), ("sleep", 6),
    ],
    "monitor": [
        ("sleep", 1.0),
        ("type", "kache monitor"), ("enter",),
        ("sleep", 16),
        ("keys", "j"), ("sleep", 1.5),
        ("keys", "k"), ("sleep", 1.5),
        ("enter",), ("sleep", 7),
        ("keys", "4"), ("sleep", 5),
        ("keys", "q"), ("sleep", 1),
    ],
    "clean": [
        ("sleep", 1.0),
        ("type", "kache clean"), ("enter",),
        ("sleep", 9),
        ("keys", "q"), ("sleep", 1),
    ],
}

steps = SCENES[sys.argv[1]]
rows, cols = struct.unpack("HHHH", fcntl.ioctl(1, termios.TIOCGWINSZ, b"\0" * 8))[:2]
pid, fd = pty.fork()
if pid == 0:
    os.execvp("bash", ["bash", "--noprofile", "--norc", "-i"])
fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))

buf = ""
mark = 0

def pump(timeout):
    global buf
    end = time.time() + timeout
    while True:
        left = end - time.time()
        if left <= 0:
            return
        r, _, _ = select.select([fd], [], [], left)
        if not r:
            return
        try:
            data = os.read(fd, 65536)
        except OSError:
            return
        if not data:
            return
        os.write(1, data)
        buf += data.decode("utf-8", "replace")

def send(s):
    os.write(fd, s.encode())

pump(1.0)
for step in steps:
    kind = step[0]
    if kind == "sleep":
        pump(step[1])
    elif kind == "type":
        for ch in step[1]:
            send(ch)
            pump(random.uniform(0.04, 0.09))
        pump(0.4)
    elif kind == "enter":
        send("\r")
        pump(0.05)
    elif kind == "keys":
        send(step[1])
        pump(0.05)
    elif kind == "wait":
        deadline = time.time() + 300
        while time.time() < deadline:
            m = re.search(step[1], buf[mark:])
            if m:
                mark += m.end()
                break
            pump(0.1)
os.kill(pid, 9)
