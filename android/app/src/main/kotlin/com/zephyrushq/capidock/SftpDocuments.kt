package com.zephyrushq.capidock

import android.app.Activity
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

/** User-selected SAF documents only. No broad storage permission or temporary
 * plaintext files. Payloads are bounded and never stored in the app vault. */
class SftpDocuments(activity: FlutterFragmentActivity, messenger: BinaryMessenger) {
    private val maxBytes = 16 * 1024 * 1024
    private var pending: MethodChannel.Result? = null
    private var output: ByteArray? = null
    private val worker = Executors.newSingleThreadExecutor()
    private val channel = MethodChannel(messenger, "com.zephyrushq.capidock/sftp-documents")
    private val launcher = activity.registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { response ->
        val result = pending ?: return@registerForActivityResult
        val bytes = output
        output = null
        val uri = response.data?.data
        if (response.resultCode != Activity.RESULT_OK || uri == null) {
            pending = null
            bytes?.fill(0)
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
                            val name = activity.contentResolver.query(uri, arrayOf(android.provider.OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
                                if (cursor.moveToFirst()) cursor.getString(0) else null
                            } ?: "upload.bin"
                            mapOf("name" to name, "bytes" to data.toByteArray())
                        } ?: throw IllegalStateException()
                    }
                    activity.runOnUiThread {
                        if (pending !== result) return@runOnUiThread
                        pending = null
                        result.success(value)
                        bytes?.fill(0)
                    }
                } catch (_: Exception) {
                    activity.runOnUiThread {
                        if (pending !== result) return@runOnUiThread
                        pending = null
                        bytes?.fill(0)
                        result.error("sftpLocalFailed", "Unable to access document", null)
                    }
                }
            }
        }
    }

    init {
        channel.setMethodCallHandler { call, result ->
            if (pending != null) {
                result.error("sftpBusy", "A document operation is already active", null)
            } else if (call.method == "readDocument" || call.method == "writeDocument") {
                val writing = call.method == "writeDocument"
                val bytes = if (writing) call.argument<ByteArray>("bytes") else null
                if (writing && (bytes == null || bytes.isEmpty() || bytes.size > maxBytes)) {
                    result.error("sftpTooLarge", "Invalid document size", null)
                } else {
                    pending = result
                    output = bytes
                    val intent = Intent(if (writing) Intent.ACTION_CREATE_DOCUMENT else Intent.ACTION_OPEN_DOCUMENT)
                        .addCategory(Intent.CATEGORY_OPENABLE)
                        .setType("application/octet-stream")
                    if (writing) intent.putExtra(Intent.EXTRA_TITLE, call.argument<String>("name") ?: "download.bin")
                    // Imports may be labelled with a generic MIME type by file providers.
                    if (!writing) intent.type = "*/*"
                    try {
                        launcher.launch(intent)
                    } catch (_: Exception) {
                        pending = null
                        output = null
                        bytes?.fill(0)
                        result.error("sftpLocalFailed", "Unable to open document picker", null)
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
        output?.fill(0)
        output = null
        pending?.success(null)
        pending = null
    }
}
