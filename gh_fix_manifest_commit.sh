#!/bin/bash
# Ambil error terakhir dari GitHub Actions, perbaiki AndroidManifest.xml jika ada conflict, lalu commit & push

WORKFLOW_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
echo "=== Ambil log error terakhir dari GitHub Actions ==="
echo "📦 Workflow terakhir ID: $WORKFLOW_ID"

if [ -z "$WORKFLOW_ID" ]; then
  echo "❌ Tidak ada workflow ditemukan."
  exit 1
fi

# Simpan log error ke file
gh run view "$WORKFLOW_ID" --log > gh_last_error.log
echo "✅ Error terakhir tersimpan di gh_last_error.log"

FILE="app/src/main/AndroidManifest.xml"

# Cek apakah error terkait manifest conflict
if grep -q "AndroidManifest.xml" gh_last_error.log; then
  echo "⚠️  Ditemukan error terkait AndroidManifest.xml"

  if [ -f "$FILE" ]; then
    echo "=== Membersihkan conflict marker di $FILE ==="
    cp "$FILE" "${FILE}.bak"
    echo "📦 Backup dibuat: ${FILE}.bak"

    # Hapus marker konflik
    sed -i '/<<<<<<<\|=======\|>>>>>>>/d' "$FILE"

    echo "✅ Conflict marker sudah dihapus dari $FILE"
    echo "---- Cuplikan setelah perbaikan ----"
    head -n 10 "$FILE"
    echo "------------------------------------"

    # Git add, commit, dan push
    echo "🚀 Commit & push perubahan..."
    git add "$FILE"
    git commit -m "Fix: remove Git conflict markers in AndroidManifest.xml"
    git push origin HEAD
    echo "✅ Perubahan sudah di-push ke repository."
  else
    echo "❌ File $FILE tidak ditemukan!"
  fi
else
  echo "ℹ️ Tidak ada error manifest ditemukan di log terakhir."
fi
