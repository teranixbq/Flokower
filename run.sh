#!/bin/bash
# ═══════════════════════════════════════════════════════
# FLOKOWER - Run Script (with .env)
# ═══════════════════════════════════════════════════════
#
# Script ini otomatis load variabel dari .env dan
# menjalankannya sebagai --dart-define saat build.
#
# Usage:
#   ./run.sh              → Run di device default
#   ./run.sh chrome       → Run di Chrome (web)
#   ./run.sh android      → Run di Android device
#

set -e

FLUTTER=/home/nodenix/FlutterDev/bin/flutter
ENV_FILE=".env"

# Check .env exists
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ File .env tidak ditemukan!"
  echo ""
  echo "Buat dulu dengan:"
  echo "  cp .env.example .env"
  echo "  # lalu edit .env dengan nilai asli kamu"
  exit 1
fi

echo "🌸 Flokower - Loading environment..."

# Parse .env into --dart-define flags
DART_DEFINES=""
while IFS='=' read -r key value; do
  # Skip comments and empty lines
  [[ "$key" =~ ^#.*$ ]] && continue
  [[ -z "$key" ]] && continue
  # Remove leading/trailing whitespace
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)
  [[ -z "$value" ]] && continue
  DART_DEFINES="$DART_DEFINES --dart-define=$key=$value"
done < "$ENV_FILE"

echo "✅ Environment loaded"
echo ""

# Determine target device
TARGET="${1:-}"

case "$TARGET" in
  chrome|web)
    echo "🌐 Running on Chrome..."
    $FLUTTER run -d chrome $DART_DEFINES
    ;;
  android|device)
    echo "📱 Running on Android device..."
    $FLUTTER run -d $(adb devices | grep device | head -1 | awk '{print $1}') $DART_DEFINES
    ;;
  *)
    echo "📱 Running on default device..."
    $FLUTTER run $DART_DEFINES
    ;;
esac
