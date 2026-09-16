# Docs GIFs

`record.sh` records the terminal GIFs used in the README and docs:

- `assets/quickstart.gif`: `kache init`, a cold build, `cargo clean`, and a warm build.
- `assets/monitor.gif`: `kache monitor` while two other projects build.
- `assets/clean.gif`: `kache clean` listing three target directories.

## Regenerate

On Linux, with `kache`, `cargo`, `python3`, [asciinema](https://github.com/asciinema/asciinema) 3, and [agg](https://github.com/asciinema/agg) on `PATH`:

```sh
assets/demo/record.sh
```

The script uses a temporary `HOME`, so it does not touch your Cargo or Kache configuration. `drive.py` types each scene into a real bash session; edit its `SCENES` table to change what gets recorded. The workload is [`fixtures/hello-kache`](fixtures/hello-kache).
