package com.zephyrushq.capidock

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    private var sftpDocuments: SftpDocuments? = null
    private var backupDocuments: BackupDocuments? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sftpDocuments = SftpDocuments(this, flutterEngine.dartExecutor.binaryMessenger)
        backupDocuments = BackupDocuments(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        sftpDocuments?.dispose()
        sftpDocuments = null
        backupDocuments?.dispose()
        backupDocuments = null
        super.onDestroy()
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            window.setHideOverlayWindows(true)
        }
    }
}
