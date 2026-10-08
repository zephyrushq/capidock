package com.zephyrushq.capidock.monitor

import android.Manifest
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.Semaphore
import java.util.concurrent.TimeUnit

/** No credentials, endpoints or response bodies cross this channel. Notifications
 * are local, generic and private; the normal locked app is their only destination. */
class MonitorBridge : FlutterPlugin, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    companion object {
        // All engines share this in-process bus. No events are retained or replayed.
        private val sinks = mutableSetOf<EventChannel.EventSink>()
        private val alertKinds = setOf("down", "recovery", "authentication", "identity", "unknown", "deployment", "deploymentStarted", "deploymentSucceeded", "deploymentCancelled", "resource", "resourceChanged")
        private fun broadcast(kind: String) { for (sink in sinks.toList()) sink.success(kind) }
        private val gate = Semaphore(1, true)
        private const val CHANNEL = "capidock_health_v1"
        private const val REQUEST = 7047
    }
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private lateinit var events: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private val main = Handler(Looper.getMainLooper())
    private val worker = Executors.newSingleThreadExecutor()
    private var activity: ActivityPluginBinding? = null
    private var permissionResult: MethodChannel.Result? = null
    private var token: String? = null
    private var attached = false
    private var acquiring = false
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        attached = true
        events = EventChannel(binding.binaryMessenger, "com.zephyrushq.capidock/monitor/events")
        events.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                eventSink?.let { sinks.remove(it) }; eventSink = sink; sinks.add(sink)
            }
            override fun onCancel(arguments: Any?) { eventSink?.let { sinks.remove(it) }; eventSink = null }
        })
        channel = MethodChannel(binding.binaryMessenger, "com.zephyrushq.capidock/monitor")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "acquire" -> {
                    if (token != null || acquiring) { result.error("monitorBusy", "Transaction already active", null) }
                    else { acquiring = true; worker.execute {
                        val acquired = try { gate.tryAcquire(10, TimeUnit.SECONDS) } catch (_: InterruptedException) { false }
                        main.post {
                            acquiring = false
                            if (!attached) { if (acquired) gate.release() }
                            else if (!acquired) result.error("monitorBusy", "Transaction timeout", null)
                            else { token = UUID.randomUUID().toString(); result.success(token) }
                        }
                    } }
                }
                "release" -> {
                    if (token != null && call.argument<String>("token") == token) {
                        token = null; gate.release(); result.success(null)
                    } else result.error("monitorToken", "Invalid transaction owner", null)
                }
                "network" -> {
                    val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                    result.success(cm.activeNetwork != null && cm.getNetworkCapabilities(cm.activeNetwork) != null)
                }
                "permission" -> result.success(allowed())
                "requestPermission" -> {
                    val current = activity?.activity
                    if (allowed()) result.success(true)
                    else if (Build.VERSION.SDK_INT < 33 || current == null) result.success(false)
                    else if (permissionResult != null) result.error("monitorBusy", "Permission request active", null)
                    else { permissionResult = result; current.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST) }
                }
                "eventsAvailable" -> result.success(true)
                "event" -> {
                    val kind = call.argument<String>("kind")
                    if (kind == null || kind !in alertKinds) result.error("monitorInvalid", "Invalid event", null)
                    else { broadcast(kind); result.success(null) }
                }
                "notify" -> {
                    val id = call.argument<Int>("id")
                    val body = call.argument<String>("body")
                    if (id == null || body == null || body.length > 240) result.error("monitorInvalid", "Invalid notification", null)
                    else {
                        if (allowed()) {
                            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                            if (Build.VERSION.SDK_INT >= 26) manager.createNotificationChannel(NotificationChannel(CHANNEL, "Capidock", NotificationManager.IMPORTANCE_DEFAULT))
                            val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(context, CHANNEL) else Notification.Builder(context)
                            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                            if (intent != null) builder.setContentIntent(PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
                            manager.notify(id, builder.setSmallIcon(R.drawable.capidock_monitor_icon)
                                .setContentTitle("Capidock").setContentText(body).setAutoCancel(true)
                                .setVisibility(Notification.VISIBILITY_PRIVATE).setOnlyAlertOnce(true).build())
                        }
                        result.success(null)
                    }
                }
                "clear" -> {
                    broadcast("clear")
                    val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    val id = call.argument<Int>("id")
                    if (id == null) manager.cancelAll() else manager.cancel(id)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    private fun allowed(): Boolean {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelEnabled = Build.VERSION.SDK_INT < 26 || manager.getNotificationChannel(CHANNEL)?.importance != NotificationManager.IMPORTANCE_NONE
        return channelEnabled && manager.areNotificationsEnabled() && (Build.VERSION.SDK_INT < 33 || context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED)
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST) return false
        permissionResult?.success(allowed()); permissionResult = null; return true
    }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding; binding.addRequestPermissionsResultListener(this) }
    override fun onDetachedFromActivityForConfigChanges() { detachActivity() }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { onAttachedToActivity(binding) }
    override fun onDetachedFromActivity() { detachActivity(); permissionResult?.success(false); permissionResult = null }
    private fun detachActivity() { activity?.removeRequestPermissionsResultListener(this); activity = null }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventSink?.let { sinks.remove(it) }; eventSink = null; events.setStreamHandler(null)
        attached = false; channel.setMethodCallHandler(null); worker.shutdownNow()
        if (token != null) { token = null; gate.release() }
        permissionResult?.success(false); permissionResult = null
    }
}
