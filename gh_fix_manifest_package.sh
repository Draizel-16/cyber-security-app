#!/bin/bash
echo "=== Perbaiki AndroidManifest.xml & Push ke GitHub ==="

MANIFEST="app/src/main/AndroidManifest.xml"
BACKUP="$MANIFEST.bak"

# 1. Cek file manifest
if [ ! -f "$MANIFEST" ]; then
  echo "❌ File $MANIFEST tidak ditemukan!"
  exit 1
fi

# 2. Backup dulu
cp "$MANIFEST" "$BACKUP"
echo "📦 Backup dibuat: $BACKUP"

# 3. Hapus duplikat package
awk '
/<manifest/ && /package=/ {
    if (!seen) {
        seen=1
        print $0
    } else {
        next
    }
    next
}
{print}
' "$BACKUP" > "$MANIFEST"

# 4. Validasi hasil
COUNT=$(grep -c 'package=' "$MANIFEST")
if [ "$COUNT" -eq 1 ]; then
    echo "✅ Valid: hanya ada 1 deklarasi package."
else
    echo "⚠️ Warning: masih ada $COUNT deklarasi package, cek manual."
fi

# 5. Tampilkan cuplikan hasil
echo "---- Cuplikan AndroidManifest.xml setelah fix ----"
head -n 10 "$MANIFEST"
echo "---------------------------------"

# 6. Commit & push
echo "🚀 Commit & push perubahan..."
git add "$MANIFEST"
git commit -m "Fix: remove duplicate package in AndroidManifest.xml"
git push origin main
echo "✅ Perubahan sudah di-push ke repository."

# 7. Ambil workflow terakhir
RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -n "$RUN_ID" ]; then
    echo "🔄 Rerun workflow terakhir (ID: $RUN_ID)..."
    gh run rerun "$RUN_ID"

    echo "⏳ Menunggu workflow selesai..."
    while true; do
        STATUS=$(gh run view "$RUN_ID" --json status --jq '.status')
        if [ "$STATUS" == "completed" ]; then
            break
        fi
        sleep 10
    done

    echo "📦 Workflow selesai. Ambil log error..."

    if [ "$1" == "full" ]; then
        echo "🔎 Mode FULL → tampilkan semua log error"
        gh run view "$RUN_ID" --log | tee gh_last_error.log
    else
        echo "🔎 Mode RINGKAS → hanya error/failed/exception"
        gh run view "$RUN_ID" --log \
          | grep -i "error\|failed\|exception\|BUILD FAILED" \
          | tee gh_last_error.log
    fi

    echo "✅ Error terbaru tersimpan di gh_last_error.log"
else
    echo "⚠️ Tidak ditemukan workflow run sebelumnya."
fi
