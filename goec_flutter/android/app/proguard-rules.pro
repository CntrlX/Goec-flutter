# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep Razorpay classes - prevents R8 from removing required classes
-keep class com.razorpay.** { *; }
-keepattributes *Annotation*

# Keep ProGuard annotation classes that Razorpay depends on
-dontwarn proguard.annotation.**
-keep class proguard.annotation.** { *; }

# Keep analytics and payment related classes
-keep class com.razorpay.AnalyticsEvent { *; }
-keepclassmembers class com.razorpay.** {
    public *;
}

# General rules for reflection-based libraries
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep Flutter and Dart related classes
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }

# Firebase related rules (if using Firebase)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.** 

-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.Wallet
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task