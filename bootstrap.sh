#!/usr/bin/env bash
# =============================================================================
# Suru-PA Bootstrap
# One-liner installer — run this on a fresh Mac with nothing pre-installed.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/sudobot99/suru-pa/main/bootstrap.sh | bash
#
# What it does:
#   1. Installs Homebrew + Node.js (prerequisites)
#   2. Installs OpenClaw
#   3. Clones the suru-pa repo
#   4. Runs the full setup.sh from the cloned repo
#   5. Starts OpenClaw gateway
# =============================================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
step() { echo -e "\n${BLUE}${BOLD}▶ $1${NC}"; }
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }
info() { echo -e "  $1"; }

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════╗"
echo "║       Suru-PA Bootstrap Installer        ║"
echo "║  Personal Assistant — OpenClaw Template  ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# OS check
[[ "$(uname -s)" != "Darwin" ]] && fail "macOS only. Linux support coming later."

ARCH="$(uname -m)"
REPO_URL="https://github.com/sudobot99/suru-pa.git"
INSTALL_DIR="$HOME/suru-pa"

# =============================================================================
# Step 1: Homebrew
# =============================================================================
step "Homebrew"
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ "$ARCH" == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
fi

# =============================================================================
# Step 2: Node.js
# =============================================================================
step "Node.js"
if ! command -v node &>/dev/null || [[ "$(node --version | cut -d. -f1 | tr -d v)" -lt 20 ]]; then
  info "Installing node@22..."
  brew install node@22
  brew link --overwrite node@22 2>/dev/null || true
  ok "Node.js installed"
else
  ok "Node.js already installed ($(node --version))"
fi

# =============================================================================
# Step 3: Git (usually pre-installed on macOS, but just in case)
# =============================================================================
step "Git"
if ! command -v git &>/dev/null; then
  info "Installing git..."
  brew install git
  ok "Git installed"
else
  ok "Git already installed ($(git --version))"
fi

# =============================================================================
# Step 4: OpenClaw
# =============================================================================
step "OpenClaw"
if ! command -v openclaw &>/dev/null; then
  info "Installing OpenClaw..."
  npm install -g openclaw
  ok "OpenClaw installed"
else
  ok "OpenClaw already installed"
fi

# =============================================================================
# Step 5: Clone suru-pa repo
# =============================================================================
step "Cloning suru-pa template"
if [[ -d "$INSTALL_DIR" ]]; then
  warn "suru-pa already cloned at $INSTALL_DIR — pulling latest..."
  cd "$INSTALL_DIR" && git pull && cd - &>/dev/null
else
  info "Cloning to $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR"
  ok "Repo cloned"
fi

# =============================================================================
# Step 6: Run full setup
# =============================================================================
step "Running full setup"
chmod +x "$INSTALL_DIR/setup.sh"
bash "$INSTALL_DIR/setup.sh"

# =============================================================================
# Step 7: Start OpenClaw gateway
# =============================================================================
step "Starting OpenClaw gateway"
if openclaw gateway status &>/dev/null; then
  ok "OpenClaw gateway already running"
else
  info "Starting OpenClaw gateway..."
  openclaw gateway start
  ok "Gateway started"
fi

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════╗"
echo "║     Bootstrap Complete! 🚀           ║"
echo -e "╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Your one-liner install is done. Next:${NC}"
echo ""
echo "  1. Fill in your details:"
echo "     nano ~/.openclaw/workspace/USER.md"
echo "     nano ~/.openclaw/workspace/SOUL.md"
echo ""
echo "  2. Open Obsidian → load vault from:"
echo "     $HOME/Documents/SecondBrain"
echo "     Then run: obsidian-cli set-default \"SecondBrain\""
echo ""
echo "  3. Open OpenClaw and paste this startup prompt:"
echo "     ────────────────────────────────────────────"
cat "$INSTALL_DIR/STARTUP-PROMPT.md" | grep -A5 "## The Prompt" | grep '```' -A5 | grep -v '```' | sed 's/^/     /'
echo "     ────────────────────────────────────────────"
echo ""
