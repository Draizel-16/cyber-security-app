#!/usr/bin/env sh
# Minimal, robust Gradle wrapper launcher
set -e

# Find Java
if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVA="$JAVA_HOME/bin/java"
else
  JAVA=java
fi

# Resolve script dir
DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

# wrapper jar path (relative to project root)
JAR="$DIR/gradle/wrapper/gradle-wrapper.jar"

if [ ! -f "$JAR" ]; then
  echo "ERROR: gradle-wrapper.jar not found at $JAR"
  echo "Please ensure gradle-wrapper.jar exists in gradle/wrapper/"
  exit 1
fi

exec "$JAVA" -cp "$JAR" org.gradle.wrapper.GradleWrapperMain "$@"
