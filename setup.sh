#!/bin/bash
set -e

echo "→ Installing Ollama..."
brew install ollama

echo "→ Configuring Ollama as a persistent network service..."
sudo mkdir -p /etc/launchd.conf
cat <<EOF | sudo tee /Library/LaunchDaemons/com.ollama.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/ollama</string>
        <string>serve</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>0.0.0.0</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

sudo launchctl load /Library/LaunchDaemons/com.ollama.plist

echo "→ Pulling models (this will take a while)..."
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:32b
ollama pull llama3.3:70b

echo "→ Done. Ollama is running and will start on boot."