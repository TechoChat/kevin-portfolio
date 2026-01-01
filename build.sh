#!/bin/bash

echo "----------------------------------------------------------------"
echo "  🚀  Starting Flutter Web Build for Vercel "
echo "----------------------------------------------------------------"

# 1. Download Flutter SDK
echo "📦  Cloning Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. Add Flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Verify installation
echo "✅  Flutter installed:"
flutter --version

# 4. Enable web and get dependencies
echo "📦  Getting dependencies..."
flutter config --enable-web
flutter pub get

# 5. Build the web project
echo "🔨  Building web application..."

# WE USE DART-DEFINE HERE INSTEAD OF .ENV
# This takes the variable from Vercel settings ($OPEN_WEATHER_API_KEY) 
# and injects it into the Dart code as 'OPEN_WEATHER_API_KEY'
flutter build web --release --dart-define=OPEN_WEATHER_API_KEY="$OPEN_WEATHER_API_KEY"

echo "----------------------------------------------------------------"
echo "  🎉  Build Complete! Output directory: build/web "
echo "----------------------------------------------------------------"