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

### Option 1: Homebrew (Recommended)

```bash
# Tap the repository
brew tap onix-ai/tap

# Install the plugin (automatically sets up plugin directory)
brew install doppler-1password-plugin

# Initialize the plugin with 1Password
op plugin init doppler
```

Add to your shell config (`~/.zshrc` or `~/.bashrc`):
```bash
source ~/.config/op/plugins.sh
```

This provides:
- ✅ Easy installation and updates
- ✅ Automatic architecture detection
- ✅ Automatic setup (no manual steps required)
- ✅ Clean uninstallation with `brew uninstall` (removes plugin automatically)

### Option 2: Install Script

Quick installation via curl:

```bash
curl -sSL https://raw.githubusercontent.com/Onix-AI/doppler-1password-plugin/main/scripts/install.sh | bash
```

This will:
- Auto-detect your OS and architecture
- Download the correct binary
- Install to `~/.config/op/plugins/local/`
- Configure shell integration
- Run `op plugin init doppler`

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

## Development

### Building Locally

```bash
# Clone the repository with submodules
git clone --recursive https://github.com/Onix-AI/doppler-1password-plugin.git
cd doppler-1password-plugin

# Quick build (no validation)
make build

# Build with validation (recommended for testing)
make build-with-validation

# Full build with validation and tests (for releases)
make build-for-release

# Clean build artifacts
make clean

# Test the plugin
op plugin init doppler
doppler me
```

### Build Script

The build process is managed by `scripts/build.sh` which:
1. Updates the shell-plugins submodule to latest
2. Copies our doppler plugin into the submodule
3. Optionally validates the plugin schema (`--validate`)
4. Optionally runs tests (`--test`)
5. Generates the plugin registry (includes all official plugins)
6. Builds with isolated cache to avoid stale builds

You can also run the script directly:
```bash
# Quick build
./scripts/build.sh

# With validation
./scripts/build.sh --validate

# With validation and tests
./scripts/build.sh --validate --test

# Build to custom location
./scripts/build.sh --output ./dist/doppler
```

### Running Tests

```bash
# Run tests via Makefile
make test

# Or manually
cd vendor/shell-plugins/plugins/doppler && go test -v .
```

### Validating the Plugin

Validate plugin schema and structure:
```bash
# Via Makefile
cd vendor/shell-plugins && make doppler/validate

# Or during build
make build-with-validation
```

### Architecture

This plugin uses the official [1Password shell-plugins](https://github.com/1Password/shell-plugins) repository as a submodule. This ensures:
- ✅ Compatibility with the 1Password CLI
- ✅ Includes all official plugin infrastructure
- ✅ Always uses the latest SDK
- ✅ Binaries work with `op plugin init`

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
