#!/bin/bash
echo "=== Auto Fix Manifest + Commit + Rerun Build + Show Errors ==="

MANIFEST="app/src/main/AndroidManifest.xml"

# 1. Cek file manifest
if [ ! -f "$MANIFEST" ]; then
  echo "❌ File $MANIFEST tidak ditemukan!"
  exit 1
fi

# 2. Bersihkan marker konflik
if grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$MANIFEST"; then
  echo "⚠️ Marker konflik ditemukan di $MANIFEST"
  cp "$MANIFEST" "${MANIFEST}.bak"
  echo "📦 Backup dibuat di ${MANIFEST}.bak"

  sed -i '/^<<<<<<< HEAD$/d' "$MANIFEST"
  sed -i '/^=======$/d' "$MANIFEST"
  sed -i '/^>>>>>>> .*$/d' "$MANIFEST"

  echo "✅ Marker konflik sudah dihapus."

  git add "$MANIFEST"
  git commit -m "fix: resolve AndroidManifest.xml conflict markers"
  git push origin main
  echo "🚀 Perubahan sudah di-push ke GitHub."
else
  echo "✅ Tidak ada marker konflik di $MANIFEST"
fi

# 3. Rerun workflow terakhir
echo "🔄 Rerun workflow GitHub Actions terakhir..."
LAST_RUN=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')

if [ -z "$LAST_RUN" ]; then
  echo "⚠️ Tidak ada workflow run ditemukan."
  exit 1
fi

gh run rerun "$LAST_RUN"
echo "✅ Workflow $LAST_RUN direquest untuk rerun."

# 4. Tunggu sampai selesai
echo "⏳ Menunggu build selesai..."
while true; do
  STATUS=$(gh run view "$LAST_RUN" --json status -q '.status')
  if [[ "$STATUS" == "completed" ]]; then
    echo "✅ Build selesai."
    break
  else
    echo "⌛ Status: $STATUS (cek lagi 15 detik)"
    sleep 15
  fi
done

# 5. Tampilkan hanya log error
echo "=== Hanya log error terakhir ==="
gh run view "$LAST_RUN" --log | grep -i "FAILURE\|FAILED\|error\|Exception" -A5 -B2
echo "================================"
