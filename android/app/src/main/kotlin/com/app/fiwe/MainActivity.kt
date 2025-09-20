package com.app.fiwe

import io.flutter.embedding.android.FlutterActivity
import android.content.res.Configuration
import android.os.Build
import live.hms.hmssdk_flutter.methods.HMSPipAction
import live.hms.hmssdk_flutter.Constants

class MainActivity : FlutterActivity(){
  override fun onUserLeaveHint() {
    super.onUserLeaveHint()
    // This should only work for android version above 8 since PIP is only supported after
    // android 8 and will not be called after android 12 since it automatically gets handled by android.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
        HMSPipAction.autoEnterPipMode(this)
    }
  }
}
