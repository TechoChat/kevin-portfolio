#!/bin/bash

echo "----------------------------------------------------------------"
echo "  🚀  Starting Flutter Web Build for Vercel "
echo "----------------------------------------------------------------"

# 1. Download the Flutter SDK
# We use depth 1 to save time and bandwidth
echo "📦  Cloning Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. Add Flutter to the path variable so we can run 'flutter' commands
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Verify installation
echo "✅  Flutter installed:"
flutter --version

# 4. Enable web support (just in case) and get dependencies
echo "📦  Getting dependencies..."
flutter config --enable-web
flutter pub get

# 5. Build the web project
echo "🔨  Building web application..."
# --release reduces file size
# --web-renderer html can be used if you want smaller download size but slightly less fidelity
# Default is 'auto' (CanvasKit for desktop, HTML for mobile), which is usually best.
flutter build web --release

echo "----------------------------------------------------------------"
echo "  🎉  Build Complete! Output directory: build/web "
echo "----------------------------------------------------------------"