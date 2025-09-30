#!/usr/bin/env bash
set -euo pipefail

echo "=== Firebase Setup Full (Auto) ==="

# CONFIG
WORKFLOW_PATH=".github/workflows/android.yml"
KEYSTORE_FILE="release.keystore"
KEYSTORE_B64="release.keystore.b64"

# 1. Cek repo git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: bukan repo git"
  exit 1
fi

# 2. Cek gh CLI
if command -v gh >/dev/null 2>&1; then
  GH_AVAILABLE=1
else
  GH_AVAILABLE=0
fi

# 3. Generate SHA-1 dari keystore
if [ ! -f "$KEYSTORE_FILE" ]; then
  echo "Keystore $KEYSTORE_FILE tidak ditemukan!"
  exit 1
fi

echo "Masukkan alias keystore:"
read KEY_ALIAS
echo "Masukkan password keystore:"
read -s KEY_STORE_PASSWORD

SHA1=$(keytool -list -v -keystore "$KEYSTORE_FILE" -alias "$KEY_ALIAS" -storepass "$KEY_STORE_PASSWORD" -keypass "$KEY_STORE_PASSWORD" 2>/dev/null | grep SHA1 | head -n 1 | awk '{print $2}')

echo "SHA-1 fingerprint: $SHA1"
echo "👉 Masukkan SHA-1 ini ke Firebase Console (Project settings → Add Fingerprint)."

# 4. Tambah google-services.json (jika ada file)
if [ -f "google-services.json" ]; then
  echo "google-services.json ditemukan, menambahkan ke git..."
  git add google-services.json
  git commit -m "chore: add google-services.json" || true
else
  echo "⚠️ File google-services.json belum ada. Download dari Firebase Console!"
fi

# 5. Commit & Push workflow
git add "$WORKFLOW_PATH" || true
git commit -m "ci: update android.yml with Firebase support" || true
git pull --rebase --autostash origin main
git push origin main

# 6. Set secrets ke GitHub (opsional)
if [ "$GH_AVAILABLE" -eq 1 ]; then
  echo "Mengunggah secrets ke GitHub..."
  gh secret set KEYSTORE_BASE64 --body "$(base64 -w0 "$KEYSTORE_FILE")"
  gh secret set KEY_STORE_PASSWORD --body "$KEY_STORE_PASSWORD"
  gh secret set KEY_ALIAS --body "$KEY_ALIAS"
else
  echo "gh CLI tidak tersedia. Set secrets manual di Settings → Secrets → Actions."
fi

echo "=== Selesai. Lanjutkan setup Firebase di Console ==="
