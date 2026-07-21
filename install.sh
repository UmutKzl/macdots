#!/usr/bin/env bash

# Exit immediately on error
set -e

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
if [ ! -d "$HOME/Dotfiles" ]; then
  git clone git@github.com:UmutKzl/macdots.git "$HOME/Dotfiles"
fi

# --- Stow and Brew ---
(
  cd "$HOME/Dotfiles"
  brew bundle
  stow shell nvim ghostty Wallpapers
)

# --- System Defaults ---

# Global Settings
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write -g com.apple.swipescrolldirection -bool false
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0
defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false
defaults write -g QLPanelAnimationDuration -float 0
defaults write -g NSScrollAnimationEnabled -bool false
defaults write -g NSScrollViewRubberbanding -bool false
defaults write -g NSToolbarFullScreenAnimationDuration -float 0
defaults write -g NSSplitViewItemSidebarDefaultsToFloatingAppearance -bool false
defaults write -g NSConvolutionOverride1 -float 10
desktoppr "$HOME/Wallpapers/jellyfish.jpg"

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.WindowManager StandardHideWidgets -int 1

# Mail
defaults write com.apple.Mail DisableReplyAnimations -bool true
defaults write com.apple.Mail DisableSendAnimations -bool true

# Brave Browser
defaults write com.brave.Browser BraveAIChatEnabled -bool false
defaults write com.brave.Browser BraveAIEnabled -bool false
defaults write com.brave.Browser BraveChatEnabled -bool false
defaults write com.brave.Browser BraveLeoEnabled -bool false
defaults write com.brave.Browser BraveRewardsDisabled -bool true
defaults write com.brave.Browser BraveVPNDisabled -bool true
defaults write com.brave.Browser BraveWalletDisabled -bool true
defaults write com.brave.Browser CryptoWalletEnabled -bool false

# Dock
dock_item() {
  printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' "$1"
}

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock springboard-hide-duration -float 0
defaults write com.apple.dock springboard-page-duration -float 0
defaults write com.apple.dock springboard-show-duration -float 0

defaults write com.apple.dock persistent-apps -array \
  "$(dock_item '/Applications/Brave Browser.app')" \
  "$(dock_item '/Applications/Ghostty.app')"

# Restart affected apps
killall Finder Dock WindowManager 2>/dev/null || true
