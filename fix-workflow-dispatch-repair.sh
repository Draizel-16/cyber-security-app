#!/bin/bash
set -e

echo "🚀 Repair workflow_dispatch section in android-release.yml (v2)"

WF_PATH=".github/workflows/android-release.yml"

if [ ! -f "$WF_PATH" ]; then
  echo "❌ File $WF_PATH tidak ditemukan!"
  exit 1
fi

# Backup dulu
cp "$WF_PATH" "$WF_PATH.bak"
echo "📦 Backup dibuat: $WF_PATH.bak"

# Normalisasi YAML section
echo "🛠️ Memperbaiki struktur YAML..."
awk '
BEGIN {found_on=0; found_dispatch=0}
{
  if ($0 ~ /^on:/) {
    found_on=1
    print "on:"
    print "  workflow_dispatch:"
    print "  push:"
    print "    branches: [ main ]"
    next
  }
  if ($0 ~ /workflow_dispatch:/) {found_dispatch=1}
  print
}
END {
  if (!found_on) {
    print "on:"
    print "  workflow_dispatch:"
    print "  push:"
    print "    branches: [ main ]"
  }
}' "$WF_PATH.bak" > "$WF_PATH"

# Tampilkan hasil perbaikan
echo "✅ Hasil perbaikan preview:"
head -20 "$WF_PATH"

# Commit & push
echo "📦 Commit & push perubahan..."
git add "$WF_PATH"
git commit -m "fix: enforce valid workflow_dispatch in android-release.yml" || echo "ℹ️ Tidak ada perubahan untuk commit"
git push || echo "ℹ️ Push mungkin sudah up-to-date"

# Trigger ulang
echo "⚡ Trigger workflow: Android Release..."
if gh workflow run android-release.yml --ref main; then
  echo "✓ Workflow berhasil ditrigger."
else
  echo "⚠️ Gagal men-trigger workflow, periksa izin token GH."
fi

# Ambil run ID terbaru
RUN_ID=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId --jq ".[0].databaseId")
echo "ℹ️ Run ID: $RUN_ID"
gh run watch "$RUN_ID" || echo "⚠️ Workflow gagal — periksa log di GitHub Actions."

echo "✨ Selesai — Struktur YAML & workflow_dispatch sudah diperbaiki!"
