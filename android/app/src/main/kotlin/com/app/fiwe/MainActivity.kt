package com.app.fiwe

import io.flutter.embedding.android.FlutterActivity
import android.content.res.Configuration
import android.os.Build
import live.hms.hmssdk_flutter.methods.HMSPipAction
import live.hms.hmssdk_flutter.Constants
import android.app.PictureInPictureParams
import android.util.Rational
import android.content.Intent
import android.util.Log

class MainActivity : FlutterActivity(){
  private val TAG = "MainActivity"
  
  override fun onUserLeaveHint() {
    super.onUserLeaveHint()
    Log.d(TAG, "onUserLeaveHint called - attempting PIP mode")
    
    // This should only work for android version above 8 since PIP is only supported after
    // android 8 and will not be called after android 12 since it automatically gets handled by android.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
        Log.d(TAG, "Attempting to enter PIP mode via HMS for Android 8-11")
        try {
            val result = HMSPipAction.autoEnterPipMode(this)
            Log.d(TAG, "HMS PIP activation result: $result")
        } catch (e: Exception) {
            Log.e(TAG, "Error entering PIP mode: ${e.message}")
        }
    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        Log.d(TAG, "Android 12+ detected, system will handle PIP automatically")
        // For Android 12+, the system handles PIP automatically
        // We just need to ensure our activity supports it
    } else {
        Log.d(TAG, "PIP not supported on this Android version (< API 26)")
    }
  }
  
  override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
    super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
    Log.d(TAG, "PIP mode changed: $isInPictureInPictureMode")
    
    // Notify Flutter about PIP state change
    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
      val channel = io.flutter.plugin.common.MethodChannel(messenger, "fiwe.pip/status")
      channel.invokeMethod("onPipModeChanged", mapOf("isInPip" to isInPictureInPictureMode))
    }
  }
  
  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    Log.d(TAG, "onNewIntent called")
    
    // Handle returning from notification
    if (intent.getBooleanExtra("from_notification", false)) {
      Log.d(TAG, "Returning from notification")
      // Bring app to foreground and exit PIP if needed
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && isInPictureInPictureMode) {
        // Exit PIP mode when returning from notification
        moveTaskToBack(false)
      }
    }
  }
}
