#!/bin/bash
# Ambil log error terakhir dari GitHub Actions

echo "=== Ambil log error terakhir dari GitHub Actions ==="

# Pastikan sudah install GitHub CLI di Termux: pkg install gh -y
# Login sekali dulu: gh auth login

# Ambil run terakhir dari workflow
RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada workflow ditemukan."
  exit 1
fi

echo "📦 Workflow terakhir ID: $RUN_ID"

# Download log build terakhir
gh run view $RUN_ID --log > gh_build.log

# Ekstrak error dari log
awk '/FAILURE:/{flag=1} /BUILD FAILED/{print; flag=0} flag' gh_build.log > gh_last_error.log

if [ -s gh_last_error.log ]; then
    echo "✅ Error terakhir tersimpan di gh_last_error.log"
    echo "---- Cuplikan error terakhir ----"
    tail -n 20 gh_last_error.log
else
    echo "Tidak ada error ditemukan di log GitHub Actions"
fi
