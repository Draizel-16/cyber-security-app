#!/bin/bash
# Script All-in-One untuk memperbaiki AndroidManifest.xml
# Fitur: auto fix, commit, validate, show-full, restore backup

set -e

MANIFEST="app/src/main/AndroidManifest.xml"
BACKUP_DIR="$(dirname "$MANIFEST")"

show_usage() {
    echo "Usage: $0 [--check | --validate-only | --show-full | --restore]"
    echo "  Default     : Fix + commit + push otomatis"
    echo "  --check     : Cek & validasi tanpa commit/push"
    echo "  --validate-only : Hanya validasi XML"
    echo "  --show-full : Tampilkan isi manifest lengkap"
    echo "  --restore   : Kembalikan manifest dari backup terbaru"
    exit 1
}

timestamp() {
    date +"%Y%m%d%H%M%S"
}

restore_backup() {
    echo "=== Restore AndroidManifest.xml dari backup terbaru ==="
    LAST_BACKUP=$(ls -t "$BACKUP_DIR"/AndroidManifest.xml.bak_* 2>/dev/null | head -n 1)

    if [ -z "$LAST_BACKUP" ]; then
        echo "❌ Tidak ada backup ditemukan."
        exit 1
    fi

    cp "$LAST_BACKUP" "$MANIFEST"
    echo "✅ Berhasil restore dari $LAST_BACKUP"
    exit 0
}

validate_xml() {
    if command -v xmllint >/dev/null 2>&1; then
        echo "🔍 Validasi XML dengan xmllint..."
        if xmllint --noout "$MANIFEST"; then
            echo "✅ XML valid"
        else
            echo "❌ XML tidak valid"
            exit 1
        fi
    else
        echo "⚠️ xmllint tidak ditemukan, skip validasi XML"
    fi
}

# === Mode Restore ===
if [[ "$1" == "--restore" ]]; then
    restore_backup
fi

# === Buat backup ===
BACKUP_FILE="$MANIFEST.bak_$(timestamp)"
cp "$MANIFEST" "$BACKUP_FILE"
echo "📦 Backup dibuat: $BACKUP_FILE"

# === Perbaikan dasar (hapus duplikat package/application) ===
sed -i '/<<<<<<<\|=======\|>>>>>>>/d' "$MANIFEST"
awk '!seen[$0]++' "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"

# === Validasi XML ===
validate_xml

# === Tampilkan hasil ===
echo "---- Hasil AndroidManifest.xml ----"
if [[ "$1" == "--show-full" || "$2" == "--show-full" ]]; then
    cat "$MANIFEST"
else
    head -n 15 "$MANIFEST"
    echo "------------------------------------"
fi

# === Mode khusus ===
if [[ "$1" == "--check" || "$2" == "--check" ]]; then
    echo "🔎 Mode check selesai, tidak ada commit/push."
    exit 0
elif [[ "$1" == "--validate-only" ]]; then
    echo "🔎 Mode validate-only selesai."
    exit 0
fi

# === Commit & Push otomatis ===
echo "🚀 Commit & push perubahan..."
git add "$MANIFEST"
git commit -m "Fix: cleanup AndroidManifest.xml (auto)" || echo "⚠️ Tidak ada perubahan untuk di-commit"
git push origin main || echo "⚠️ Push gagal"
