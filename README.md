# onyxia-init

Startup script for Onyxia VS Code services. It runs before VS Code starts, so
every new service is ready to use without manual setup.

## What it does

### Extensions
- **Claude Code** (`anthropic.claude-code`)
- **Python** (`ms-python.python`)
- **Jupyter** (`ms-toolsai.jupyter`)

### Python & notebooks
- Sets the image's Python (`/opt/python/bin/python`) as the default interpreter
  and notebook kernel
- Shows each cell's last run time and duration

### Claude login
- Reads `CLAUDE_CODE_OAUTH_TOKEN` from the Onyxia secret `claude` (or from the
  environment, if that secret is injected via the service's Vault tab) and
  writes it to the `env` block of `~/.claude/settings.json`, so the Claude Code
  extension starts already logged in

### Appearance
- Uses the **Default Dark Modern** theme
- Opens Claude Code in the bottom panel

## Usage

In the Onyxia service launcher, set **Init → personalInit** to:

```
https://raw.githubusercontent.com/cherrylchico/onyxia-init/main/onyxia-init.sh
```
