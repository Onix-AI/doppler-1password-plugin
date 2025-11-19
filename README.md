# Doppler 1Password Plugin

1Password shell plugin for Doppler CLI - authenticate with biometrics

## Overview

This plugin enables secure authentication for the [Doppler CLI](https://docs.doppler.com/docs/cli) using [1Password](https://1password.com). Store your Doppler Personal Tokens securely in your 1Password vault and authenticate CLI commands with biometric authentication (Touch ID/Face ID).

**Benefits:**
- 🔐 No more plaintext tokens in environment variables
- 👆 Biometric authentication for every CLI command
- 🔄 Easy credential rotation and management
- 👥 Consistent security across your team

## Prerequisites

- [1Password CLI](https://developer.1password.com/docs/cli/get-started/) (v2.0+)
- [Doppler CLI](https://docs.doppler.com/docs/install-cli)
- 1Password account with biometric unlock enabled

## Installation

### Option 1: Install Script (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/Onix-AI/doppler-1password-plugin/main/scripts/install.sh | bash
```

This will:
- Auto-detect your OS and architecture
- Download the correct binary
- Install to `~/.config/op/plugins/local/`
- Configure shell integration
- Run `op plugin init doppler`

### Option 2: Homebrew Tap

For macOS and Linux users with Homebrew:

```bash
brew tap Onix-AI/tap
brew install doppler-1password-plugin
```

> **Note:** Homebrew tap setup instructions are in the [Homebrew Tap section](#homebrew-tap-setup) below.

### Option 3: Manual Installation

1. Download the latest binary for your platform from [Releases](https://github.com/Onix-AI/doppler-1password-plugin/releases)

2. Install the binary:
   ```bash
   mkdir -p ~/.config/op/plugins/local
   cp doppler-<os>-<arch> ~/.config/op/plugins/local/doppler
   chmod +x ~/.config/op/plugins/local/doppler
   ```

3. Initialize the plugin:
   ```bash
   op plugin init doppler
   ```

4. Source the 1Password plugin configuration (add to your `~/.zshrc` or `~/.bashrc`):
   ```bash
   source ~/.config/op/plugins.sh
   ```

## Usage

### First-Time Setup

1. **Generate a Doppler Personal Token**

   Visit your Doppler dashboard:
   ```
   https://dashboard.doppler.com/workplace/<workplace-id>/tokens/personal
   ```

   Click "Generate" to create a new Personal Token. The format will be: `dp.pt.xxxxx...`

2. **Run a Doppler command**
   ```bash
   doppler me
   ```

3. **Authenticate with 1Password**

   You'll see a prompt to:
   - Paste your Doppler Personal Token
   - Save it to your 1Password vault
   - Configure credential usage scope

4. **Future commands use biometric auth**
   ```bash
   doppler secrets
   # Touch ID/Face ID prompt appears
   # Token is automatically provisioned as DOPPLER_TOKEN
   # Command runs with authentication
   ```

### Credential Scopes

When initializing, you can choose how credentials are used:

- **Per-session**: Prompt for credentials each terminal session
- **Per-directory**: Use specific credentials for each project directory
- **Global**: Use the same credentials everywhere

## How It Works

1. Plugin detects when `doppler` commands need authentication
2. 1Password prompts for biometric authentication
3. Personal Token is retrieved from your vault
4. Token is provisioned as `DOPPLER_TOKEN` environment variable
5. Doppler CLI authenticates and runs your command

## Supported Platforms

- **macOS**: Intel (x64) and Apple Silicon (ARM64)
- **Linux**: x64
- **Windows**: x64 (via Git Bash or WSL)

## Troubleshooting

### Plugin not found after installation

Make sure you've sourced the shell integration:
```bash
source ~/.config/op/plugins.sh
```

Add this to your `~/.zshrc` or `~/.bashrc` to make it permanent.

### "Plugin not from official registry" warning

This is expected for local plugins. The warning can be safely ignored if you built or installed the plugin yourself.

### Doppler command not authenticating

1. Verify 1Password CLI is working:
   ```bash
   op --version
   ```

2. Check plugin is installed:
   ```bash
   op plugin list | grep doppler
   ```

3. Reinitialize the plugin:
   ```bash
   op plugin init doppler
   ```

### Token format issues

Ensure your Personal Token:
- Starts with `dp.pt.`
- Is 47-50 characters total length
- Contains only alphanumeric characters after the prefix

## Homebrew Tap Setup

To set up the Homebrew tap for easy distribution to your team:

1. **Create a new repository**: `github.com/Onix-AI/homebrew-tap`

2. **Create the formula** at `Formula/doppler-1password-plugin.rb`:
   ```ruby
   class DopplerOnepasswordPlugin < Formula
     desc "1Password shell plugin for Doppler CLI"
     homepage "https://github.com/Onix-AI/doppler-1password-plugin"
     version "1.0.0"

     if OS.mac? && Hardware::CPU.arm?
       url "https://github.com/Onix-AI/doppler-1password-plugin/releases/download/v1.0.0/doppler-darwin-arm64"
       sha256 "CHECKSUM_HERE"
     elsif OS.mac?
       url "https://github.com/Onix-AI/doppler-1password-plugin/releases/download/v1.0.0/doppler-darwin-amd64"
       sha256 "CHECKSUM_HERE"
     elsif OS.linux?
       url "https://github.com/Onix-AI/doppler-1password-plugin/releases/download/v1.0.0/doppler-linux-amd64"
       sha256 "CHECKSUM_HERE"
     end

     def install
       bin.install "doppler-#{OS.kernel_name.downcase}-#{Hardware::CPU.arch}" => "doppler-1password"

       # Install to 1Password plugin directory
       (buildpath/"install").write <<~EOS
         #!/bin/bash
         mkdir -p ~/.config/op/plugins/local
         cp #{bin}/doppler-1password ~/.config/op/plugins/local/doppler
         chmod +x ~/.config/op/plugins/local/doppler
         op plugin init doppler
       EOS

       bin.install "install" => "doppler-1password-install"
     end

     def caveats
       <<~EOS
         To complete installation, run:
           doppler-1password-install

         Then add to your shell config (~/.zshrc or ~/.bashrc):
           source ~/.config/op/plugins.sh
       EOS
     end
   end
   ```

3. **Team installation**:
   ```bash
   brew tap Onix-AI/tap
   brew install doppler-1password-plugin
   doppler-1password-install
   ```

## Development

### Building Locally

```bash
# Clone the repository
git clone https://github.com/Onix-AI/doppler-1password-plugin.git
cd doppler-1password-plugin

# Build for your platform
make doppler/build

# Test
op plugin init doppler
doppler me
```

### Running Tests

```bash
go test ./plugins/doppler/ -v
```

### Building for Multiple Platforms

```bash
# macOS Intel
GOOS=darwin GOARCH=amd64 make doppler/build

# macOS Apple Silicon
GOOS=darwin GOARCH=arm64 make doppler/build

# Linux
GOOS=linux GOARCH=amd64 make doppler/build

# Windows
GOOS=windows GOARCH=amd64 make doppler/build
```

## Contributing

This is an internal plugin for Onix AI. For issues or improvements, please open an issue in this repository.

## Security

This plugin:
- Never stores tokens in plaintext
- Uses 1Password's secure storage
- Requires biometric authentication for access
- Only provisions tokens as environment variables for the duration of the command

**Important:** Never commit Personal Tokens to version control.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

Built using the [1Password Shell Plugins SDK](https://github.com/1Password/shell-plugins).

---

Made with ❤️ by the Onix AI team
