# ============================================================================
# SURVIVAL OPTIMIZER — Makefile
# ============================================================================

.DEFAULT_GOAL := help
SHELL         := /bin/bash
APP_DIR       := app
APP_ID        := com.survival.app
FVM           := fvm flutter

# ============================================================================
# HELP
# ============================================================================

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' \
		| sort

# ============================================================================
# SETUP
# ============================================================================

.PHONY: install
install: ## Install all tools (fvm, melos, cocoapods)
	@echo "→ Installing FVM..."
	brew tap leoafarias/fvm && brew install fvm
	@echo "→ Installing Flutter stable..."
	fvm install stable && fvm global stable
	@echo "→ Installing Melos..."
	dart pub global activate melos
	@echo "→ Installing CocoaPods..."
	gem install cocoapods
	@echo "✓ All tools installed"

.PHONY: setup
setup: ## Bootstrap monorepo (install all dependencies)
	melos bootstrap
	@echo "✓ Workspace bootstrapped"

.PHONY: doctor
doctor: ## Run Flutter doctor
	$(FVM) doctor

# ============================================================================
# DEVELOPMENT
# ============================================================================

.PHONY: run
run: ## Run app on connected device/simulator
	cd $(APP_DIR) && $(FVM) run

.PHONY: run-fresh
run-fresh: db-reset ## Uninstall app (clear DB) then run
	cd $(APP_DIR) && $(FVM) run

.PHONY: run-ios
run-ios: ## Run app on iOS simulator
	cd $(APP_DIR) && $(FVM) run -d iPhone

.PHONY: run-android
run-android: ## Run app on Android emulator
	cd $(APP_DIR) && $(FVM) run -d android

.PHONY: run-macos
run-macos: ## Run app on macOS
	cd $(APP_DIR) && $(FVM) run -d macos

.PHONY: run-chrome
run-chrome: ## Run app in Chrome
	cd $(APP_DIR) && $(FVM) run -d chrome

# ============================================================================
# CODE GENERATION
# ============================================================================

.PHONY: gen
gen: ## Run code generation (Drift, Riverpod)
	melos run gen

.PHONY: gen-l10n
gen-l10n: ## Generate localizations from ARB files
	cd packages/design_system && $(FVM) gen-l10n
	@echo "✓ Localizations generated"

.PHONY: gen-all
gen-all: gen gen-l10n ## Run all code generation

# ============================================================================
# QUALITY
# ============================================================================

.PHONY: analyze
analyze: ## Analyze all packages
	@echo "→ Analyzing domain..."
	@cd packages/domain && dart analyze
	@echo "→ Analyzing data..."
	@cd packages/data && $(FVM) analyze
	@echo "→ Analyzing application..."
	@cd packages/application && $(FVM) analyze
	@echo "→ Analyzing design_system..."
	@cd packages/design_system && $(FVM) analyze
	@echo "→ Analyzing presentation..."
	@cd packages/presentation && $(FVM) analyze
	@echo "→ Analyzing app..."
	@cd $(APP_DIR) && $(FVM) analyze
	@echo "✓ All packages analyzed"

.PHONY: format
format: ## Format all Dart files
	@cd packages/domain        && dart format lib test
	@cd packages/data          && dart format lib
	@cd packages/application   && dart format lib
	@cd packages/design_system && dart format lib
	@cd packages/presentation  && dart format lib
	@cd $(APP_DIR)             && dart format lib
	@echo "✓ All files formatted"

.PHONY: lint
lint: format analyze ## Format + analyze all packages

# ============================================================================
# TESTING
# ============================================================================

.PHONY: test
test: ## Run all tests
	@echo "→ Running domain tests..."
	@cd packages/domain && dart test
	@echo "✓ All tests passed"

.PHONY: test-verbose
test-verbose: ## Run all tests with verbose output
	@cd packages/domain && dart test --reporter=expanded

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@cd packages/domain && dart test --coverage=coverage
	@echo "✓ Coverage report generated in packages/domain/coverage"

# ============================================================================
# BUILD
# ============================================================================

.PHONY: build-ios
build-ios: ## Build iOS app (release)
	cd $(APP_DIR) && $(FVM) build ios --release
	@echo "✓ iOS build complete"

.PHONY: build-android
build-android: ## Build Android APK (release)
	cd $(APP_DIR) && $(FVM) build apk --release
	@echo "✓ Android APK build complete"

.PHONY: build-android-aab
build-android-aab: ## Build Android App Bundle (release)
	cd $(APP_DIR) && $(FVM) build appbundle --release
	@echo "✓ Android AAB build complete"

.PHONY: build-macos
build-macos: ## Build macOS app (release)
	cd $(APP_DIR) && $(FVM) build macos --release
	@echo "✓ macOS build complete"

# ============================================================================
# CLEAN
# ============================================================================

.PHONY: clean
clean: ## Clean all build artifacts
	@cd packages/domain        && dart run build_runner clean 2>/dev/null || true
	@cd packages/data          && $(FVM) clean
	@cd packages/application   && $(FVM) clean
	@cd packages/design_system && $(FVM) clean
	@cd packages/presentation  && $(FVM) clean
	@cd $(APP_DIR)             && $(FVM) clean
	@echo "✓ All packages cleaned"

.PHONY: clean-gen
clean-gen: ## Delete all generated files (*.g.dart, *.freezed.dart)
	@find . -name "*.g.dart" -not -path "*/packages/design_system/lib/generated/*" -delete
	@find . -name "*.freezed.dart" -delete
	@echo "✓ Generated files deleted"

.PHONY: reset
reset: clean clean-gen setup gen-all ## Full reset — clean + regenerate everything
	@echo "✓ Full reset complete"

# ============================================================================
# DATABASE
# ============================================================================

.PHONY: db-reset
db-reset: ## Uninstall iOS app to reset SQLite database
	xcrun simctl uninstall booted $(APP_ID)
	@echo "✓ App uninstalled — database cleared"

.PHONY: db-reset-android
db-reset-android: ## Reset database on Android emulator
	adb uninstall $(APP_ID)
	@echo "✓ App uninstalled on Android — database cleared"

# ============================================================================
# SIMULATOR
# ============================================================================

.PHONY: sim-open
sim-open: ## Open iOS Simulator
	open -a Simulator

.PHONY: sim-launch
sim-launch: ## Launch iOS Simulator
	fvm flutter emulators --launch apple_ios_simulator

.PHONY: devices
devices: ## List connected devices
	$(FVM) devices

.PHONY: emulators
emulators: ## List available emulators
	$(FVM) emulators

# ============================================================================
# LOCALIZATION
# ============================================================================

.PHONY: l10n
l10n: gen-l10n ## Alias for gen-l10n

.PHONY: l10n-check
l10n-check: ## Check all ARB files are valid
	@for f in packages/design_system/lib/l10n/*.arb; do \
		python3 -c "import json; json.load(open('$$f'))" && echo "✓ $$f" || echo "✗ $$f INVALID"; \
	done

# ============================================================================
# GIT
# ============================================================================

.PHONY: precommit
precommit: lint test ## Run lint + tests before committing
	@echo "✓ Pre-commit checks passed"

.PHONY: version
version: ## Show Flutter + Dart + Melos versions
	@$(FVM) --version
	@dart --version
	@melos --version
