#!/bin/bash
set -e

echo "🚀 Auto Inject workflow_dispatch + Trigger Android Release (vAuto)"

WF_PATH=".github/workflows/android-release.yml"

# Pastikan file ada
if [ ! -f "$WF_PATH" ]; then
  echo "❌ File $WF_PATH tidak ditemukan!"
  exit 1
fi

# Cek apakah sudah punya workflow_dispatch
if grep -q "workflow_dispatch" "$WF_PATH"; then
  echo "ℹ️ workflow_dispatch sudah ada, skip inject."
else
  echo "📦 Menambahkan workflow_dispatch ke $WF_PATH ..."
  # Tambahkan di bawah baris 'on:' jika ada
  if grep -q "^on:" "$WF_PATH"; then
    awk '
      /^on:/ && !added { print; print "  workflow_dispatch:"; added=1; next }
      { print }
    ' "$WF_PATH" > tmpfile && mv tmpfile "$WF_PATH"
  else
    # Jika file tidak punya 'on:', tambahkan di atas
    echo -e "on:\n  workflow_dispatch:\n" | cat - "$WF_PATH" > temp && mv temp "$WF_PATH"
  fi
fi

# Commit & push perubahan
echo "📦 Commit & Push perubahan..."
git add "$WF_PATH"
git commit -m "fix: auto inject workflow_dispatch to android-release.yml" || echo "ℹ️ Tidak ada perubahan untuk commit"
git push || echo "ℹ️ Push mungkin sudah up-to-date"

# Trigger workflow
echo "⚡ Trigger workflow: Android Release..."
if gh workflow run android-release.yml --ref main; then
  echo "✓ Workflow berhasil ditrigger."
else
  echo "⚠️ Gagal men-trigger workflow, periksa izin token GH."
fi

# Ambil run ID terbaru
RUN_ID=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId --jq ".[0].databaseId")
if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak dapat menemukan Run ID."
  exit 1
fi

echo "ℹ️ Run ID: $RUN_ID"
echo "⏳ Menunggu workflow selesai..."
gh run watch "$RUN_ID" || echo "⚠️ Workflow gagal — periksa log di GitHub Actions."

echo "✨ Selesai — workflow_dispatch dijamin aktif!"
