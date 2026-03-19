# ghostty-config

Portable Ghostty configuration with a cross-platform sync script.

## Files

- `config`: the tracked Ghostty configuration in this repository.
- `sync-ghostty-config.sh`: sync helper for macOS and Linux.

## Quick Start

Apply the repository version to Ghostty:

```bash
./sync-ghostty-config.sh
```

Pull the current Ghostty config back into this repository:

```bash
./sync-ghostty-config.sh pull
```

Show detected paths and install status:

```bash
./sync-ghostty-config.sh doctor
```

## Behavior

- Works on macOS and Linux.
- Uses `GHOSTTY_CONFIG_HOME`, then `XDG_CONFIG_HOME`, then `~/.config`.
- Creates the Ghostty config directory on first install or first run.
- Backs up overwritten files into `.backup/`.
- Keeps this repository as the canonical source when running without arguments.

## Config Path

Ghostty config is written to:

```text
${GHOSTTY_CONFIG_HOME:-${XDG_CONFIG_HOME:-~/.config}}/ghostty/config
```
