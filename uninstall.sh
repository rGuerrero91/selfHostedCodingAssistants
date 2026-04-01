#!/bin/bash

echo "→ Stopping and removing Ollama service..."
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.ollama.plist 2>/dev/null
rm -f ~/Library/LaunchAgents/com.ollama.plist

echo "→ Removing Ollama..."
brew uninstall ollama

echo "→ Removing models and Ollama data..."
rm -rf ~/.ollama

echo "→ Removing logs..."
rm -f ~/ollama.log ~/ollama.err

echo "→ Done. Ollama and all models have been removed."