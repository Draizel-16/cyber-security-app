#!/bin/bash
# === Cek error di AndroidManifest.xml ===

FILE="app/src/main/AndroidManifest.xml"

echo "=== Validasi AndroidManifest.xml dengan xmllint ==="
if [ ! -f "$FILE" ]; then
    echo "❌ File $FILE tidak ditemukan!"
    exit 1
fi

# Mode fix indent
if [ "$1" == "--fix-indent" ]; then
    echo "📦 Membuat backup: ${FILE}.bak_$(date +%Y%m%d%H%M%S)"
    cp "$FILE" "${FILE}.bak_$(date +%Y%m%d%H%M%S)"

    echo "🛠️  Merapikan indentasi file..."
    xmllint --format "$FILE" -o "$FILE"
    if [ $? -eq 0 ]; then
        echo "✅ Berhasil dirapikan."
    else
        echo "❌ Gagal merapikan, cek file backup."
    fi
    exit 0
fi

# Simpan error ke file log
xmllint --noout --format "$FILE" 2> manifest_error.log

if [ $? -eq 0 ]; then
    echo "✅ Tidak ada error XML, file valid."
else
    echo "⚠️ Ada error, lihat detail di manifest_error.log"
    echo "---- Cuplikan error ----"
    grep -n "error" manifest_error.log || cat manifest_error.log
    echo "-------------------------"
    
    # Tampilkan baris sekitar error
    LINE=$(grep -oE "line [0-9]+" manifest_error.log | awk '{print $2}' | head -n1)
    if [ ! -z "$LINE" ]; then
        echo "🔎 Menampilkan baris sekitar line $LINE di $FILE"
        nl -ba "$FILE" | sed -n "$((LINE-3)),$((LINE+3))p"
    fi
fi
