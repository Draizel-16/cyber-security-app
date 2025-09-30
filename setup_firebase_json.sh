#!/usr/bin/env bash
set -euo pipefail

FILE=${1:-google-services.json}
B64=${FILE}.b64
WORKFLOW=".github/workflows/android.yml"

echo "=== Setup Firebase google-services.json (Auto) ==="

# 1. Pastikan file ada
if [ ! -f "$FILE" ]; then
  echo "❌ File $FILE tidak ditemukan."
  echo "   Jalankan: ./setup_firebase_json.sh /path/to/google-services.json"
  exit 1
fi

# 2. Base64 encode
if base64 --help 2>&1 | grep -q -- '-w'; then
  base64 -w0 "$FILE" > "$B64"
else
  base64 "$FILE" | tr -d '\n' > "$B64"
fi
echo "✔ Base64 dibuat: $B64 (size: $(wc -c < "$B64") bytes)"

# 3. Upload ke GitHub Secret
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ gh CLI tidak ditemukan. Install & login dulu: gh auth login"
  exit 1
fi
gh secret set GOOGLE_SERVICES_JSON_BASE64 --body "$(cat "$B64")"
echo "✔ Secret GOOGLE_SERVICES_JSON_BASE64 sudah di-set."

# 4. Sisipkan step decode ke workflow kalau belum ada
mkdir -p "$(dirname "$WORKFLOW")"
if ! grep -q "GOOGLE_SERVICES_JSON_BASE64" "$WORKFLOW"; then
  echo "🔧 Menyisipkan step decode ke $WORKFLOW ..."
  awk '
    /- name: Build Release APK/ {
      print "      - name: Restore Firebase config (google-services.json)";
      print "        env:";
      print "          GS_B64: ${{ secrets.GOOGLE_SERVICES_JSON_BASE64 }}";
      print "        run: |";
      print "          mkdir -p app";
      print "          echo \"$GS_B64\" | base64 -d > app/google-services.json";
      print "          echo \"✔ google-services.json ditulis\"";
    }
    { print }
  ' "$WORKFLOW" > "$WORKFLOW.tmp" && mv "$WORKFLOW.tmp" "$WORKFLOW"
  echo "✔ Step decode ditambahkan."
else
  echo "ℹ Step decode sudah ada di $WORKFLOW."
fi

# 5. Commit & push
git add "$WORKFLOW"
git commit -m "ci: add Firebase google-services.json restore step" || echo "ℹ Tidak ada perubahan baru."
git pull --rebase origin main || true
git push origin main

echo "✅ Selesai! google-services.json akan otomatis di-restore saat build."
