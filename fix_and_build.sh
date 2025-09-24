#!/bin/bash
echo "=== Perbaikan + Build APK ==="

# === Step 1: Backup styles.xml ===
STYLES_FILE="app/src/main/res/values/styles.xml"
if [ -f "$STYLES_FILE" ]; then
    cp "$STYLES_FILE" "$STYLES_FILE.bak_$(date +%Y%m%d%H%M%S)"
    echo "📦 Backup dibuat."
fi

# === Step 2: Pindahkan tag <application> dari styles.xml jika ada ===
if grep -q "<application" "$STYLES_FILE"; then
    echo "⚠️  Ditemukan <application> di styles.xml, akan dipindahkan..."
    sed -i '/<application/,/<\/application>/d' "$STYLES_FILE"
    echo "✅ <application> berhasil dihapus dari styles.xml"
else
    echo "👌 Tidak ada <application> di styles.xml, aman."
fi

# === Step 3: Bersihkan file backup non-xml di res/values ===
VALUES_DIR="app/src/main/res/values"
BACKUP_DIR="app/src/main/res/backup_values"
mkdir -p "$BACKUP_DIR"

BACKUPS=$(find "$VALUES_DIR" -type f ! -name "*.xml")

if [ -n "$BACKUPS" ]; then
    echo "📦 Memindahkan file backup non-xml ke $BACKUP_DIR ..."
    mv $BACKUPS "$BACKUP_DIR"/
    echo "✅ File backup berhasil dipindahkan."
else
    echo "👌 Tidak ada file backup non-xml di $VALUES_DIR"
fi

# === Step 4: Jalankan build ===
echo "🔨 Jalankan build Gradle..."
./gradlew assembleDebug 2>&1 | tee build_error.log

# === Step 5: Cek hasil ===
if grep -qi "FAILURE:" build_error.log; then
    echo "❌ Build gagal. Detail error tersimpan di build_error.log"
    echo "👉 Gunakan: grep -A5 -B5 'error' build_error.log untuk lihat error sekitar."
else
    echo "🎉 Build sukses! APK ada di app/build/outputs/apk/debug/"
fi
