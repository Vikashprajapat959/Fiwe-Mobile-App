# --- Flutter & Firebase Keep Rules ---
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# --- Play Core (Dynamic Features / Deferred Components) ---
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# --- General ---
-keepattributes Signature
-keepattributes *Annotation*
