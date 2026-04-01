# Local Coding Assistant

A self-hosted AI coding assistant running on Apple Silicon, accessible across your local network via VS Code and browser.

---

## Blueprint

**Hardware:** MacBook M5 Pro (48GB) — always-on inference server

### Model Layer
| Role | Model | Size |
|------|-------|------|
| Autocomplete | `qwen2.5-coder:7b` | 7B |
| Coding Assistant | `qwen2.5-coder:32b` | 32B |
| Architecture/Planning | `llama3.3:70b-instruct-q3_K_M` | 70B |

**Note:** The Planning model's weight is currently too large for a 48GB M5 Pro, I'm in the process of finding a good Quantization/Weight-Pruning/Context-reduction tradeoff strategy.

### Software Layer
| Tool | Where | Purpose |
|------|-------|---------|
| Ollama | macOS native | Model server, network API |
| Continue.dev | VS Code (all devices) | IDE integration, model switching |
| Docker Desktop | macOS | Surrounding infrastructure |
| Open WebUI | Docker container | Browser accessible chat |

### Storage
```
~/.ollama/models/
├── qwen2.5-coder:7b              (~5GB)
├── qwen2.5-coder:32b             (~20GB)
└── llama3.3:70b-instruct-q3_K_M  (~34GB)

Total: ~59GB of 1TB
```

### Workflow
```
Typing code        → qwen2.5-coder:7b              (automatic)
Writing/fixing     → qwen2.5-coder:32b             (sidebar)
Designing/planning → llama3.3:70b-instruct-q3_K_M  (sidebar)
```

### Repo Structure
```
coding-assistant/
├── README.md
├── Makefile
├── setup.sh
├── uninstall.sh
└── docker-compose.yml
```

---

## Quickstart

### 1. Mac Prerequisites

Install Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

install Docker Desktop for Mac:
```bash
brew install --cask docker
```
or:
https://docs.docker.com/desktop/setup/install/mac-install/

Disable sleep (optional):
```bash
sudo systemsetup -setcomputersleep Never
```

### 2. Provision Everything

From the repo root, run:
```bash
make setup
```

This will install Ollama, configure it as a persistent network service, pull all three models, and start Open WebUI in Docker. **This will take a while depending on your connection.**

---
#### If Make isn't available, run the provisioning scripts manually:

Install Ollama and pull model weights:
```bash
chmod +x setup.sh && ./setup.sh
```

Install Docker Desktop:
```bash
brew install --cask docker
```

Start Open WebUI:
```bash
docker compose up -d
```

Open WebUI will be available at `http://YOUR_MAC_IP:3000` from any device on your network.


### 3. Continue.dev (VS Code)

- Install the **Continue** extension from the VS Code marketplace
- Open `~/.continue/config.yaml`
- Replace its contents with the config below, substituting your Mac's IP

```yaml
name: Local Config
version: 1.0.0
schema: v1
models:
  - name: Coding Assistant (32B)
    provider: ollama
    model: qwen2.5-coder:32b
    apiBase: http://YOUR_MAC_IP:11434
    roles:
      - chat
      - edit
      - apply

  - name: Architecture (70B)
    provider: ollama
    model: llama3.3:70b-instruct-q3_K_M
    apiBase: http://YOUR_MAC_IP:11434
    roles:
      - chat
      - edit
      - apply

  - name: Autocomplete (7B)
    provider: ollama
    model: qwen2.5-coder:7b
    apiBase: http://YOUR_MAC_IP:11434
    roles:
      - autocomplete

  - name: Nomic Embed
    provider: ollama
    model: nomic-embed-text:latest
    roles:
      - embed
```

> `config.ts` is also present in the Continue directory — leave it at its default passthrough state and do not edit it. `config.yaml` is the active configuration file.

Find your Mac's IP:
```bash
ipconfig getifaddr en0
```

---

## Usage

### Make Commands
| Command | Action |
|---------|--------|
| `make setup` | First time provisioning — installs Ollama, pulls models, starts Docker |
| `make start` | Start Ollama service and Docker containers |
| `make stop` | Stop Ollama service and Docker containers |
| `make restart` | Bounce everything |
| `make logs` | Tail Ollama and Docker logs |

### VS Code
| Action | Shortcut |
|--------|----------|
| Open chat | `Cmd + L` |
| Inline edit (highlight code first) | `Cmd + I` |
| Accept autocomplete | `Tab` |
| Dismiss autocomplete | `Esc` |

Switch between models using the dropdown at the top of the Continue sidebar.

### Browser
Navigate to `http://YOUR_MAC_IP:3000` from any device on your network.

---

## Maintenance

### Remove a single model
```bash
ollama rm llama3.3:70b-instruct-q3_K_M
```

### List installed models
```bash
ollama list
```

### Full uninstall
To remove Ollama, all models, and the service entirely:
```bash
chmod +x uninstall.sh && ./uninstall.sh
```

This will stop the service, uninstall Ollama via Homebrew, and delete all model data and logs.

---

## Verification Checklist
```bash
# Ollama is reachable on the network
curl http://YOUR_MAC_IP:11434

# Models are loaded
ollama list

# Open WebUI is running
docker compose ps
```

Logs are written to `~/ollama.log` and `~/ollama.err` for debugging.

To restart the Ollama service manually:
```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.ollama.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.ollama.plist
```