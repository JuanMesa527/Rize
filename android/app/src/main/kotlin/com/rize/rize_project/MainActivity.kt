package com.rize.rize_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val VIDEO_PROCESSOR_CHANNEL = "com.rize.rize/video_processor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Registrar CameraView para streaming en vivo
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("camera_view", CameraViewFactory(this))

        // Registrar VideoView para procesamiento de videos
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("video_view", VideoViewFactory())

        // EventChannel para transmitir datos de pose
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.rize.rize/pose_data")
            .setStreamHandler(PoseDataManager)

        // MethodChannel para procesamiento de videos
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIDEO_PROCESSOR_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "processVideo" -> {
                    val videoPath = call.argument<String>("videoPath")
                    if (videoPath != null) {
                        result.success("Video processing started: $videoPath")
                    } else {
                        result.error("INVALID_ARGUMENT", "Video path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
