# Dotfiles Bootstrap

> One-liner installation system for [dotfiles](https://github.com/alejakun/dotfiles)

Privacy-focused bootstrap that installs prerequisites and clones dotfiles without exposing sensitive information.

---

## Quick Start

### New Mac Setup

Run this single command to bootstrap everything:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/dotfiles-bootstrap/main/bin/pre-bootstrap.sh)
```

This will:
1. Install Xcode Command Line Tools
2. Install Homebrew
3. Install GitHub CLI (`gh`)
4. Authenticate with GitHub (browser-based, no SSH keys needed)
5. Configure Git with your GitHub identity (dynamic discovery)
6. Optionally execute full dotfiles installation

---

## Manual Installation

If you prefer step-by-step control:

### Step 1: Prerequisites

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/dotfiles-bootstrap/main/bin/pre-bootstrap.sh)
```

### Step 2: Clone and Install Dotfiles

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/dotfiles-bootstrap/main/bin/bootstrap.sh)
```

---

## What Gets Installed

### Pre-Bootstrap (`pre-bootstrap.sh`)
- **Xcode Command Line Tools** - Required for compilation
- **Homebrew** - Package manager for macOS
- **GitHub CLI** - Authentication and repo management
- **Git Configuration** - User name/email from GitHub API

### Bootstrap (`bootstrap.sh`)
- Clones your dotfiles repo (HTTPS, no SSH key needed)
- Initializes submodules
- Sets up logging directory (`~/.dotfiles-install-logs/`)
- Runs full installation (`bin/install.sh --all`)
- Generates post-mortem report

---

## Features

- **No SSH Keys Required** - Uses GitHub CLI with browser auth
- **Privacy-Focused** - No hardcoded emails or usernames
- **Dynamic Discovery** - Detects GitHub user automatically
- **Comprehensive Logging** - All actions logged to `~/.dotfiles-install-logs/`
- **Post-Mortem Reports** - Summary of installation with verification steps
- **Continue on Error** - Installation completes even if individual steps fail

---

## Logs and Reports

Installation logs are stored in:

```
~/.dotfiles-install-logs/
├── install-YYYYMMDD-HHMMSS.log
└── report-YYYYMMDD-HHMMSS.md
```

View logs:
```bash
ls -lt ~/.dotfiles-install-logs/
cat ~/.dotfiles-install-logs/install-*.log
```

---

## Troubleshooting

### Prerequisites Missing

If you see "Faltan X prerequisito(s)":
1. Run `pre-bootstrap.sh` first
2. Verify Homebrew: `brew --version`
3. Verify GitHub CLI: `gh --version`
4. Verify authentication: `gh auth status`

### Clone Fails

If cloning fails:
1. Check authentication: `gh auth status`
2. Verify repo exists: `gh repo view alejakun/dotfiles`
3. Try manual clone: `gh repo clone alejakun/dotfiles ~/.dotfiles`

### Installation Errors

Check the logs:
```bash
tail -f ~/.dotfiles-install-logs/install-*.log
```

See [dotfiles troubleshooting](https://github.com/alejakun/dotfiles/blob/main/docs/troubleshooting.md)

---

## Requirements

- macOS 11.0 (Big Sur) or later
- Internet connection
- Admin privileges (for Homebrew/Xcode installation)

---

## Privacy

This bootstrap system is designed with privacy in mind:
- No hardcoded emails or personal information
- Uses GitHub private email for commits
- All user data discovered dynamically via GitHub API
- No sensitive information in public code

---

## License

MIT License - See [dotfiles LICENSE](https://github.com/alejakun/dotfiles/blob/main/LICENSE)

---

## Related

- [dotfiles](https://github.com/alejakun/dotfiles) - Main dotfiles repository (private)
- [GitHub CLI](https://cli.github.com/) - Official GitHub CLI

---

**Author:** Alex (@alejakun)
