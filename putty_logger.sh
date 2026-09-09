#!/bin/bash
# ==============================================================================
# Script Name : disable_terminal_escape_sequences.sh
# Description : Disable OSC 3008, terminal title updates and bracketed paste
# Tested On   : Ubuntu 24.04
# ==============================================================================

set -e

echo "============================================================"
echo " Disabling Terminal Escape Sequences"
echo "============================================================"

#
# 1. Disable systemd OSC 3008 context
#
if [ -L /etc/profile.d/80-systemd-osc-context.sh ] || [ -f /etc/profile.d/80-systemd-osc-context.sh ]; then
    echo "[INFO] Removing systemd OSC 3008 profile..."

    sudo rm -f /etc/profile.d/80-systemd-osc-context.sh

    echo "[ OK ] OSC 3008 disabled."
else
    echo "[SKIP] OSC 3008 profile already removed."
fi

#
#
# 2. Disable terminal title updates
#
BASHRC="$HOME/.bashrc"

if grep -q 'PS1=.*\\e]0;' "$BASHRC"; then
    echo "[INFO] Disabling terminal title updates..."

    sed -i '/\\e]0;/ s/^/# /' "$BASHRC"

    echo "[ OK ] Terminal title updates disabled."
else
    echo "[SKIP] Terminal title update already disabled."
fi

#
# 3. Disable bracketed paste
#
INPUTRC="$HOME/.inputrc"

if [ ! -f "$INPUTRC" ]; then
    touch "$INPUTRC"
fi

if grep -q '^set enable-bracketed-paste off$' "$INPUTRC"; then
    echo "[SKIP] Bracketed paste already disabled."
else
    echo "set enable-bracketed-paste off" >> "$INPUTRC"
    echo "[ OK ] Bracketed paste disabled."
fi

#
# 4. Reload inputrc
#
bind -f "$INPUTRC" 2>/dev/null || true

echo
echo "============================================================"
echo " Completed Successfully"
echo "============================================================"
echo
echo "Please logout and reconnect to apply all changes."
