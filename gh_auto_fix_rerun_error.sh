#!/bin/bash
echo "=== Auto Monitor + Fix + Rerun GitHub Actions ==="

MODE=${1:-ringkas}   # default = ringkas, bisa diganti jadi 'full'

# Ambil ID run terakhir
RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada workflow run ditemukan."
  exit 1
fi

echo "📦 Workflow terakhir ID: $RUN_ID"

# Looping sampai workflow selesai
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

      # Ambil semua log → filter error
      gh run view "$RUN_ID" --log | grep -i "error" > gh_last_error.log

      if [ ! -s gh_last_error.log ]; then
        echo "⚠️ Tidak ada error ditemukan dalam log."
        exit 1
      fi

      echo "---- Error terakhir ----"
      if [ "$MODE" == "full" ]; then
        cat gh_last_error.log
      else
        tail -n 15 gh_last_error.log
      fi

      # Cek apakah error dari AndroidManifest.xml
      if grep -q "AndroidManifest.xml" gh_last_error.log; then
        echo "⚠️ Ditemukan error terkait AndroidManifest.xml"
        
        # Backup dulu
        cp app/src/main/AndroidManifest.xml app/src/main/AndroidManifest.xml.bak

        # Hapus conflict marker otomatis
        sed -i '/<<<<<<< HEAD/d' app/src/main/AndroidManifest.xml
        sed -i '/=======/d' app/src/main/AndroidManifest.xml
        sed -i '/>>>>>>>/d' app/src/main/AndroidManifest.xml

        echo "✅ Conflict marker sudah dihapus dari AndroidManifest.xml"

        # Commit & push
        git add app/src/main/AndroidManifest.xml
        git commit -m "Fix: auto remove conflict markers in AndroidManifest.xml"
        git push origin main
        echo "🚀 Perubahan sudah di-push ke repository."
      fi

      # Jalankan ulang workflow
      echo "🔄 Menjalankan ulang workflow gagal..."
      gh run rerun "$RUN_ID"
      echo "✅ Workflow sudah dijalankan ulang."

      # Ambil ID run baru
      RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
      echo "📦 Workflow baru ID: $RUN_ID"
    fi
  fi

  sleep 20
done
