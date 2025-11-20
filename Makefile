.PHONY: build build-with-validation build-for-release test clean

# Quick local build (no validation)
build:
	@./scripts/build.sh

# Build with validation (recommended for testing)
build-with-validation:
	@./scripts/build.sh --validate

# Full build with validation and tests (for CI/releases)
build-for-release:
	@./scripts/build.sh --validate --test

# Run tests only
test:
	@cd vendor/shell-plugins/plugins/doppler && go test -v .

# Clean build artifacts
clean:
	@rm -rf vendor/shell-plugins/plugins/doppler
	@if [ -d vendor/shell-plugins/.go-cache ]; then \
		chmod -R +w vendor/shell-plugins/.go-cache 2>/dev/null || true; \
		rm -rf vendor/shell-plugins/.go-cache; \
	fi
	@cd vendor/shell-plugins && git checkout -- plugins/ 2>/dev/null || true

# Update submodule to latest
update-submodule:
	@git submodule update --remote vendor/shell-plugins
	@echo "✅ Submodule updated to latest"

.DEFAULT_GOAL := build
