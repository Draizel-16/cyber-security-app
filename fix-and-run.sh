#!/bin/bash
echo "🚀 Auto Fix + CI Run Android App"

TARGET="app/build.gradle"
MAX_RETRY=3

# --- Fix Theme + Colors + Manifest ---
echo "🚀 Auto Fix: Theme + Colors + JVM Target"
if ! grep -q "Theme.CyberSecurityApp" app/src/main/res/values/styles.xml; then
  sed -i '/<style name="AppTheme"/a\
    <item name="android:theme">@style/Theme.CyberSecurityApp</item>' app/src/main/AndroidManifest.xml
  echo "➕ Tambah Theme.CyberSecurityApp ke styles.xml & AndroidManifest.xml"
fi

# --- Fix JVM Target Sinkron ---
echo "🚀 Sinkronkan Java + Kotlin JVM Target"
if ! grep -q "compileOptions" "$TARGET"; then
  sed -i '/android {/a\
    compileOptions {\
        sourceCompatibility JavaVersion.VERSION_17\
        targetCompatibility JavaVersion.VERSION_17\
    }' "$TARGET"
  echo "➕ Tambah compileOptions JavaVersion.VERSION_17"
fi

if ! grep -q "jvmTarget = \"17\"" "$TARGET"; then
  sed -i '/kotlinOptions {/a\
        jvmTarget = "17"' "$TARGET"
  echo "➕ Tambah kotlinOptions.jvmTarget = 17"
fi

# --- Git Commit & Push ---
echo "📦 Commit & Push..."
git add app/build.gradle app/src/main/res/values/styles.xml app/src/main/AndroidManifest.xml
if git commit -m "fix: align Java+Kotlin JVM target 17 & theme"; then
  git push origin main
else
  echo "ℹ️ Tidak ada perubahan yang perlu di-commit."
fi

# --- Enable workflow_dispatch kalau belum ---
echo "🚀 Enable workflow_dispatch trigger"
if ! grep -q "workflow_dispatch:" .github/workflows/android.yml; then
  sed -i '1i on:\n  workflow_dispatch:\n' .github/workflows/android.yml
  git add .github/workflows/android.yml
  git commit -m "chore: enable workflow_dispatch trigger"
  git push origin main
else
  echo "✅ workflow_dispatch sudah ada"
fi

# --- Trigger & Monitor with Retry ---
RETRY=0
while [[ $RETRY -lt $MAX_RETRY ]]; do
  echo "🚀 Trigger Android CI Workflow (Attempt $((RETRY+1))/$MAX_RETRY)"
  gh workflow run android.yml

  echo "📡 Ambil status run terbaru..."
  RUN_ID=$(gh run list --workflow="android.yml" --limit 1 --json databaseId -q '.[0].databaseId')
  echo "📡 Memantau Run ID: $RUN_ID"

  while true; do
    STATUS=$(gh run view "$RUN_ID" --json status -q '.status')
    CONCLUSION=$(gh run view "$RUN_ID" --json conclusion -q '.conclusion')
    echo "⏳ Status: $STATUS | Hasil: $CONCLUSION"
    if [[ "$STATUS" == "completed" ]]; then
      if [[ "$CONCLUSION" == "success" ]]; then
        echo "✅ Build Sukses!"
        exit 0
      else
        echo "❌ Build Gagal ($CONCLUSION)"
        RETRY=$((RETRY+1))
        if [[ $RETRY -ge $MAX_RETRY ]]; then
          echo "⛔ Sudah gagal $MAX_RETRY kali, stop retry."
          exit 1
        else
          echo "🔄 Retry ke-$RETRY ..."
        fi
      fi
      break
    fi
    sleep 20
  done
done
