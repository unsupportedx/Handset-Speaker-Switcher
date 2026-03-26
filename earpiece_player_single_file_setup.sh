#!/usr/bin/env bash
# This script generates a complete Android project that plays audio through the earpiece.
# Usage: bash setup_earpiece_project.sh

set -e

PROJECT=EarpiecePlayer
mkdir -p $PROJECT/app/src/main/java/com/earpiece/player
mkdir -p $PROJECT/app/src/main/res/layout
mkdir -p $PROJECT/.github/workflows

cat > $PROJECT/settings.gradle <<'EOF'
rootProject.name = "EarpiecePlayer"
include ':app'
EOF

cat > $PROJECT/build.gradle <<'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

cat > $PROJECT/app/build.gradle <<'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.earpiece.player'
    compileSdk 34

    defaultConfig {
        applicationId "com.earpiece.player"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
EOF

cat > $PROJECT/app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.earpiece.player">

    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>

    <application
        android:label="Earpiece Player"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">

        <activity android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF

cat > $PROJECT/app/src/main/java/com/earpiece/player/MainActivity.kt <<'EOF'
package com.earpiece.player

import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Bundle
import android.provider.Settings
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    private var player: MediaPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val btn = Button(this)
        btn.text = "Ahizeden Ses Testi"
        setContentView(btn)

        val audio = getSystemService(AUDIO_SERVICE) as AudioManager
        audio.mode = AudioManager.MODE_IN_CALL
        audio.isSpeakerphoneOn = false

        btn.setOnClickListener {
            player?.release()
            player = MediaPlayer.create(
                this,
                Settings.System.DEFAULT_RINGTONE_URI
            )
            player?.setAudioStreamType(AudioManager.STREAM_VOICE_CALL)
            player?.start()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        player?.release()
    }
}
EOF

cat > $PROJECT/.github/workflows/build.yml <<'EOF'
name: Build APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17

      - uses: gradle/gradle-build-action@v2

      - run: ./gradlew assembleDebug

      - uses: actions/upload-artifact@v4
        with:
          name: app-debug
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

echo "Project created in $PROJECT/"
echo "Next steps:"
echo "1. cd $PROJECT"
echo "2. git init && git add . && git commit -m 'init'"
echo "3. push to GitHub to build APK automatically"
