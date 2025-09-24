#!/bin/bash
# gh_rerun_last.sh
# Rerun workflow terakhir (atau terakhir gagal) + lihat log error + cek status + cancel

set -e

echo "=== GitHub Actions: Rerun & Cek Error ==="

# Pastikan gh CLI ada
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ GitHub CLI (gh) belum terinstall. Install dulu dengan:"
  echo "   pkg install gh"
  exit 1
fi

# Pastikan login
if ! gh auth status >/dev/null 2>&1; then
  echo "❌ Belum login GitHub CLI. Jalankan:"
  echo "   gh auth login"
  exit 1
fi

# Opsi cek status
if [ "$1" == "--status" ]; then
  echo "📋 Daftar 5 workflow terakhir:"
  gh run list --limit 5 --json databaseId,displayTitle,status,conclusion,createdAt \
    -q '.[] | "🆔 \(.databaseId) | \(.status) | \(.conclusion) | \(.displayTitle) | \(.createdAt)"'
  exit 0
fi

# Mode cancel workflow yang masih berjalan
if [ "$1" == "--cancel" ]; then
  RUN_ID=$(gh run list --limit 1 --json databaseId,status \
    -q '.[] | select(.status=="in_progress") | .databaseId' | head -n1)

  if [ -z "$RUN_ID" ]; then
    echo "⚠️ Tidak ada workflow in-progress untuk dibatalkan."
    exit 0
  fi

  echo "🛑 Membatalkan workflow RUN_ID=$RUN_ID ..."
  gh run cancel "$RUN_ID"
  echo "✅ Workflow berhasil dibatalkan."
  exit 0
fi

# Mode rerun last failed
if [ "$1" == "--last-failed" ]; then
  RUN_ID=$(gh run list --limit 1 --json databaseId,status,conclusion \
    -q '.[] | select(.status=="completed" and .conclusion=="failure") | .databaseId' | head -n1)

  if [ -z "$RUN_ID" ]; then
    echo "⚠️ Tidak ada workflow gagal terbaru untuk direrun."
    exit 0
  fi

  echo "🔄 Rerun workflow gagal terakhir (RUN_ID=$RUN_ID)..."
  gh run rerun "$RUN_ID"
  echo "✅ Workflow gagal sudah dijalankan ulang!"
  exit 0
fi

# Ambil RUN_ID terakhir (apapun statusnya)
RUN_ID=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada workflow run ditemukan di repo ini."
  exit 1
fi

# Mode lihat log error saja
if [ "$1" == "--logs" ]; then
  echo "📜 Menampilkan log error workflow terakhir (RUN_ID=$RUN_ID)..."
  gh run view "$RUN_ID" --log
  exit 0
fi

# Mode follow log real-time
if [ "$1" == "--follow" ]; then
  echo "🔄 Rerun workflow terakhir (RUN_ID=$RUN_ID)..."
  gh run rerun "$RUN_ID"
  echo "📡 Tunggu, menampilkan log real-time..."
  gh run watch "$RUN_ID" --exit-status
  gh run view "$RUN_ID" --log
  exit 0
fi

# Default: rerun saja
echo "🔄 Rerun workflow terakhir (RUN_ID=$RUN_ID)..."
gh run rerun "$RUN_ID"

echo "✅ Workflow berhasil dijalankan ulang!"
echo "👉 Untuk melihat error detail jalankan:"
echo "   ./gh_rerun_last.sh --logs"
echo "👉 Untuk pantau log real-time jalankan:"
echo "   ./gh_rerun_last.sh --follow"
echo "👉 Untuk rerun hanya workflow gagal terakhir:"
echo "   ./gh_rerun_last.sh --last-failed"
echo "👉 Untuk cek daftar status workflow terakhir:"
echo "   ./gh_rerun_last.sh --status"
echo "👉 Untuk batalkan workflow yang sedang berjalan:"
echo "   ./gh_rerun_last.sh --cancel"
