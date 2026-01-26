import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  bool _showSelection = true;
  String? _selectedVideoPath;

  @override
  Widget build(BuildContext context) {
    if (_showSelection) {
      return _buildSelectionScreen();
    } else if (_selectedVideoPath != null) {
      return _VideoProcessorScreen(videoPath: _selectedVideoPath!);
    } else {
      return _LiveCameraScreen();
    }
  }

  Widget _buildSelectionScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detección de Pose'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black87,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.accessibility_new,
                  size: 100,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Elige una opción',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Selecciona cómo quieres detectar la pose',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // Botón Cámara en Vivo
                _buildOptionCard(
                  icon: Icons.videocam,
                  title: 'Cámara en Vivo',
                  description: 'Usa la cámara en tiempo real',
                  gradientColors: const [Color(0xFFFFB300), Color(0xFFFF4081)],
                  onTap: () {
                    setState(() {
                      _showSelection = false;
                      _selectedVideoPath = null;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Botón Subir Video
                _buildOptionCard(
                  icon: Icons.video_library,
                  title: 'Subir Video',
                  description: 'Analiza un video desde tu dispositivo',
                  gradientColors: const [Color(0xFF4CAF50), Color(0xFF00BCD4)],
                  onTap: () async {
                    await _pickVideo();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedVideoPath = result.files.single.path;
          _showSelection = false;
        });
      }
    } catch (e) {
      debugPrint('Error al seleccionar video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Pantalla de cámara en vivo (código existente)
class _LiveCameraScreen extends StatefulWidget {
  const _LiveCameraScreen();

  @override
  State<_LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<_LiveCameraScreen> {
  static const EventChannel _channel = EventChannel('com.rize.rize/pose_data');

  List<double> _currentLandmarks = [];
  StreamSubscription? _subscription;
  int _frameCount = 0;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _subscription = _channel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (mounted) {
          setState(() {
            // Convertimos la lista dinámica a lista de doubles
            final List<dynamic> rawList = event as List<dynamic>;
            _currentLandmarks = rawList.map((e) => (e as num).toDouble()).toList();
            _frameCount++;

            // Debug log cada 30 cuadros para no saturar la consola
            if (_frameCount % 30 == 0) {
              debugPrint("Android -> Flutter: Recibidos ${_currentLandmarks.length} valores.");
            }
          });
        }
      },
      onError: (dynamic error) {
        debugPrint('Error en el stream de poses: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'camera_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return Scaffold(
      body: Stack(
        children: [
          // 1. Vista Nativa (CameraX + MediaPipe)
          SizedBox.expand(
            child: Platform.isAndroid
                ? AndroidView(
                    viewType: viewType,
                    layoutDirection: TextDirection.ltr,
                    creationParams: creationParams,
                    creationParamsCodec: const StandardMessageCodec(),
                    onPlatformViewCreated: (id) {
                      debugPrint('Vista nativa Android creada con ID: $id');
                    },
                  )
                : const Center(
                    child: Text("Esta función solo está disponible en Android por ahora"),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BackButton(
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla de procesamiento de video
class _VideoProcessorScreen extends StatefulWidget {
  final String videoPath;

  const _VideoProcessorScreen({required this.videoPath});

  @override
  State<_VideoProcessorScreen> createState() => _VideoProcessorScreenState();
}

class _VideoProcessorScreenState extends State<_VideoProcessorScreen> {
  static const EventChannel _channel = EventChannel('com.rize.rize/pose_data');
  static const MethodChannel _methodChannel = MethodChannel('com.rize.rize/video_processor');

  List<double> _currentLandmarks = [];
  StreamSubscription? _subscription;
  int _frameCount = 0;
  bool _isProcessing = false;
  bool _processingComplete = false;

  @override
  void initState() {
    super.initState();
    _startListening();
    _startVideoProcessing();
  }

  void _startListening() {
    _subscription = _channel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (mounted) {
          setState(() {
            final List<dynamic> rawList = event as List<dynamic>;
            _currentLandmarks = rawList.map((e) => (e as num).toDouble()).toList();
            _frameCount++;

            if (_frameCount % 30 == 0) {
              debugPrint("Video Frame -> Flutter: Recibidos ${_currentLandmarks.length} valores.");
            }
          });
        }
      },
      onError: (dynamic error) {
        debugPrint('Error en el stream de poses del video: $error');
      },
    );
  }

  Future<void> _startVideoProcessing() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      debugPrint('Iniciando procesamiento de video: ${widget.videoPath}');
      final result = await _methodChannel.invokeMethod('processVideo', {
        'videoPath': widget.videoPath,
      });

      debugPrint('Resultado del procesamiento: $result');

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingComplete = true;
        });
      }
    } catch (e) {
      debugPrint('Error al procesar video: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'video_view';
    final Map<String, dynamic> creationParams = {
      'videoPath': widget.videoPath,
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vista nativa del video con overlay de pose
          SizedBox.expand(
            child: Platform.isAndroid
                ? AndroidView(
                    viewType: viewType,
                    layoutDirection: TextDirection.ltr,
                    creationParams: creationParams,
                    creationParamsCodec: const StandardMessageCodec(),
                    onPlatformViewCreated: (id) {
                      debugPrint('Vista de video nativa creada con ID: $id');
                    },
                  )
                : const Center(
                    child: Text(
                      "Esta función solo está disponible en Android",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),

          // Indicador de procesamiento
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Procesando video...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Botones de control
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      BackButton(
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Frames: $_frameCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

