# GAF command

`gaf` installs and synchronizes the canonical Global Agent Flow skills for
Codex and Claude, then provides short verification commands.

## One-time shell alias

```powershell
Set-Alias gaf E:\_Yua\Projects\global-agent-flow\scripts\gaf.ps1
```

This alias lasts for the current PowerShell session and does not modify the
user's PowerShell profile.

## Install and update

```powershell
gaf install
gaf status
gaf sync
```

By default, `install` copies skills to both supported user locations:

- Codex: `~/.agents/skills`
- Claude: `~/.claude/skills`

Use `-Provider codex` or `-Provider claude` to select one. `install` refuses to
overwrite an existing unmanaged skill. `sync` replaces only directories that
contain a matching `.gaf-managed.json` marker.

After installation, invoke the workflow with:

```text
Codex:  Use $dev-flow to implement [feature].
Claude: /dev-flow implement [feature].
```

Codex detects changes automatically in current versions; restart it if a new
skill does not appear. Claude normally detects changes inside an existing
skills directory; restart it when the top-level directory was created after the
session began.

## Project checks

From a project directory:

```powershell
gaf verify
gaf scan
```

Or specify a project:

```powershell
gaf verify E:\_Yua\Projects\aethra
gaf scan E:\_Yua\Projects\aethra
```

Add `-DryRun` to preview either command.
