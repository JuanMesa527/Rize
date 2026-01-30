package com.rize.rize_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val cameraFactory = CameraViewFactory(this)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("camera_view", cameraFactory)

        // Register EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.rize.rize/pose_data")
            .setStreamHandler(PoseDataManager)

        // MethodChannel para control de cámara
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.rize.rize/camera_control")
            .setMethodCallHandler { call, result ->
                if (call.method == "switchCamera") {
                    try {
                        cameraFactory.switchCamera()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("CAMERA_ERROR", "Error switching camera: ${e.message}", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
