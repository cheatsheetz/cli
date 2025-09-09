# CheetSheetz CLI Makefile

PROGRAM_NAME = cheatsheetz
VERSION = 1.0.0
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man/man1

# Build variables
BUILD_DIR = dist
SRC_DIR = bin
TEST_DIR = tests

.PHONY: all install uninstall test clean release help

all: build

help:
	@echo "CheetSheetz CLI Build System"
	@echo ""
	@echo "Targets:"
	@echo "  build      Build the CLI tool"
	@echo "  install    Install to system (requires sudo)"
	@echo "  uninstall  Remove from system (requires sudo)"
	@echo "  test       Run tests"
	@echo "  lint       Check shell script quality"
	@echo "  clean      Clean build artifacts"
	@echo "  release    Create release packages"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX     Install prefix (default: /usr/local)"
	@echo "  DESTDIR    Staging directory for packaging"

build:
	@echo "Building $(PROGRAM_NAME)..."
	@mkdir -p $(BUILD_DIR)
	@cp $(SRC_DIR)/$(PROGRAM_NAME) $(BUILD_DIR)/
	@sed -i 's/VERSION=".*"/VERSION="$(VERSION)"/' $(BUILD_DIR)/$(PROGRAM_NAME)
	@chmod +x $(BUILD_DIR)/$(PROGRAM_NAME)
	@echo "✓ Built $(BUILD_DIR)/$(PROGRAM_NAME)"

install: build
	@echo "Installing $(PROGRAM_NAME) to $(DESTDIR)$(BINDIR)..."
	@mkdir -p $(DESTDIR)$(BINDIR)
	@cp $(BUILD_DIR)/$(PROGRAM_NAME) $(DESTDIR)$(BINDIR)/
	@chmod +x $(DESTDIR)$(BINDIR)/$(PROGRAM_NAME)
	@echo "✓ Installed $(PROGRAM_NAME) to $(BINDIR)"
	@echo ""
	@echo "Usage: $(PROGRAM_NAME) help"

uninstall:
	@echo "Removing $(PROGRAM_NAME) from $(BINDIR)..."
	@rm -f $(BINDIR)/$(PROGRAM_NAME)
	@echo "✓ Uninstalled $(PROGRAM_NAME)"

test:
	@echo "Running tests..."
	@if [ -f "$(TEST_DIR)/test.sh" ]; then \
		sh "$(TEST_DIR)/test.sh"; \
	else \
		echo "Testing basic functionality..."; \
		$(BUILD_DIR)/$(PROGRAM_NAME) --version; \
		$(BUILD_DIR)/$(PROGRAM_NAME) help > /dev/null; \
		echo "✓ Basic tests passed"; \
	fi

lint:
	@echo "Linting shell script..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(SRC_DIR)/$(PROGRAM_NAME); \
		echo "✓ Shell script linting passed"; \
	else \
		echo "shellcheck not found, skipping linting"; \
	fi

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "✓ Clean complete"

# Release packaging
release: clean build
	@echo "Creating release packages..."
	@mkdir -p $(BUILD_DIR)/packages
	
	# Create tarballs for different platforms
	@for os in linux darwin freebsd openbsd; do \
		for arch in amd64 386 arm64; do \
			case "$$os-$$arch" in \
				freebsd-arm64|openbsd-arm64) continue ;; \
			esac; \
			package_name="$(PROGRAM_NAME)-$$os-$$arch"; \
			echo "Creating $$package_name..."; \
			mkdir -p "$(BUILD_DIR)/$$package_name"; \
			cp $(BUILD_DIR)/$(PROGRAM_NAME) "$(BUILD_DIR)/$$package_name/"; \
			cp README.md "$(BUILD_DIR)/$$package_name/"; \
			echo "#!/bin/sh" > "$(BUILD_DIR)/$$package_name/install.sh"; \
			echo "INSTALL_DIR=\"\$${INSTALL_DIR:-/usr/local/bin}\"" >> "$(BUILD_DIR)/$$package_name/install.sh"; \
			echo "mkdir -p \"\$$INSTALL_DIR\"" >> "$(BUILD_DIR)/$$package_name/install.sh"; \
			echo "cp $(PROGRAM_NAME) \"\$$INSTALL_DIR/\"" >> "$(BUILD_DIR)/$$package_name/install.sh"; \
			echo "chmod +x \"\$$INSTALL_DIR/$(PROGRAM_NAME)\"" >> "$(BUILD_DIR)/$$package_name/install.sh"; \
			echo "echo \"✓ CheetSheetz CLI installed to \$$INSTALL_DIR/$(PROGRAM_NAME)\"" >> "$(BUILD_DIR)/$$package_name/install.sh"; \
			chmod +x "$(BUILD_DIR)/$$package_name/install.sh"; \
			cd $(BUILD_DIR) && tar -czf "packages/$$package_name.tar.gz" "$$package_name" && cd ..; \
		done; \
	done
	
	# Create universal shell script
	@cp $(BUILD_DIR)/$(PROGRAM_NAME) $(BUILD_DIR)/packages/$(PROGRAM_NAME)-universal.sh
	@chmod +x $(BUILD_DIR)/packages/$(PROGRAM_NAME)-universal.sh
	
	# Generate checksums
	@cd $(BUILD_DIR)/packages && sha256sum *.tar.gz *.sh > checksums.txt
	@echo "✓ Release packages created in $(BUILD_DIR)/packages/"
	@echo ""
	@echo "Files created:"
	@ls -la $(BUILD_DIR)/packages/

# Development helpers
dev-test:
	@echo "Testing development version..."
	@$(SRC_DIR)/$(PROGRAM_NAME) version
	@$(SRC_DIR)/$(PROGRAM_NAME) help

dev-install:
	@echo "Installing development version to ~/.local/bin..."
	@mkdir -p ~/.local/bin
	@cp $(SRC_DIR)/$(PROGRAM_NAME) ~/.local/bin/
	@chmod +x ~/.local/bin/$(PROGRAM_NAME)
	@echo "✓ Development version installed"
	@echo "Make sure ~/.local/bin is in your PATH"