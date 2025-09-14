# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Preserve line number information for debugging stack traces.
-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules - CRITICAL for Flutter apps with obfuscation
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter engine - ESSENTIAL
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# Keep MainActivity and application classes - CRITICAL
-keep class com.rmac.multitimer.MainActivity { *; }
-keep class com.rmac.multitimer.** { *; }

# Keep all native methods - ESSENTIAL for JNI
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep reflection-based classes - IMPORTANT for Flutter
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep shared preferences and file storage (your app uses these)
-keep class androidx.preference.** { *; }
-keep class android.content.SharedPreferences** { *; }
-dontwarn android.content.SharedPreferences**

# Keep path provider classes (your app uses path_provider)
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class androidx.core.content.FileProvider { *; }

# Keep timer and provider classes (your app uses these)
-keep class com.flutter.plugins.** { *; }
-keep class provider.** { *; }

# Keep shared_preferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Google Play Core library (deferred components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep Dart/Flutter generated classes
-keep class **.FlutterMain { *; }
-keep class **.MainActivity { *; }

# System UI and orientation classes (your app locks orientation)
-keep class android.view.** { *; }
-keep class androidx.** { *; }

# Keep plugin classes that might be accessed via reflection
-keep class * extends io.flutter.plugin.common.PluginRegistry$Registrar { *; }
-keep class * extends io.flutter.plugin.common.BinaryMessenger { *; }

# Keep method channels
-keep class io.flutter.plugin.common.** { *; }

# Prevent optimization that might cause Flutter issues
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Don't warn about missing classes that are not part of the app
-dontwarn java.lang.invoke.StringConcatFactory
