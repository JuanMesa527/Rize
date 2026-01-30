import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  static const EventChannel _channel = EventChannel('com.rize.rize/pose_data');
  static const MethodChannel _methodChannel = MethodChannel('com.rize.rize/camera_control');

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
            // Formato esperado: [x, y, z, visibility, x, y, z, visibility, ...]
            final List<dynamic> rawList = event as List<dynamic>;
            _currentLandmarks = rawList.map((e) => (e as num).toDouble()).toList();
            _frameCount++;

            if (_frameCount % 10 == 0) {
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

  Future<void> _switchCamera() async {
    try {
      await _methodChannel.invokeMethod('switchCamera');
      debugPrint('Solicitud de cambio de cámara enviada.');
    } on PlatformException catch (e) {
      debugPrint("Error al cambiar de cámara: '${e.message}'.");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parámetros para la vista nativa
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Atrás
                  BackButton(
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Botón Cambiar Cámara
                  IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 30),
                    onPressed: _switchCamera,
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
