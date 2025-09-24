#!/bin/bash
# Script otomatis build + ambil log error terakhir Gradle

echo "=== Build Debug APK & ambil log error terakhir ==="

./gradlew assembleDebug | tee build_output.log

awk '/FAILURE:/{flag=1} /BUILD FAILED/{print; flag=0} flag' build_output.log > last_error.log

if [ -s last_error.log ]; then
    echo "✅ Error terakhir tersimpan di last_error.log"
    echo "---- Cuplikan error terakhir ----"
    tail -n 20 last_error.log
else
    echo "Tidak ada error ditemukan"
fi
