#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Setup Android SDK di Termux ==="

SDK_DIR="$HOME/Android/Sdk"
TOOLS_ZIP="commandlinetools-linux-10406996_latest.zip"
TOOLS_URL="https://dl.google.com/android/repository/$TOOLS_ZIP"
TOOLS_DIR="$SDK_DIR/cmdline-tools"

# 1. Buat folder SDK
mkdir -p "$SDK_DIR"

# 2. Download command line tools jika belum ada
if [ ! -f "$SDK_DIR/$TOOLS_ZIP" ]; then
    echo "📥 Download Android Command Line Tools..."
    wget -O "$SDK_DIR/$TOOLS_ZIP" "$TOOLS_URL"
fi

# 3. Ekstrak tools
if [ ! -d "$TOOLS_DIR/latest" ]; then
    echo "📦 Ekstrak tools..."
    mkdir -p "$TOOLS_DIR"
    unzip -qo "$SDK_DIR/$TOOLS_ZIP" -d "$TOOLS_DIR"
    mv "$TOOLS_DIR/cmdline-tools" "$TOOLS_DIR/latest"
fi

# 4. Tambah ke PATH sementara
export ANDROID_HOME="$SDK_DIR"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# 5. Install komponen dasar
echo "⚡ Install platform-tools, build-tools, dan platform android-34..."
yes | sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# 6. Buat local.properties di project root
if [ -d "$HOME/cyber-security-app" ]; then
    echo "sdk.dir=$ANDROID_HOME" > "$HOME/cyber-security-app/local.properties"
    echo "✅ local.properties berhasil dibuat di cyber-security-app/"
else
    echo "⚠️ Folder project tidak ditemukan: $HOME/cyber-security-app"
fi

# 7. Update .bashrc agar permanen
BASHRC="$HOME/.bashrc"
if ! grep -q "ANDROID_HOME=$SDK_DIR" "$BASHRC"; then
    echo "🔧 Update .bashrc untuk export ANDROID_HOME & PATH..."
    {
        echo ""
        echo "# Android SDK"
        echo "export ANDROID_HOME=$SDK_DIR"
        echo "export PATH=\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH"
    } >> "$BASHRC"
    echo "✅ .bashrc berhasil diperbarui. Restart Termux atau jalankan: source ~/.bashrc"
else
    echo "ℹ️ PATH SDK sudah ada di .bashrc"
fi

echo "🎉 Android SDK setup selesai!"
