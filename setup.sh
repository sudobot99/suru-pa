#!/usr/bin/env bash
# =============================================================================
# Suru-PA Setup Script
# Installs and configures all dependencies for a full OpenClaw personal
# assistant deployment, matching the Suru Solutions golden image.
#
# Tested on: macOS (Apple Silicon + Intel)
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

step()  { echo -e "\n${BLUE}${BOLD}▶ $1${NC}"; }
ok()    { echo -e "${GREEN}✓ $1${NC}"; }
warn()  { echo -e "${YELLOW}⚠ $1${NC}"; }
fail()  { echo -e "${RED}✗ $1${NC}"; exit 1; }
info()  { echo -e "  $1"; }

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════╗"
echo "║         Suru-PA Setup  v1.0              ║"
echo "║  Personal Assistant — OpenClaw Template  ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# 1. OS Check
# =============================================================================
step "Checking system"
OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$OS" != "Darwin" ]]; then
  fail "This script is designed for macOS. Linux support coming later."
fi
ok "macOS detected ($ARCH)"

# =============================================================================
# 2. Homebrew
# =============================================================================
step "Homebrew"
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add to PATH for Apple Silicon
  if [[ "$ARCH" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  ok "Homebrew already installed ($(brew --version | head -1))"
fi

# =============================================================================
# 3. Node.js (v22 LTS)
# =============================================================================
step "Node.js"
if ! command -v node &>/dev/null || [[ "$(node --version | cut -d. -f1 | tr -d v)" -lt 20 ]]; then
  info "Installing node@22..."
  brew install node@22
  # Link if needed
  brew link --overwrite node@22 2>/dev/null || true
  ok "Node.js installed"
else
  ok "Node.js already installed ($(node --version))"
fi
NPM="$(which npm)"

# =============================================================================
# 4. Homebrew packages
# =============================================================================
step "Homebrew packages"
BREW_PACKAGES=(
  "gh"                                    # GitHub CLI
  "1password-cli"                         # 1Password CLI (op)
  "yakitrak/yakitrak/obsidian-cli"       # Obsidian CLI
  "git"                                   # Git
)

for pkg in "${BREW_PACKAGES[@]}"; do
  # Extract just the formula name for display
  name="${pkg##*/}"
  if brew list "$name" &>/dev/null 2>&1; then
    ok "$name already installed"
  else
    info "Installing $name..."
    brew install "$pkg"
    ok "$name installed"
  fi
done

# =============================================================================
# 5. OpenClaw
# =============================================================================
step "OpenClaw"
if command -v openclaw &>/dev/null; then
  ok "OpenClaw already installed ($(openclaw --version 2>/dev/null | head -1 || echo 'version unknown'))"
else
  info "Installing OpenClaw..."
  $NPM install -g openclaw
  ok "OpenClaw installed"
fi

# =============================================================================
# 6. Coding CLIs (Claude Code, Codex, Gemini)
# =============================================================================
step "Coding CLIs"

# Claude Code
if command -v claude &>/dev/null; then
  ok "Claude Code already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
  info "Installing Claude Code CLI..."
  $NPM install -g @anthropic-ai/claude-code
  ok "Claude Code installed"
fi

# OpenAI Codex
if command -v codex &>/dev/null; then
  ok "Codex CLI already installed ($(codex --version 2>/dev/null || echo 'version unknown'))"
else
  info "Installing Codex CLI..."
  $NPM install -g @openai/codex
  ok "Codex CLI installed"
fi

# Google Gemini CLI
if command -v gemini &>/dev/null; then
  ok "Gemini CLI already installed ($(gemini --version 2>/dev/null || echo 'version unknown'))"
else
  info "Installing Gemini CLI..."
  $NPM install -g @google/gemini-cli
  ok "Gemini CLI installed"
fi

# =============================================================================
# 7. Git config
# =============================================================================
step "Git configuration"
if [[ -z "$(git config --global user.name)" ]]; then
  echo ""
  read -p "  Git name (e.g. 'SuruBot'): " GIT_NAME
  read -p "  Git email: " GIT_EMAIL
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  ok "Git configured as '$GIT_NAME <$GIT_EMAIL>'"
else
  ok "Git already configured ($(git config --global user.name) <$(git config --global user.email)>)"
fi

# =============================================================================
# 8. GitHub CLI auth
# =============================================================================
step "GitHub CLI"
if gh auth status &>/dev/null; then
  ok "GitHub CLI already authenticated"
else
  warn "GitHub CLI not authenticated. Launching auth flow..."
  info "You'll need a GitHub account. Press ENTER to continue or Ctrl+C to skip."
  read -p ""
  gh auth login
fi

# =============================================================================
# 9. Obsidian vault setup
# =============================================================================
step "Obsidian vault"

VAULT_DIR="$HOME/Documents/SuruBrain"
SCAFFOLD_DIR="$(cd "$(dirname "$0")" && pwd)/obsidian-scaffold"

if obsidian-cli print-default &>/dev/null; then
  ok "obsidian-cli already has a default vault: $(obsidian-cli print-default)"
else
  info "Setting up Obsidian vault at $VAULT_DIR..."
  if [[ ! -d "$VAULT_DIR" ]]; then
    mkdir -p "$VAULT_DIR"
    # Copy scaffold
    if [[ -d "$SCAFFOLD_DIR" ]]; then
      cp -r "$SCAFFOLD_DIR/." "$VAULT_DIR/"
      info "Vault scaffold copied to $VAULT_DIR"
    fi
    # Init git repo
    cd "$VAULT_DIR"
    git init && git add -A && git commit -m "init: Obsidian vault from Suru-PA scaffold" 2>/dev/null || true
    cd - &>/dev/null
  fi

  # Set as default vault (folder name only, not full path)
  VAULT_NAME="$(basename "$VAULT_DIR")"
  warn "To complete Obsidian setup:"
  info "1. Open Obsidian → File → Open Folder as Vault → select: $VAULT_DIR"
  info "2. Then run: obsidian-cli set-default \"$VAULT_NAME\""
  info "(Obsidian must be open and have the vault loaded for obsidian-cli to work)"
fi

# =============================================================================
# 10. OpenClaw workspace
# =============================================================================
step "OpenClaw workspace"
WORKSPACE_DIR="$HOME/.openclaw/workspace"

if [[ -f "$WORKSPACE_DIR/SOUL.md" ]]; then
  warn "Workspace already exists at $WORKSPACE_DIR — skipping copy to avoid overwrite"
  info "To apply the Suru-PA template: manually copy files from this repo to $WORKSPACE_DIR"
else
  info "Deploying template to $WORKSPACE_DIR..."
  mkdir -p "$WORKSPACE_DIR/state" "$WORKSPACE_DIR/prompts" "$WORKSPACE_DIR/memory"
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

  for f in SOUL.md USER.md IDENTITY.md AGENTS.md HEARTBEAT.md MEMORY.md TOOLS.md BOOTSTRAP.md; do
    if [[ -f "$SCRIPT_DIR/$f" ]]; then
      cp "$SCRIPT_DIR/$f" "$WORKSPACE_DIR/$f"
    fi
  done
  cp "$SCRIPT_DIR/state/active-context.json" "$WORKSPACE_DIR/state/active-context.json"
  [[ -d "$SCRIPT_DIR/prompts" ]] && cp -r "$SCRIPT_DIR/prompts/." "$WORKSPACE_DIR/prompts/"

  # Init git if not already
  if [[ ! -d "$WORKSPACE_DIR/.git" ]]; then
    cd "$WORKSPACE_DIR"
    git init && git add -A && git commit -m "init: Suru-PA workspace template deployed"
    cd - &>/dev/null
  fi
  ok "Template deployed to $WORKSPACE_DIR"
fi

# =============================================================================
# 11. Summary
# =============================================================================
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════╗"
echo "║         Setup Complete! 🎉           ║"
echo -e "╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Installed:${NC}"
command -v claude   &>/dev/null && echo "  ✓ Claude Code    $(claude --version 2>/dev/null | head -1)"
command -v codex    &>/dev/null && echo "  ✓ Codex CLI      $(codex --version 2>/dev/null | head -1)"
command -v gemini   &>/dev/null && echo "  ✓ Gemini CLI     $(gemini --version 2>/dev/null | head -1)"
command -v openclaw &>/dev/null && echo "  ✓ OpenClaw       $(openclaw --version 2>/dev/null | head -1)"
command -v gh       &>/dev/null && echo "  ✓ GitHub CLI     $(gh --version | head -1)"
command -v op       &>/dev/null && echo "  ✓ 1Password CLI  $(op --version)"
command -v obsidian-cli &>/dev/null && echo "  ✓ obsidian-cli   $(obsidian-cli --version)"

echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Fill in your workspace files:"
echo "     → $WORKSPACE_DIR/USER.md"
echo "     → $WORKSPACE_DIR/SOUL.md  (replace {{owner_name}} etc.)"
echo "     → $WORKSPACE_DIR/IDENTITY.md"
echo "  2. Open Obsidian → load vault from: $VAULT_DIR"
echo "     Then run: obsidian-cli set-default \"$(basename "$VAULT_DIR")\""
echo "  3. Start OpenClaw: openclaw gateway start"
echo "  4. Open OpenClaw and paste the startup prompt from:"
echo "     $(cd "$(dirname "$0")" && pwd)/STARTUP-PROMPT.md"
echo ""
echo -e "${YELLOW}Need API keys? You'll need:${NC}"
echo "  - Anthropic API key  → https://console.anthropic.com"
echo "  - OpenAI API key     → https://platform.openai.com"
echo "  - Google API key     → https://aistudio.google.com"
echo "  → Set these in OpenClaw config or paste when prompted by each CLI"
echo ""
