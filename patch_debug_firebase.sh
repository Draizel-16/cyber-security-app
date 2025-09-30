#!/usr/bin/env bash
set -euo pipefail

WORKFLOW=".github/workflows/android.yml"

echo "=== Patch Debug Firebase ==="

if ! grep -q "Debug cek google-services.json" "$WORKFLOW"; then
  echo "🔧 Menyisipkan step debug ke $WORKFLOW ..."
  awk '
    /Decode google-services.json/ {
      print;
      print "    - name: Debug cek google-services.json";
      print "      run: |";
      print "        echo \"=== Isi google-services.json ===\"";
      print "        cat app/google-services.json";
      next
    }
    { print }
  ' "$WORKFLOW" > "$WORKFLOW.tmp" && mv "$WORKFLOW.tmp" "$WORKFLOW"
else
  echo "⚠️ Step debug sudah ada, dilewati."
fi

git add "$WORKFLOW"
git commit -m "ci: add debug step for google-services.json" || echo "⚠️ Tidak ada perubahan untuk di-commit."
git push origin main

echo "✅ Selesai. Jalankan workflow di GitHub Actions untuk cek log debug."
