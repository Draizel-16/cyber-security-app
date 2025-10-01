#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🎨 Fix Theme.CyberSecurityApp ..."

STYLES="app/src/main/res/values/styles.xml"
COLORS="app/src/main/res/values/colors.xml"

# Pastikan folder ada
mkdir -p app/src/main/res/values

# === Styles ===
if [ ! -f "$STYLES" ]; then
  echo "⚡ Membuat $STYLES"
  cat > "$STYLES" <<XML
<resources xmlns:tools="http://schemas.android.com/tools">

    <!-- Theme utama untuk CyberSecurityApp -->
    <style name="Theme.CyberSecurityApp" parent="Theme.Material3.DayNight.NoActionBar">
        <item name="colorPrimary">@color/purple_500</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="android:statusBarColor" tools:targetApi="l">?attr/colorPrimaryVariant</item>
    </style>

</resources>
XML
else
  if ! grep -q "Theme.CyberSecurityApp" "$STYLES"; then
    echo "✍️ Menambahkan Theme.CyberSecurityApp ke $STYLES"
    sed -i '/<\/resources>/i \
    <style name="Theme.CyberSecurityApp" parent="Theme.Material3.DayNight.NoActionBar">\
        <item name="colorPrimary">@color/purple_500</item>\
        <item name="colorPrimaryVariant">@color/purple_700</item>\
        <item name="colorOnPrimary">@color/white</item>\
        <item name="android:statusBarColor" tools:targetApi="l">?attr/colorPrimaryVariant</item>\
    </style>' "$STYLES"
  else
    echo "✅ Theme.CyberSecurityApp sudah ada di $STYLES"
  fi
fi

# === Colors ===
if [ ! -f "$COLORS" ]; then
  echo "⚡ Membuat $COLORS"
  cat > "$COLORS" <<XML
<resources>
    <color name="purple_500">#6200EE</color>
    <color name="purple_700">#3700B3</color>
    <color name="white">#FFFFFF</color>
</resources>
XML
else
  for C in purple_500 purple_700 white; do
    if ! grep -q "$C" "$COLORS"; then
      echo "✍️ Menambahkan warna $C ke $COLORS"
      sed -i "/<\/resources>/i \    <color name=\"$C\">#FFFFFF</color>" "$COLORS"
    fi
  done
fi

echo "✅ Fix selesai. Commit dan push untuk dicoba build ulang."
