.PHONY: all setup generate build clean

all: setup generate build

setup:
	@echo "🔧 Setting up project..."
	git submodule update --init --recursive
	chmod +x scripts/setup_ephemeris.sh
	./scripts/setup_ephemeris.sh

generate:
	@echo "📐 Generating Xcode project..."
	xcodegen generate

build: generate
	@echo "🔨 Building project..."
	xcodebuild build \
		-project PlanetaryEphemeris.xcodeproj \
		-scheme PlanetaryEphemeris \
		-sdk iphoneos \
		-configuration Release \
		-destination 'generic/platform=iOS' \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO

ipa: build
	@echo "📦 Creating unsigned IPA..."
	mkdir -p build/ipa/Payload
	cp -r build/Build/Products/Release-iphoneos/PlanetaryEphemeris.app build/ipa/Payload/
	cd build/ipa && zip -r PlanetaryEphemeris_unsigned.ipa Payload/
	mv build/ipa/PlanetaryEphemeris_unsigned.ipa .
	@echo "✅ IPA created: PlanetaryEphemeris_unsigned.ipa"

clean:
	@echo "🧹 Cleaning..."
	rm -rf build/ PlanetaryEphemeris.xcodeproj/ PlanetaryEphemeris_unsigned.ipa
	xcodebuild clean -project PlanetaryEphemeris.xcodeproj 2>/dev/null || true

open: generate
	@echo "📱 Opening project..."
	open PlanetaryEphemeris.xcodeproj
