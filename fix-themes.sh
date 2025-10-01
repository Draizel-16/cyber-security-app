#!/bin/bash
set -e

echo "🎨 Membuat themes.xml dan colors.xml ..."

# Pastikan folder ada
mkdir -p app/src/main/res/values

# Buat themes.xml
cat > app/src/main/res/values/themes.xml <<'EOF'
<resources xmlns:tools="http://schemas.android.com/tools">

    <!-- Base theme untuk aplikasi -->
    <style name="Theme.CyberSecurityApp" parent="Theme.Material3.DayNight.NoActionBar">
        <!-- Warna utama -->
        <item name="colorPrimary">@color/purple_500</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="colorSecondary">@color/teal_200</item>
    </style>

</resources>
EOF

# Buat colors.xml
cat > app/src/main/res/values/colors.xml <<'EOF'
<resources>
    <color name="purple_500">#6200EE</color>
    <color name="purple_700">#3700B3</color>
    <color name="teal_200">#03DAC5</color>
    <color name="white">#FFFFFF</color>
</resources>
EOF

echo "✅ themes.xml & colors.xml sudah dibuat."

# Commit & push
git add app/src/main/res/values/themes.xml app/src/main/res/values/colors.xml
git commit -m "fix: add themes and colors for Theme.CyberSecurityApp"
git push origin main

echo "🚀 Fix selesai, silakan cek build CI lagi."
