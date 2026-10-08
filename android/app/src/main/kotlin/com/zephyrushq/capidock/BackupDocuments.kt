package com.zephyrushq.capidock

import android.app.Activity
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

/** SAF accesses only documents explicitly chosen by the user. Payloads are
 * ciphertext, never decrypted workspaces or private keys. No cache files. */
class BackupDocuments(activity: FlutterFragmentActivity, messenger: BinaryMessenger) {
    private val maxBytes = 8 * 1024 * 1024
    private var pending: MethodChannel.Result? = null
    private var output: ByteArray? = null
    private val worker = Executors.newSingleThreadExecutor()
    private val channel = MethodChannel(messenger, "com.zephyrushq.capidock/backups")
    private val launcher = activity.registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { response ->
        val result = pending ?: return@registerForActivityResult
        val bytes = output
        output = null
        val uri = response.data?.data
        if (response.resultCode != Activity.RESULT_OK || uri == null) {
            pending = null
            result.success(null)
        } else {
            worker.execute {
                try {
                    val value: Any = if (bytes != null) {
                        activity.contentResolver.openOutputStream(uri, "wt")?.use { stream ->
                            stream.write(bytes)
                            stream.flush()
                        } ?: throw IllegalStateException()
                        true
                    } else {
                        activity.contentResolver.openInputStream(uri)?.use { stream ->
                            val data = ByteArrayOutputStream()
                            val buffer = ByteArray(8192)
                            var count: Int
                            while (stream.read(buffer).also { count = it } != -1) {
                                if (data.size() + count > maxBytes) throw IllegalArgumentException()
                                data.write(buffer, 0, count)
                            }
                            data.toByteArray()
                        } ?: throw IllegalStateException()
                    }
                    activity.runOnUiThread {
                        if (pending !== result) return@runOnUiThread
                        pending = null
                        result.success(value)
                    }
                } catch (_: Exception) {
                    activity.runOnUiThread {
                        if (pending !== result) return@runOnUiThread
                        pending = null
                        result.error("backupFileFailed", "Unable to access backup document", null)
                    }
                }
            }
        }
    }

    init {
        channel.setMethodCallHandler { call, result ->
            if (pending != null) {
                result.error("backupBusy", "A document operation is already active", null)
            } else if (call.method == "readBackup" || call.method == "writeBackup") {
                val writing = call.method == "writeBackup"
                val bytes = if (writing) call.argument<ByteArray>("bytes") else null
                if (writing && (bytes == null || bytes.isEmpty() || bytes.size > maxBytes)) {
                    result.error("backupInvalid", "Invalid backup size", null)
                } else {
                    pending = result
                    output = bytes
                    val intent = Intent(if (writing) Intent.ACTION_CREATE_DOCUMENT else Intent.ACTION_OPEN_DOCUMENT)
                        .addCategory(Intent.CATEGORY_OPENABLE)
                        .setType("application/octet-stream")
                    if (writing) intent.putExtra(Intent.EXTRA_TITLE, call.argument<String>("name") ?: "capidock.capidock")
                    // Imports may be labelled with a generic MIME type by file providers.
                    if (!writing) intent.type = "*/*"
                    try {
                        launcher.launch(intent)
                    } catch (_: Exception) {
                        pending = null
                        output = null
                        result.error("backupFileFailed", "Unable to open document picker", null)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        launcher.unregister()
        worker.shutdownNow()
        output = null
        pending?.success(null)
        pending = null
    }
}
