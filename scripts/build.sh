#!/bin/bash
set -e

# Build script for doppler 1Password plugin
# This script:
# 1. Updates the shell-plugins submodule
# 2. Copies our doppler plugin into it
# 3. Validates the plugin (optional)
# 4. Runs tests (optional)
# 5. Generates the registry
# 6. Builds the binary

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SUBMODULE_DIR="$REPO_ROOT/vendor/shell-plugins"
PLUGIN_NAME="doppler"

# Parse arguments
VALIDATE=false
TEST=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --validate)
      VALIDATE=true
      shift
      ;;
    --test)
      TEST=true
      shift
      ;;
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🔄 Updating shell-plugins submodule..."
cd "$REPO_ROOT"
git submodule update --remote vendor/shell-plugins

echo "📦 Copying doppler plugin into submodule..."
rm -rf "$SUBMODULE_DIR/plugins/doppler"
cp -r "$REPO_ROOT/plugins/doppler" "$SUBMODULE_DIR/plugins/doppler"

cd "$SUBMODULE_DIR"

# Set up isolated build cache for all Go commands
export GOMODCACHE="$SUBMODULE_DIR/.go-cache/mod"
export GOCACHE="$SUBMODULE_DIR/.go-cache/build"

# Clear cache to ensure clean build
if [ -d "$SUBMODULE_DIR/.go-cache" ]; then
  echo "🧹 Cleaning build cache..."
  chmod -R +w "$SUBMODULE_DIR/.go-cache" 2>/dev/null || true
  rm -rf "$SUBMODULE_DIR/.go-cache"
fi
mkdir -p "$SUBMODULE_DIR/.go-cache/mod"
mkdir -p "$SUBMODULE_DIR/.go-cache/build"

if [ "$VALIDATE" = true ]; then
  echo "✅ Validating plugin..."
  make doppler/validate || {
    echo "❌ Validation failed"
    exit 1
  }
fi

if [ "$TEST" = true ]; then
  echo "🧪 Running tests..."
  cd "$SUBMODULE_DIR/plugins/doppler"
  go test -v . || {
    echo "❌ Tests failed"
    exit 1
  }
  cd "$SUBMODULE_DIR"
fi

echo "📝 Generating plugin registry..."
make registry

echo "🔨 Building plugin..."
if [ -n "$OUTPUT" ]; then
  go build -o "$OUTPUT" -ldflags="-X 'main.PluginName=$PLUGIN_NAME'" ./cmd/contrib/build/
  echo "✅ Built: $OUTPUT"
else
  make doppler/build
  echo "✅ Built: $(go run cmd/contrib/scripts/config_dir_getter.go)/plugins/local/$PLUGIN_NAME"
fi

echo "🎉 Build complete!"
