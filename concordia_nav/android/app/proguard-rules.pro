#Flutter Wrapper
# -keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
# -keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# You might not be using firebase
# -keep class com.google.firebase.** { *; }
-keep class com.builttoroam.devicecalendar.** { *; }

# R8 Warning Suppression
# -dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
# -dontwarn com.google.android.play.core.splitinstall.SplitInstallException
# -dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
# -dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
# -dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
# -dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
# -dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
# -dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
# -dontwarn com.google.android.play.core.tasks.OnFailureListener
# -dontwarn com.google.android.play.core.tasks.OnSuccessListener
# -dontwarn com.google.android.play.core.tasks.Task