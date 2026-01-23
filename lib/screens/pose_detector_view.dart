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
  // El canal debe coincidir exactamente con el nombre definido en MainActivity.kt
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
            // Formato esperado: [x, y, z, visibility, x, y, z, visibility, ...]
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

          // 2. Capa de Dibujo (Landmarks)
          // ELIMINADO: El dibujado ahora es nativo en Android (OverlayView) para mayor eficiencia y sincronización.

          // 3. Botón para volver
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
