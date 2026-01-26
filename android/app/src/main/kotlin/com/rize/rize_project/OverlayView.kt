package com.rize.rize_project

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.util.Log
import android.view.View
import androidx.core.content.ContextCompat
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import kotlin.math.max
import kotlin.math.min

class OverlayView(context: Context?, attrs: AttributeSet? = null) :
    View(context, attrs) {

    private var results: PoseLandmarkerResult? = null
    private var pointPaint = Paint()
    private var linePaint = Paint()

    private var scaleFactor: Float = 1f
    private var imageWidth: Int = 1
    private var imageHeight: Int = 1
    private var offsetX: Float = 0f
    private var offsetY: Float = 0f

    init {
        initPaints()
    }

    fun clear() {
        results = null
        pointPaint.reset()
        linePaint.reset()
        invalidate()
        initPaints()
    }

    private fun initPaints() {
        linePaint.color = Color.RED
        linePaint.strokeWidth = LANDMARK_STROKE_WIDTH
        linePaint.style = Paint.Style.STROKE

        pointPaint.color = Color.YELLOW
        pointPaint.strokeWidth = LANDMARK_STROKE_WIDTH * 3  // Triplicar tamaño para mejor visibilidad
        pointPaint.style = Paint.Style.FILL

        Log.d("OverlayView", "Paints inicializados - linePaint: RED, pointPaint: YELLOW")
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        if (results == null) {
            return
        }

        // Log solo cada 10 frames para no saturar logcat
        if ((System.currentTimeMillis() / 100) % 10 == 0L) {
            Log.d("OverlayView", "✓ Redibujando - scaleFactor: $scaleFactor, canvas: ${width}x${height}")
        }

        results?.let { poseLandmarkerResult ->
            for(landmark in poseLandmarkerResult.landmarks()) {
                for((index, normalizedLandmark) in landmark.withIndex()) {
                    val x = normalizedLandmark.x() * imageWidth * scaleFactor + offsetX
                    val y = normalizedLandmark.y() * imageHeight * scaleFactor + offsetY

                    canvas.drawPoint(x, y, pointPaint)
                }

                PoseLandmarker.POSE_LANDMARKS.forEach {
                    canvas.drawLine(
                        poseLandmarkerResult.landmarks().get(0).get(it!!.start()).x() * imageWidth * scaleFactor + offsetX,
                        poseLandmarkerResult.landmarks().get(0).get(it.start()).y() * imageHeight * scaleFactor + offsetY,
                        poseLandmarkerResult.landmarks().get(0).get(it.end()).x() * imageWidth * scaleFactor + offsetX,
                        poseLandmarkerResult.landmarks().get(0).get(it.end()).y() * imageHeight * scaleFactor + offsetY,
                        linePaint)
                }
            }
        }
    }

    fun setResults(
        poseLandmarkerResults: PoseLandmarkerResult,
        imageHeight: Int,
        imageWidth: Int,
        runningMode: RunningMode = RunningMode.LIVE_STREAM
    ) {
        results = poseLandmarkerResults

        this.imageHeight = imageHeight
        this.imageWidth = imageWidth

        // Calcular scaleFactor y offsets según el modo
        when (runningMode) {
            RunningMode.IMAGE,
            RunningMode.VIDEO -> {
                // Para VIDEO: el overlay tiene el MISMO tamaño que el video visible
                // Por lo tanto, NO necesitamos calcular offsets, solo escalar directamente
                scaleFactor = width.toFloat() / imageWidth.toFloat()
                offsetX = 0f
                offsetY = 0f

                Log.d("OverlayView", "VIDEO mode - Direct scale: $scaleFactor, overlay: ${width}x${height}, image: ${imageWidth}x${imageHeight}")
            }
            RunningMode.LIVE_STREAM -> {
                // Para LIVE_STREAM usar max (comportamiento original)
                scaleFactor = max(width * 1f / imageWidth, height * 1f / imageHeight)
                offsetX = 0f
                offsetY = 0f
            }
        }
        invalidate()
    }

    companion object {
        private const val LANDMARK_STROKE_WIDTH = 8F
    }
}
