# Variables
BINARY_NAME = gstash
BUILD_DIR = .build

# Default target
all: build

# Build the project in debug mode
build:
	swift build

# Build the project in release mode
release:
	swift build -c release

# Run the debug build
debug: build
	$(BUILD_DIR)/debug/$(BINARY_NAME)

# Run the release build
run: release
	$(BUILD_DIR)/release/$(BINARY_NAME)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
	rm -rf *.xcodeproj

# Install the binary
install: release
	install $(BUILD_DIR)/release/$(BINARY_NAME) /usr/local/bin/

# Test the project
test:
	swift test

.PHONY: all build release debug run clean install test
