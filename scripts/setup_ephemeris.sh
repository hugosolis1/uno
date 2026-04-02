#!/bin/bash
set -e

EPHE_DIR="Resources/ephe"
mkdir -p "$EPHE_DIR"

echo "📥 Downloading Swiss Ephemeris data files..."

BASE_URL="https://www.astro.com/ftp/swisseph/ephe"

FILES=(
    "semo_18.se1"
    "sepl_18.se1" 
    "seas_18.se1"
    "sefstars.txt"
)

for file in "${FILES[@]}"; do
    if [ -f "$EPHE_DIR/$file" ]; then
        echo "✅ $file already exists, skipping"
    else
        echo "⬇️  Downloading $file..."
        curl -fSL "$BASE_URL/$file" -o "$EPHE_DIR/$file" || echo "⚠️  Failed to download $file"
    fi
done

echo ""
echo "✨ Ephemeris data setup complete!"
ls -la "$EPHE_DIR/"
