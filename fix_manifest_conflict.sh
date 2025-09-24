#!/bin/bash
echo "=== Perbaiki konflik di AndroidManifest.xml ==="

MANIFEST="app/src/main/AndroidManifest.xml"

if [ ! -f "$MANIFEST" ]; then
  echo "❌ File $MANIFEST tidak ditemukan!"
  exit 1
fi

# Backup dulu
cp "$MANIFEST" "${MANIFEST}.bak"
echo "📦 Backup disimpan di ${MANIFEST}.bak"

# Hapus marker konflik
sed -i '/^<<<<<<< HEAD$/d' "$MANIFEST"
sed -i '/^=======$/d' "$MANIFEST"
sed -i '/^>>>>>>> .*$/d' "$MANIFEST"

echo "✅ Marker konflik dihapus. Silakan cek ulang baris pertama file:"
head -n 5 "$MANIFEST"
