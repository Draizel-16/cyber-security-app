#!/bin/bash
set -e

echo "🚀 Auto Fix: Theme + Colors + JVM Target"

STYLES="app/src/main/res/values/styles.xml"
COLORS="app/src/main/res/values/colors.xml"
MANIFEST="app/src/main/AndroidManifest.xml"
APP_GRADLE="app/build.gradle"

# --- 1. Fix styles.xml ---
if [ ! -f "$STYLES" ]; then
    echo "📄 Membuat styles.xml ..."
    mkdir -p app/src/main/res/values
    cat > "$STYLES" <<EOF
<resources>
    <style name="Theme.CyberSecurityApp" parent="Theme.Material3.DayNight.NoActionBar">
        <item name="colorPrimary">@color/purple_500</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
    </style>
</resources>
EOF
else
    if ! grep -q "Theme.CyberSecurityApp" "$STYLES"; then
        echo "➕ Tambah Theme.CyberSecurityApp ke styles.xml"
        sed -i '/<\/resources>/i \
    <style name="Theme.CyberSecurityApp" parent="Theme.Material3.DayNight.NoActionBar">\
        <item name="colorPrimary">@color/purple_500</item>\
        <item name="colorPrimaryVariant">@color/purple_700</item>\
        <item name="colorOnPrimary">@color/white</item>\
    </style>' "$STYLES"
    fi
fi

# --- 2. Fix colors.xml ---
if [ ! -f "$COLORS" ]; then
    echo "📄 Membuat colors.xml ..."
    cat > "$COLORS" <<EOF
<resources>
    <color name="purple_500">#6200EE</color>
    <color name="purple_700">#3700B3</color>
    <color name="white">#FFFFFF</color>
</resources>
EOF
fi

# --- 3. Fix AndroidManifest.xml Theme ---
if grep -q "android:theme=" "$MANIFEST"; then
    echo "🔧 Set Theme di AndroidManifest.xml"
    sed -i 's/android:theme="[^"]*"/android:theme="@style\/Theme.CyberSecurityApp"/' "$MANIFEST"
else
    echo "➕ Tambah theme ke AndroidManifest.xml"
    sed -i '/<application /a\        android:theme="@style/Theme.CyberSecurityApp"' "$MANIFEST"
fi

# --- 4. Fix build.gradle (JVM target) ---
if grep -q "JavaVersion.VERSION_1_8" "$APP_GRADLE"; then
    echo "🔧 Ganti JavaVersion ke 17"
    sed -i 's/JavaVersion.VERSION_1_8/JavaVersion.VERSION_17/g' "$APP_GRADLE"
fi

if ! grep -q 'jvmTarget = "17"' "$APP_GRADLE"; then
    echo "➕ Tambah kotlinOptions.jvmTarget = \"17\""
    sed -i '/kotlinOptions {/a\        jvmTarget = "17"' "$APP_GRADLE"
fi

# --- 5. Commit & Push ---
git add "$STYLES" "$COLORS" "$MANIFEST" "$APP_GRADLE"
git commit -m "fix: Theme.CyberSecurityApp + JVM target 17"
git push origin main

echo "✅ Semua fix selesai, silakan cek build CI ulang!"
