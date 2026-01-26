package com.rize.rize_project

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.media.MediaPlayer
import android.util.Log
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup.LayoutParams
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import com.google.mediapipe.tasks.vision.core.RunningMode
import io.flutter.plugin.platform.PlatformView
import java.util.Timer
import java.util.TimerTask
import java.util.concurrent.Executors

class VideoView(
    private val context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?
) : PlatformView, PoseLandmarkerHelper.LandmarkerListener {

    private val frameLayout: FrameLayout = FrameLayout(context)
    private val surfaceView: SurfaceView = SurfaceView(context)
    private val overlayView: OverlayView = OverlayView(context)

    private var mediaPlayer: MediaPlayer? = null
    private var retriever: MediaMetadataRetriever? = null
    private var timer: Timer? = null

    private var videoDisplayWidth: Int = 0
    private var videoDisplayHeight: Int = 0

    private lateinit var poseLandmarkerHelper: PoseLandmarkerHelper
    private val backgroundExecutor = Executors.newSingleThreadExecutor()
    private val frameProcessorExecutor = Executors.newFixedThreadPool(2) // Pool para procesar frames en paralelo

    private var videoPath: String? = null
    private var isProcessing = false // Flag para evitar sobrecarga

    init {
        frameLayout.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        frameLayout.setBackgroundColor(android.graphics.Color.BLACK)

        // SurfaceView para video (mantiene aspect ratio)
        surfaceView.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)

        overlayView.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)

        frameLayout.addView(surfaceView)
        frameLayout.addView(overlayView)

        videoPath = creationParams?.get("videoPath") as? String

        Log.d("VideoView", "Inicializando VideoView con path: $videoPath")

        setupMediaPipe()
        setupSurfaceView()
    }

    private fun setupMediaPipe() {
        poseLandmarkerHelper = PoseLandmarkerHelper(
            context = context,
            runningMode = RunningMode.VIDEO, // VIDEO mode es más rápido y simple
            poseLandmarkerHelperListener = this
        )
    }

    private fun setupSurfaceView() {
        surfaceView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                videoPath?.let { path ->
                    startVideoPlayback(path, holder)
                }
            }

            override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {}
            override fun surfaceDestroyed(holder: SurfaceHolder) {
                mediaPlayer?.release()
            }
        })
    }

    private fun startVideoPlayback(videoPath: String, holder: SurfaceHolder) {
        try {
            mediaPlayer = MediaPlayer().apply {
                setDataSource(videoPath)
                setDisplay(holder)
                isLooping = true
                // Usar SCALE_TO_FIT para mantener aspect ratio (no estirar)
                setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT)

                setOnPreparedListener { mp ->
                    // Ajustar tamaño del SurfaceView basado en el video
                    val videoWidth = mp.videoWidth
                    val videoHeight = mp.videoHeight

                    val screenWidth = surfaceView.width
                    val screenHeight = surfaceView.height

                    // Calcular escala para FIT (como FIT_CENTER en ImageView)
                    val scaleX = screenWidth.toFloat() / videoWidth
                    val scaleY = screenHeight.toFloat() / videoHeight
                    val scale = minOf(scaleX, scaleY)

                    val newWidth = (videoWidth * scale).toInt()
                    val newHeight = (videoHeight * scale).toInt()

                    // Guardar dimensiones para el overlay
                    videoDisplayWidth = newWidth
                    videoDisplayHeight = newHeight

                    // Centrar el video
                    val layoutParams = surfaceView.layoutParams as FrameLayout.LayoutParams
                    layoutParams.width = newWidth
                    layoutParams.height = newHeight
                    layoutParams.gravity = android.view.Gravity.CENTER
                    surfaceView.layoutParams = layoutParams

                    // Ajustar overlay al mismo tamaño y posición
                    val overlayParams = overlayView.layoutParams as FrameLayout.LayoutParams
                    overlayParams.width = newWidth
                    overlayParams.height = newHeight
                    overlayParams.gravity = android.view.Gravity.CENTER
                    overlayView.layoutParams = overlayParams

                    mp.start()

                    // Obtener duración del MediaPlayer (más confiable)
                    val videoDuration = mp.duration.toLong()

                    Log.d("VideoView", "Video iniciado: ${videoWidth}x${videoHeight} escalado a ${newWidth}x${newHeight}")
                    Log.d("VideoView", "Overlay ajustado al mismo tamaño: ${newWidth}x${newHeight}")
                    Log.d("VideoView", "Duración del video (MediaPlayer): ${videoDuration}ms")

                    startPoseTracking(videoPath, videoDuration)
                }

                setOnErrorListener { _, what, extra ->
                    Log.e("VideoView", "MediaPlayer error: what=$what, extra=$extra")
                    true
                }

                prepareAsync()
            }
        } catch (e: Exception) {
            Log.e("VideoView", "Error al iniciar video", e)
        }
    }

    private fun startPoseTracking(videoPath: String, videoDuration: Long) {
        backgroundExecutor.execute {
            try {
                retriever = MediaMetadataRetriever()
                retriever?.setDataSource(videoPath)

                val duration = videoDuration
                val width = retriever?.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull() ?: 0
                val height = retriever?.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toIntOrNull() ?: 0

                Log.d("VideoView", "Video tracking info - duración: ${duration}ms, tamaño: ${width}x${height}")

                if (duration == 0L) {
                    Log.e("VideoView", "Duración del video es 0, no se puede iniciar tracking")
                    return@execute
                }

                var frameCount = 0
                var lastSuccessfulPosition = 0L

                Log.d("VideoView", "✓ Iniciando tracking sincronizado en tiempo real...")

                // Timer cada 150ms (~6-7 FPS) - más estable, menos frames NULL
                timer = Timer()
                timer?.scheduleAtFixedRate(object : TimerTask() {
                    override fun run() {
                        try {
                            // Si ya hay un frame procesándose, saltar
                            if (isProcessing) {
                                return
                            }

                            val currentPosition = mediaPlayer?.currentPosition?.toLong() ?: 0L

                            // Solo procesar si el video está reproduciendo y ha avanzado significativamente
                            if (currentPosition > 0 && currentPosition < duration &&
                                (currentPosition - lastSuccessfulPosition) >= 100) {

                                isProcessing = true

                                frameProcessorExecutor.execute {
                                    try {
                                        // Usar OPTION_CLOSEST_SYNC es más confiable (menos NULLs)
                                        val bitmap = retriever?.getFrameAtTime(
                                            currentPosition * 1000,
                                            MediaMetadataRetriever.OPTION_CLOSEST_SYNC
                                        )

                                        if (bitmap != null) {
                                            frameCount++
                                            lastSuccessfulPosition = currentPosition

                                            if (frameCount % 5 == 0) {
                                                Log.d("VideoView", "✓ Frame $frameCount OK - Posición: ${currentPosition}ms")
                                            }

                                            val argbBitmap = if (bitmap.config != Bitmap.Config.ARGB_8888) {
                                                val converted = Bitmap.createBitmap(
                                                    bitmap.width,
                                                    bitmap.height,
                                                    Bitmap.Config.ARGB_8888
                                                )
                                                val canvas = android.graphics.Canvas(converted)
                                                canvas.drawBitmap(bitmap, 0f, 0f, null)
                                                bitmap.recycle()
                                                converted
                                            } else {
                                                bitmap
                                            }

                                            // Usar timestamp del último frame exitoso para evitar errores de orden
                                            poseLandmarkerHelper.detectVideoFrame(
                                                bitmap = argbBitmap,
                                                frameTimestampMs = lastSuccessfulPosition
                                            )

                                            argbBitmap.recycle()
                                        } else {
                                            Log.w("VideoView", "⚠ Frame NULL en ${currentPosition}ms - manteniendo última posición")
                                        }
                                    } catch (e: Exception) {
                                        Log.e("VideoView", "Error procesando frame en ${currentPosition}ms", e)
                                    } finally {
                                        isProcessing = false
                                    }
                                }
                            }
                        } catch (e: Exception) {
                            Log.e("VideoView", "Error en timer", e)
                            isProcessing = false
                        }
                    }
                }, 0, 150) // 6-7 FPS - más estable y confiable

            } catch (e: Exception) {
                Log.e("VideoView", "Error configurando tracking: ${e.message}", e)
            }
        }
    }

    override fun getView(): View = frameLayout

    override fun dispose() {
        timer?.cancel()
        timer = null
        mediaPlayer?.release()
        mediaPlayer = null
        retriever?.release()
        retriever = null
        backgroundExecutor.shutdown()
        frameProcessorExecutor.shutdown()
        poseLandmarkerHelper.clearPoseLandmarker()
    }

    override fun onError(error: String, errorCode: Int) {
        Log.e("VideoView", "MediaPipe Error: $error")
    }

    override fun onResults(resultBundle: PoseLandmarkerHelper.ResultBundle) {
        val results = resultBundle.results
        if (results.isNotEmpty()) {
            val firstResult = results[0]
            val landmarks = firstResult.landmarks()

            if (landmarks.isNotEmpty()) {
                val personLandmarks = landmarks[0]

                // Log para verificar que se reciben landmarks
                if (personLandmarks.isNotEmpty()) {
                    val nose = personLandmarks[0] // Punto de la nariz
                    Log.d("VideoView", "Landmarks recibidos - Nariz: x=${nose.x()}, y=${nose.y()}")
                }

                // Actualizar overlay en el hilo principal
                ContextCompat.getMainExecutor(context).execute {
                    overlayView.setResults(
                        firstResult,
                        resultBundle.inputImageHeight,
                        resultBundle.inputImageWidth,
                        RunningMode.VIDEO  // Usar VIDEO mode
                    )
                    overlayView.invalidate() // Forzar redibujado
                }

                // Enviar datos a Flutter
                val flatList = ArrayList<Double>()
                for (landmark in personLandmarks) {
                    flatList.add(landmark.x().toDouble())
                    flatList.add(landmark.y().toDouble())
                    flatList.add(landmark.z().toDouble())
                    flatList.add(landmark.visibility().orElse(0.0f).toDouble())
                }
                PoseDataManager.sendPoseData(flatList)
            }
        }
    }
}
