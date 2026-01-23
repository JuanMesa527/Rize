package com.rize.rize_project

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

import androidx.lifecycle.LifecycleOwner

class CameraViewFactory(private val lifecycleOwner: LifecycleOwner) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return CameraView(context, lifecycleOwner, viewId, creationParams)
    }
}
