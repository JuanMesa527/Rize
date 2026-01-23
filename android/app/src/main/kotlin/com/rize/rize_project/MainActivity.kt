package com.rize.rize_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register CameraView
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("camera_view", CameraViewFactory(this))

        // Register EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.rize.rize/pose_data")
            .setStreamHandler(PoseDataManager)
    }
}
