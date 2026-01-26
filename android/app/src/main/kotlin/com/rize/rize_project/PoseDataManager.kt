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
        val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())
        mainHandler.post {
            eventSink?.success(data)
        }
    }
}
