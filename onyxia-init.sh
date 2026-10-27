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
