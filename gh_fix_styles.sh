#!/bin/bash
set -e

STYLES_FILE="app/src/main/res/values/styles.xml"
MANIFEST_FILE="app/src/main/AndroidManifest.xml"
BACKUP_DIR="backup_styles"

echo "=== Perbaiki styles.xml & update AndroidManifest.xml ==="

# --- Flags ---
check_mode=false
show_full=false
restore_mode=false
validate_only=false

for arg in "$@"; do
  case $arg in
    --check) check_mode=true ;;
    --show-full) show_full=true ;;
    --restore) restore_mode=true ;;
    --validate-only) validate_only=true ;;
  esac
done

# Buat folder backup
mkdir -p "$BACKUP_DIR"

# --- Mode restore ---
if $restore_mode; then
  last_backup=$(ls -t "$BACKUP_DIR" | head -n 1 || true)
  if [[ -n "$last_backup" ]]; then
    cp "$BACKUP_DIR/$last_backup" "$STYLES_FILE"
    echo "✅ styles.xml berhasil direstore dari $last_backup"
  else
    echo "⚠️ Tidak ada backup styles.xml ditemukan."
  fi
  exit 0
fi

# --- Mode validate-only ---
if $validate_only; then
  echo "🔍 Validasi styles.xml dengan xmllint..."
  if command -v xmllint >/dev/null 2>&1; then
    if xmllint --noout "$STYLES_FILE"; then
      echo "✅ XML valid"
    else
      echo "❌ XML tidak valid, cek $STYLES_FILE"
    fi
  else
    echo "⚠️ xmllint tidak ditemukan, install dulu (contoh: sudo apt install libxml2-utils)"
  fi
  exit 0
fi

# Backup dulu
timestamp=$(date +%Y%m%d%H%M%S)
cp "$STYLES_FILE" "$BACKUP_DIR/styles.xml.bak_$timestamp" 2>/dev/null || true
cp "$MANIFEST_FILE" "$BACKUP_DIR/AndroidManifest.xml.bak_$timestamp" 2>/dev/null || true
echo "📦 Backup dibuat: $BACKUP_DIR/styles.xml.bak_$timestamp"

# 1. Pastikan folder values ada
mkdir -p app/src/main/res/values

# 2. Jika styles.xml belum ada, buat baru
if [[ ! -f "$STYLES_FILE" ]]; then
  echo "📄 Membuat styles.xml baru..."
  cat > "$STYLES_FILE" <<'EOF'
<resources xmlns:tools="http://schemas.android.com/tools">

    <!-- Tema utama aplikasi -->
    <style name="Theme.CyberSecurityApp" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
        <item name="colorPrimary">@color/purple_500</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="colorSecondary">@color/teal_200</item>
    </style>

</resources>
EOF
  echo "✅ styles.xml berhasil dibuat"
else
  # Jika sudah ada, cek apakah theme sudah ada
  if grep -q "Theme.CyberSecurityApp" "$STYLES_FILE"; then
    echo "ℹ️ Theme.CyberSecurityApp sudah ada di styles.xml"
  else
    echo "✏️ Menambahkan Theme.CyberSecurityApp ke styles.xml"
    cat >> "$STYLES_FILE" <<'EOF'

    <!-- Tema utama aplikasi -->
    <style name="Theme.CyberSecurityApp" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
        <item name="colorPrimary">@color/purple_500</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="colorSecondary">@color/teal_200</item>
    </style>
EOF
  fi
fi

# 3. Update AndroidManifest.xml agar pakai Theme.CyberSecurityApp
if grep -q 'android:theme="@style/Theme.MaterialComponents.DayNight.DarkActionBar"' "$MANIFEST_FILE"; then
  echo "✏️ Mengganti theme di AndroidManifest.xml"
  sed -i 's|android:theme="@style/Theme.MaterialComponents.DayNight.DarkActionBar"|android:theme="@style/Theme.CyberSecurityApp"|' "$MANIFEST_FILE"
fi

# 4. Mode check
if $check_mode; then
  echo "---- Cuplikan styles.xml ----"
  if $show_full; then
    cat "$STYLES_FILE"
  else
    head -n 15 "$STYLES_FILE"
  fi
  echo "------------------------------------"
  echo "🔎 Mode check selesai, tidak ada commit/push."
  exit 0
fi

# 5. Commit & push
echo "🚀 Commit & push perubahan..."
git add "$STYLES_FILE" "$MANIFEST_FILE"
git commit -m "Fix: add/update styles.xml with Theme.CyberSecurityApp and update manifest"
git push origin main

echo "🎉 Selesai! Coba build ulang di GitHub Actions."
