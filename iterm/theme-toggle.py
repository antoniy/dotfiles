#!/usr/bin/env python3
"""iTerm2 day/night theme toggle that works inside any full-screen app.

Bind a hotkey to it via:
    Settings → Keys → Key Bindings → + → (press ⌥⇧T)
    Action: "Invoke Script Function"
    Value:  theme_toggle(session_id: session.id)

It delegates the cross-tool sync to the dotfiles `theme` zsh function (state
file + tmux status bar + bat + claude), then applies the iTerm2 colour preset
to the *current* session by injecting the same SetColors OSC the shell uses.
Because the bytes are injected straight into iTerm2's terminal for this session
(bypassing the shell and tmux), it's session-local, ephemeral, and fires even
when a TUI app — vim, less, htop, ssh — owns the terminal.

Install: symlinked into ~/Library/Application Support/iTerm2/Scripts/AutoLaunch/
so iTerm2 runs it as a "Basic" script at startup. Requires the iTerm2 Python
API enabled (Settings → General → Magic → Enable Python API).
"""

import asyncio

import iterm2

# Source theme.zsh in a clean shell, toggle, and echo the resulting preset name.
# PATH is set explicitly because iTerm2 launches scripts with a minimal
# environment — without it, theme.zsh's tmux/jq calls would silently no-op.
TOGGLE_CMD = (
    'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"; '
    'source "$HOME/.config/zsh/theme.zsh"; '
    'theme toggle >/dev/null 2>&1; '
    'theme-iterm-preset'
)


async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def theme_toggle(session_id):
        proc = await asyncio.create_subprocess_exec(
            "/bin/zsh", "-c", TOGGLE_CMD,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.DEVNULL,
        )
        out, _ = await proc.communicate()
        lines = out.decode(errors="replace").split()
        if not lines:
            return
        preset = lines[-1]

        session = app.get_session_by_id(session_id)
        if session is None:
            return

        # Same OSC the shell's _theme_iterm emits; injected as program output so
        # iTerm2 applies it to this session only. No tmux passthrough wrapper is
        # needed here — injection bypasses tmux entirely.
        await session.async_inject(
            b"\033]1337;SetColors=preset=" + preset.encode() + b"\007"
        )

    await theme_toggle.async_register(connection)


iterm2.run_forever(main)
