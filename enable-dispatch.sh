#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🚀 Enable workflow_dispatch trigger"

YAML_FILE=".github/workflows/android.yml"

if [ ! -f "$YAML_FILE" ]; then
  echo "❌ File $YAML_FILE tidak ditemukan!"
  exit 1
fi

# Tambahkan workflow_dispatch kalau belum ada
if ! grep -q "workflow_dispatch:" "$YAML_FILE"; then
  echo "🔧 Menambahkan workflow_dispatch ke $YAML_FILE"
  tmpfile=$(mktemp)
  awk '
    /^on:/ {
      print $0
      print "  workflow_dispatch:"
      next
    }
    { print $0 }
  ' "$YAML_FILE" > "$tmpfile"
  mv "$tmpfile" "$YAML_FILE"
else
  echo "✅ workflow_dispatch sudah ada"
fi

# Commit & push
git add "$YAML_FILE"
git commit -m "ci: enable workflow_dispatch"
git push origin main

echo "=== ✅ workflow_dispatch sudah aktif ==="
