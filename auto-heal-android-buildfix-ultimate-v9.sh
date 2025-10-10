#!/bin/bash
echo "🚀 Auto-Heal Android BuildFix Ultimate v9 — Infinite Retry Mode (🔥)"
echo "==================================================================="

# Pastikan dijalankan di root proyek
if [ ! -f "settings.gradle" ]; then
  echo "❌ Jalankan script ini dari root project Android!"
  exit 1
fi

# Backup konfigurasi utama
echo "📦 Backup konfigurasi lama..."
mkdir -p backup_autoheal_v9
cp -r app build.gradle* settings.gradle gradle.properties gradle .github backup_autoheal_v9/ 2>/dev/null

# Perbarui Gradle Wrapper ke versi stabil
echo "🧱 Update Gradle Wrapper ke versi 8.9..."
mkdir -p gradle/wrapper
cat > gradle/wrapper/gradle-wrapper.properties <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# Gradle properties
cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx4g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOF

# settings.gradle
cat > settings.gradle <<'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "CyberSecurityApp"
include(":app")
EOF

# Root build.gradle
cat > build.gradle <<'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:8.5.2"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.25"
        classpath "com.google.gms:google-services:4.4.2"
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

# app/build.gradle
mkdir -p app
cat > app/build.gradle <<'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'com.google.gms.google-services'
}

android {
    namespace "com.cybersecurity.app"
    compileSdk 34

    defaultConfig {
        applicationId "com.cybersecurity.app"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            shrinkResources false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            minifyEnabled false
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation "androidx.core:core-ktx:1.13.1"
    implementation "androidx.appcompat:appcompat:1.7.0"
    implementation "com.google.android.material:material:1.12.0"
    implementation "com.google.android.gms:play-services-auth:21.2.0"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1"
}
EOF

# Workflow GitHub Actions
mkdir -p .github/workflows
cat > .github/workflows/android-release.yml <<'EOF'
name: Android Release

on:
  workflow_dispatch:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: 17

      - name: Create local.properties
        run: echo "sdk.dir=$ANDROID_HOME" > local.properties

      - name: Grant execute permission for gradlew
        run: chmod +x gradlew

      - name: Build Release APK
        run: ./gradlew clean assembleRelease --stacktrace

      - name: Upload Release Artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: app/build/outputs/apk/release/app-release.apk
EOF

# Commit & push
echo "📤 Commit & push perubahan..."
git add .
git commit -m "auto-heal: ultimate v9 (infinite retry mode)" || echo "ℹ️ Tidak ada perubahan baru"
git push

# Fungsi trigger workflow
trigger_workflow() {
  echo "⚡ Menjalankan workflow Android Release..."
  gh workflow run android-release.yml || echo "⚠️ Gagal trigger otomatis, coba manual via tab Actions."
  sleep 25

  RUN_ID=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId -q '.[0].databaseId')
  STATUS=$(gh run view "$RUN_ID" --json conclusion -q '.conclusion')
  echo "ℹ️ Status workflow: $STATUS"

  if [ "$STATUS" = "failure" ]; then
    echo "❌ Build gagal — mendownload log..."
    mkdir -p logs
    gh run download "$RUN_ID" --dir logs
    tail -n 40 logs/*/step*.txt 2>/dev/null || echo "⚠️ Log tidak ditemukan."
    return 1
  elif [ "$STATUS" = "success" ]; then
    echo "✅ Build berhasil!"
    return 0
  else
    echo "⏳ Status belum jelas — menunggu lagi..."
    return 2
  fi
}

# Loop tanpa batas
COUNT=1
while true; do
  echo "🔁 Percobaan build ke-$COUNT..."
  trigger_workflow
  RESULT=$?
  if [ $RESULT -eq 0 ]; then
    echo "🎉 Build sukses setelah $COUNT percobaan!"
    break
  fi
  echo "🕐 Menunggu 45 detik sebelum mencoba ulang..."
  sleep 45
  ((COUNT++))
done

echo "✨ Auto-Heal BuildFix Ultimate v9 selesai dijalankan dengan sukses!"
