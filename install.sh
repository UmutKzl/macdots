#!/usr/bin/env bash

# Exit immediately on error
set -e

# Set dotfile directory
DOTDIR="${HOME}/Dotfiles"

# Exit if we're not in macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "Error: This script is intended to run on macOS only." >&2
  exit 1
fi

# --- Homebrew Setup ---
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! grep -q '/opt/homebrew/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >>~/.zprofile
fi
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# --- Clone Dotfiles ---
if [ ! -d "${DOTDIR}" ]; then
  git clone git@github.com:UmutKzl/macdots.git "${DOTDIR}"
fi

# --- Config file ---
source "${DOTDIR}/CONFIG"

# --- Stow and Brew ---
(
  cd "${DOTDIR}"
  brew bundle
  stow ${CONFIGS}
)

# --- System Defaults ---

# Global Settings
defaults write NSGlobalDomain AppleInterfaceStyle -string "${THEME}"
defaults write NSGlobalDomain AppleShowAllExtensions -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write -g com.apple.swipescrolldirection -bool false
defaults write -g NSSplitViewItemSidebarDefaultsToFloatingAppearance -bool ${SIDEBAR_FLOATING}
defaults write -g NSConvolutionOverride1 -float ${ROUNDED_CORNERS}

if [ "$ANIMATIONS" == "true" ]; then
  defaults delete -g NSAutomaticWindowAnimationsEnabled || true
  defaults delete -g NSBrowserColumnAnimationSpeedMultiplier || true
  defaults delete -g NSDocumentRevisionsWindowTransformAnimation || true
  defaults delete -g QLPanelAnimationDuration || true
  defaults delete -g NSScrollAnimationEnabled || true
  defaults delete -g NSScrollViewRubberbanding || true
  defaults delete -g NSToolbarFullScreenAnimationDuration || true
  defaults delete com.apple.finder DisableAllAnimations || true
  defaults write com.apple.dock autohide-delay -float 0.1
  defaults write com.apple.dock autohide-time-modifier -float 0.1
  defaults delete com.apple.dock expose-animation-duration || true
  defaults delete com.apple.Mail DisableReplyAnimations || true
  defaults delete com.apple.Mail DisableSendAnimations || true
else
  defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
  defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0
  defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false
  defaults write -g QLPanelAnimationDuration -float 0
  defaults write -g NSScrollAnimationEnabled -bool false
  defaults write -g NSScrollViewRubberbanding -bool false
  defaults write -g NSToolbarFullScreenAnimationDuration -float 0
  defaults write com.apple.finder DisableAllAnimations -bool true
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0
  defaults write com.apple.dock expose-animation-duration -float 0.1
  defaults write com.apple.Mail DisableReplyAnimations -bool true
  defaults write com.apple.Mail DisableSendAnimations -bool true
fi

desktoppr "$HOME/Wallpapers/jellyfish.jpg"

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int "${TRACKPAD_PRESSURE}"

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool "${HIDDEN_FILES}"
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.WindowManager StandardHideWidgets -int 1

# Dock
defaults write com.apple.dock autohide -bool ${DOCK_AUTOHIDE}

# Restart affected apps
killall Finder Dock WindowManager 2>/dev/null || true

# Last info
echo "Hello dear user, I hope this script doesn't have any bugs. If it has, please report it using my GitHub repo's issues tab. Good luck!"
