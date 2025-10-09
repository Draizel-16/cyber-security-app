#!/bin/bash
set -e

WF_FILE=".github/workflows/android.yml"

echo "🚀 Cek isi blok 'on:' di $WF_FILE"

if [[ ! -f "$WF_FILE" ]]; then
  echo "❌ Workflow file $WF_FILE tidak ditemukan!"
  exit 1
fi

# Ambil semua baris dari "on:" sampai sebelum line pertama tanpa indentasi (next root key)
awk '/^on:/,/^[^[:space:]]/{print}' "$WF_FILE"
