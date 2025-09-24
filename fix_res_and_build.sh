#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
RES_DIR="$REPO_ROOT/app/src/main/res"
BACKUP_DIR="$REPO_ROOT/.res_backups/$(date +%Y%m%d_%H%M%S)"
LOG="$REPO_ROOT/build_error.log"

echo "Working dir: $REPO_ROOT"
echo "RES dir: $RES_DIR"
echo "Backup dir: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# 1) Temukan file di res yang tidak berakhiran .xml
echo "--- Mencari file non-XML di $RES_DIR ---"
mapfile -t BAD_FILES < <(find "$RES_DIR" -type f ! -name '*.xml' -print)

if [ ${#BAD_FILES[@]} -eq 0 ]; then
  echo "✅ Tidak ada file non-XML di folder res."
else
  echo "⚠️ Ditemukan ${#BAD_FILES[@]} file non-XML. Memindahkan ke backup..."
  for f in "${BAD_FILES[@]}"; do
    # relatif path untuk git commands
    rel="${f#$REPO_ROOT/}"
    dest="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    if git ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
      # tracked -> git mv supaya perubahan tercatat
      echo "git mv $rel -> $dest"
      git mv "$rel" "$dest" || mv "$f" "$dest"
    else
      # untracked -> biasa mv
      echo "mv $rel -> $dest"
      mv "$f" "$dest"
    fi
  done

  echo "✅ Semua file non-XML dipindahkan ke: $BACKUP_DIR"
  # stage & commit changes if any
  git add -A
  if git diff --cached --quiet; then
    echo "ℹ️ Tidak ada perubahan git untuk di-commit."
  else
    git commit -m "chore: move non-XML files from res to .res_backups (fix build)" || true
    echo "🚀 Mencoba push ke origin (butuh credential jika belum dikonfigurasi)..."
    git push origin HEAD || echo "⚠️ git push gagal (cek credential atau remote)."
  fi
fi

# 2) Jalankan build dan simpan log
echo "---- Menjalankan: ./gradlew assembleDebug (log -> $LOG) ----"
# jangan exit script jika gradle gagal, kita ingin lognya tetap tersedia
./gradlew assembleDebug --no-daemon --console=plain --stacktrace > "$LOG" 2>&1 || true

# 3) Summarize errors
echo
echo "===== RINGKASAN ERROR (grep) ====="
grep -niE "FAILURE:|Exception:|Caused by:|ERROR:|ManifestMerger2|A problem occurred" "$LOG" | sed -n '1,200p' || echo "Tidak menemukan string error yang umum di log."

echo
echo "===== 200 BARIS TERAKHIR $LOG ====="
tail -n 200 "$LOG" || true

echo
echo "✅ Backup disimpan di: $BACKUP_DIR"
echo "✅ Full log: $LOG"
echo "📌 Jika ada error terkait file manifest/styles, buka file yang disebut di log dan periksa line/kolom yang dilaporkan."
echo "📌 Untuk membatalkan perubahan yang dipush: gunakan git revert / reset pada commit yang terkait."

exit 0
