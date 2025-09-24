#!/bin/bash
echo "=== Validasi & Perbaiki AndroidManifest.xml ==="

MANIFEST="app/src/main/AndroidManifest.xml"
BACKUP="$MANIFEST.bak_$(date +%Y%m%d%H%M%S)"

# Backup dulu
cp "$MANIFEST" "$BACKUP"
echo "📦 Backup dibuat: $BACKUP"

# Hapus semua duplikat deklarasi package, sisakan yang pertama
sed -i '0,/package=/!s/.*package=.*//g' "$MANIFEST"

# Hapus duplikat <application>, sisakan yang pertama
awk '
BEGIN { seen=0 }
{
    if ($0 ~ /<application/) {
        if (seen==1) next
        seen=1
    }
    print
}
' "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"

echo "✅ Duplikat package & application sudah dihapus."

# Cek validitas XML dengan xmllint
if command -v xmllint >/dev/null 2>&1; then
    echo "🔎 Mengecek validitas XML..."
    xmllint --noout "$MANIFEST"
    if [ $? -ne 0 ]; then
        echo "❌ XML masih invalid. Periksa file: $MANIFEST"
        echo "🛑 Commit dibatalkan."
        exit 1
    else
        echo "✅ XML valid."
    fi
else
    echo "⚠️ xmllint tidak ditemukan, lewati pengecekan XML."
fi

# Tampilkan cuplikan hasil
echo "---- Cuplikan hasil AndroidManifest.xml ----"
head -n 15 "$MANIFEST"
echo "--------------------------------------------"

# Commit & push
echo "🚀 Commit & push perubahan..."
git add "$MANIFEST"
git commit -m "Fix: cleanup duplicate package & application in AndroidManifest.xml"
git push origin main
