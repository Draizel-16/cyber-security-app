#!/bin/bash
# gh_show_errors.sh
# Ambil log error terakhir dari GitHub Actions dan tampilkan ringkas

LOGFILE="gh_last_error.log"
ERRORFILE="errors_only.txt"

echo "=== Ambil error terakhir dari GitHub Actions ==="

# Jalankan gh_error_only.sh untuk update log terbaru
if [[ -x ./gh_error_only.sh ]]; then
    ./gh_error_only.sh full > "$LOGFILE"
else
    echo "❌ Script gh_error_only.sh tidak ditemukan atau tidak bisa dieksekusi."
    exit 1
fi

# Filter hanya baris error/exception/failed
egrep -i "error|exception|failed" "$LOGFILE" > "$ERRORFILE"

# Cek hasil
if [[ -s "$ERRORFILE" ]]; then
    echo "✅ Error berhasil disimpan ke $ERRORFILE"
    echo "---- Cuplikan error ----"
    tail -n 20 "$ERRORFILE"
else
    echo "✅ Tidak ada error ditemukan."
fi
