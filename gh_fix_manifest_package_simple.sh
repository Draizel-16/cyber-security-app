#!/bin/bash
set -e

MANIFEST="app/src/main/AndroidManifest.xml"
BACKUP="$MANIFEST.bak_$(date +%Y%m%d%H%M%S)"

echo "=== Perbaiki AndroidManifest.xml (hapus duplikat package) ==="

# 1. Backup dulu
cp "$MANIFEST" "$BACKUP"
echo "📦 Backup dibuat: $BACKUP"

# 2. Hapus semua duplikat package, sisakan yang pertama
awk '
/package=/ {
    if (found == 1) next
    found=1
}
{ print }
' "$BACKUP" > "$MANIFEST"

# 3. Validasi jumlah package
COUNT=$(grep -c "package=" "$MANIFEST" || true)

if [ "$COUNT" -eq 1 ]; then
    echo "✅ Duplikat package sudah dihapus, hanya 1 package tersisa."
else
    echo "⚠️ Masih ada lebih dari 1 package, silakan cek manual."
fi

# 4. Commit & push perubahan
echo "🚀 Commit & push perubahan..."
git add "$MANIFEST"
git commit -m "Fix: remove duplicate package in AndroidManifest.xml" || echo "⚠️ Tidak ada perubahan untuk di-commit."
git push origin main
