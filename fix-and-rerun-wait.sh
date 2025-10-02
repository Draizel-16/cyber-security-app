#!/bin/bash
echo "🚀 Auto Fix + Rerun Workflow (Wait until finished)"

# 1. Jalankan fix build error (kalau ada)
./fix-build-error.sh

# 2. Trigger ulang workflow android.yml
echo "⚡ Menjalankan ulang workflow android.yml..."
gh workflow run android.yml

# 3. Ambil Run ID terbaru
RUN_ID=$(gh run list --workflow="android.yml" --limit 1 --json databaseId --jq '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $RUN_ID"

# 4. Tunggu sampai selesai
STATUS="in_progress"
while [ "$STATUS" == "in_progress" ] || [ "$STATUS" == "queued" ]; do
    echo "⏳ Workflow masih jalan... cek lagi 30 detik"
    sleep 30
    STATUS=$(gh run view $RUN_ID --json status --jq '.status')
done

# 5. Cek hasil akhir
CONCLUSION=$(gh run view $RUN_ID --json conclusion --jq '.conclusion')
if [ "$CONCLUSION" == "success" ]; then
    echo "✅ Workflow sukses!"
else
    echo "❌ Workflow gagal. Ambil error terakhir..."
    gh run view $RUN_ID --log | tail -n 50
fi
