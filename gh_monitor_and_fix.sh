#!/bin/bash
echo "=== Monitor Build Terakhir di GitHub Actions ==="

# Ambil ID run terakhir
RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada workflow run ditemukan."
  exit 1
fi

echo "📦 Workflow terakhir ID: $RUN_ID"

# Looping sampai status completed
while true; do
  STATUS=$(gh run view "$RUN_ID" --json status --jq '.status')
  CONCLUSION=$(gh run view "$RUN_ID" --json conclusion --jq '.conclusion')
  
  echo "⏳ Status: $STATUS"

  if [ "$STATUS" == "completed" ]; then
    if [ "$CONCLUSION" == "success" ]; then
      echo "✅ Build selesai dengan status SUCCESS"
      exit 0
    else
      echo "❌ Build gagal, ambil log error..."
      ./gh_last_error.sh

      # Cek apakah error terkait AndroidManifest.xml
      if grep -q "AndroidManifest.xml" gh_last_error.log; then
        echo "⚠️ Ditemukan error terkait AndroidManifest.xml"
        ./gh_fix_manifest_commit.sh
      fi

      echo "🔄 Menjalankan ulang workflow gagal..."
      gh run rerun "$RUN_ID"
      echo "✅ Workflow sudah dijalankan ulang."
      exit 1
    fi
  fi

  # Tunggu 20 detik sebelum cek lagi
  sleep 20
done
