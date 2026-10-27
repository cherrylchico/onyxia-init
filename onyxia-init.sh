#!/bin/bash
# Run by Onyxia at service startup (init.personalInit) before code-server starts.
# Installs the VS Code extensions needed for Claude Code and Python notebooks.

extensions=(
    "anthropic.claude-code"
    "ms-python.python"
    "ms-toolsai.jupyter"
)

for extension in "${extensions[@]}"; do
    for attempt in 1 2 3; do
        code-server --install-extension "$extension" && break
        echo "Failed to install $extension (attempt $attempt/3), retrying..."
        sleep 5
    done
done

# Make the image's Python the default interpreter / notebook kernel, and show
# each cell's last run time and duration (like JupyterLab's execute-time extension).
# Also dark theme and Claude Code in the bottom panel.
settings="${HOME}/.local/share/code-server/User/settings.json"
mkdir -p "$(dirname "$settings")"
[ -s "$settings" ] || echo '{}' > "$settings"
jq --arg p "$(which python)" \
    '.["python.defaultInterpreterPath"] = $p | .["notebook.cellExecutionTimeVerbosity"] = "verbose"
     | .["workbench.colorTheme"] = "Default Dark Modern"
     | .["claudeCode.preferredLocation"] = "panel"' \
    "$settings" > "${settings}.tmp" \
    && mv "${settings}.tmp" "$settings"

# Log in to Claude Code with the long-lived token from the Onyxia secret "claude".
# Uses the env var if the secret was injected via the service's Vault tab,
# otherwise reads it from Vault directly. ~/.claude/settings.json is shared by
# the extension and the CLI.
token="${CLAUDE_CODE_OAUTH_TOKEN:-}"
if [ -z "$token" ] && command -v vault >/dev/null 2>&1; then
    token=$(vault kv get -field=CLAUDE_CODE_OAUTH_TOKEN \
        "${VAULT_MOUNT}/${VAULT_TOP_DIR}/claude" 2>/dev/null)
fi
if [ -n "$token" ]; then
    claude_settings="${HOME}/.claude/settings.json"
    mkdir -p "$(dirname "$claude_settings")"
    [ -s "$claude_settings" ] || echo '{}' > "$claude_settings"
    jq --arg t "$token" '.env.CLAUDE_CODE_OAUTH_TOKEN = $t' \
        "$claude_settings" > "${claude_settings}.tmp" \
        && mv "${claude_settings}.tmp" "$claude_settings"
    chmod 600 "$claude_settings"
else
    echo "CLAUDE_CODE_OAUTH_TOKEN not found (env or Vault secret 'claude'); skipping Claude login."
fi
