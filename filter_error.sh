#!/bin/bash
echo "🔎 Menjalankan build, hanya menampilkan ERROR / FAILED..."

# jalankan gradle, simpan semua log, tapi hanya tampilkan baris yang ada 'error' atau 'failed'
./gradlew assembleRelease 2>&1 | tee build_full.log | grep -iE "error|failed" || true

echo ""
echo "📂 Log lengkap tersimpan di build_full.log"
echo "⚠️  Di atas hanya ringkasan error/failed, bukan full log."
