#!/usr/bin/env bash
set -euo pipefail

# CONFIG
WORKFLOW_PATH=".github/workflows/android-ci.yml"
KEYSTORE_FILE="release.keystore"
KEYSTORE_B64="release.keystore.b64"

echo "=== Android CI setup (auto) ==="
pwd

# 1) pastikan kita di repo git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: bukan direktori git. cd ke repo proyek Anda dulu." >&2
  exit 1
fi

# 2) cek gh cli
if command -v gh >/dev/null 2>&1; then
  GH_AVAILABLE=1
else
  GH_AVAILABLE=0
fi

# 3) siapkan keystore (jika belum ada)
if [ ! -f "$KEYSTORE_FILE" ]; then
  echo "Tidak ditemukan $KEYSTORE_FILE — membuat keystore baru (keytool diperlukan)..."
  read -p "Masukkan alias keystore (default: key): " KEY_ALIAS_INPUT
  KEY_ALIAS=${KEY_ALIAS_INPUT:-key}
  read -sp "Masukkan password keystore (akan dipakai juga sebagai key password) (kosong->'android'): " KEY_STORE_PASSWORD
  echo
  KEY_STORE_PASSWORD=${KEY_STORE_PASSWORD:-android}
  KEY_PASSWORD="$KEY_STORE_PASSWORD"

  echo "Membuat keystore: alias=$KEY_ALIAS ..."
  keytool -genkeypair -v \
    -keystore "$KEYSTORE_FILE" \
    -storepass "$KEY_STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=example, OU=Dev, O=Company, L=City, ST=State, C=ID"

  echo "Keystore dibuat: $KEYSTORE_FILE"
else
  echo "$KEYSTORE_FILE ditemukan."
  read -p "Gunakan keystore ini? (y/n) [y]: " use; use=${use:-y}
  if [ "$use" != "y" ] && [ "$use" != "Y" ]; then
    echo "Batal. Hapus $KEYSTORE_FILE dulu jika ingin membuat baru." >&2
    exit 1
  fi
  read -p "Masukkan alias keystore (yang digunakan untuk signing): " KEY_ALIAS
  read -sp "Masukkan password keystore: " KEY_STORE_PASSWORD; echo
  read -sp "Masukkan key password (kosong untuk pakai same as keystore): " KEY_PASSWORD; echo
  if [ -z "$KEY_PASSWORD" ]; then KEY_PASSWORD="$KEY_STORE_PASSWORD"; fi
fi

# 4) buat base64 file (single-line)
echo "Membuat base64 encoded keystore -> $KEYSTORE_B64"
if base64 --help 2>&1 | grep -q -- '-w'; then
  base64 -w0 "$KEYSTORE_FILE" > "$KEYSTORE_B64"
else
  # fallback (macos/linux without -w) -> produce single line
  base64 "$KEYSTORE_FILE" | tr -d '\n' > "$KEYSTORE_B64"
fi
echo "File $KEYSTORE_B64 dibuat (size: $(wc -c < "$KEYSTORE_B64") bytes)."

# 5) buat workflow file (overwrite jika ada)
mkdir -p "$(dirname "$WORKFLOW_PATH")"
cat > "$WORKFLOW_PATH" <<'YAML'
name: Android CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: temurin
          java-version: '17'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v2
        with:
          api-level: '34'
          build-tools: '34.0.0'

      - name: Decode keystore (from secret KEYSTORE_BASE64)
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
        run: |
          if [ -n "$KEYSTORE_BASE64" ]; then
            echo "$KEYSTORE_BASE64" | base64 -d > release.keystore
          fi

      - name: Create keystore.properties
        run: |
          cat > keystore.properties <<EOF
          storeFile=release.keystore
          storePassword=${{ secrets.KEY_STORE_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
EOF

      - name: Build Release APK
        run: ./gradlew assembleRelease --no-daemon

      - name: Upload Release APK
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: app/build/outputs/apk/release/*.apk
YAML

echo "Workflow ditulis ke $WORKFLOW_PATH"

# 6) commit & push workflow (hanya file workflow)
git add "$WORKFLOW_PATH"
git commit -m "ci: add Android CI workflow (auto)" || echo "Tidak ada perubahan untuk workflow (sudah commit sebelumnya)."
# tarik update remote (autostash jika perlu) lalu push
if git pull --rebase --autostash origin main; then
  git push origin main
else
  echo "git pull gagal, mencoba push dengan --force-with-lease"
  git push origin main --force-with-lease
fi

# 7) (opsional) set GitHub Secrets via gh CLI
if [ "$GH_AVAILABLE" -eq 1 ]; then
  echo "Mendeteksi gh CLI — akan mengunggah secrets ke repo saat ini."
  if ! gh auth status >/dev/null 2>&1; then
    echo "Mohon login gh CLI dahulu: gh auth login" >&2
    echo "Saya akan berhenti di sini; jalankan lagi setelah gh auth login."
    exit 0
  fi

  echo "Mengunggah secrets (KEYSTORE_BASE64, KEY_STORE_PASSWORD, KEY_PASSWORD, KEY_ALIAS) ke repo..."
  gh secret set KEYSTORE_BASE64 --body "$(cat "$KEYSTORE_B64")"
  gh secret set KEY_STORE_PASSWORD --body "$KEY_STORE_PASSWORD"
  gh secret set KEY_PASSWORD --body "$KEY_PASSWORD"
  gh secret set KEY_ALIAS --body "$KEY_ALIAS"
  echo "Secrets ter-set."
else
  echo "gh CLI tidak ditemukan — tidak mengupload secrets otomatis."
  echo "Silakan unggah secret berikut secara manual ke Settings → Secrets → Actions:"
  echo "  - KEYSTORE_BASE64  (isi dengan isi file $KEYSTORE_B64)"
  echo "  - KEY_STORE_PASSWORD  (keystore password)"
  echo "  - KEY_PASSWORD  (key password)"
  echo "  - KEY_ALIAS  (alias key)"
fi

echo "Selesai. Workflow sudah dipush. Cek Actions di GitHub."
