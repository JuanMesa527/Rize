package com.rize.rize_project

import io.flutter.plugin.common.EventChannel

object PoseDataManager : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendPoseData(data: List<Double>) {
        // Must be run on main thread
        // We can ensure this or use Handler(Looper.getMainLooper()).post { ... }
        // But EventChannel usually handles this if called from main thread.
        // If called from background, we need to switch.
        // Assuming we will switch to main thread before calling this or inside this.
        val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())
        mainHandler.post {
            eventSink?.success(data)
        }
    }
}
