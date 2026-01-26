// dart
// Archivo: lib/screens/pose_detector_view.dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> with WidgetsBindingObserver {
  static const EventChannel _channel = EventChannel('com.rize.rize/pose_data');

  // Usar ValueNotifier para evitar setState constante
  final ValueNotifier<List<double>> landmarksNotifier = ValueNotifier<List<double>>(<double>[]);

  StreamSubscription? _subscription;
  Timer? _throttleTimer;
  List<double>? _latestRaw;
  List<double>? _smoothed; // última versión suavizada
  int _frameCount = 0;

  // Ajustar según target fps (ej. 16ms => ~60 FPS si el HW lo permite)
  final Duration _throttleDuration = const Duration(milliseconds: 16);

  // Suavizado exponencial (0..1). Más alto => respuesta más rápida, menos suavizado.
  final double _smoothingAlpha = 0.6;

  // Umbral mínimo para actualizar la UI (en unidades de landmarks). Ajustar según escala (0..1 o pixeles)
  final double _movementThreshold = 0.005;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) _startListening();
  }

  void _startListening() {
    _subscription = _channel.receiveBroadcastStream().listen(
          (dynamic event) {
        try {
          final List<dynamic> rawList = event as List<dynamic>;
          // Convertir a double rápido
          _latestRaw = rawList.map((e) => (e as num).toDouble()).toList();
          _frameCount++;

          // Throttle: solo actualizamos a la frecuencia deseada
          if (_throttleTimer == null || !_throttleTimer!.isActive) {
            _throttleTimer = Timer(_throttleDuration, _emitLatest);
          }

          if (_frameCount % 300 == 0) {
            debugPrint('Android -> Flutter: received ${_latestRaw?.length ?? 0} values.');
          }
        } catch (e) {
          debugPrint('Parsing error en stream de poses: $e');
        }
      },
      onError: (dynamic error) {
        debugPrint('Error en el stream de poses: $error');
      },
      cancelOnError: false,
    );
  }

  void _emitLatest() {
    if (!mounted) return;
    final latest = _latestRaw;
    if (latest == null || latest.isEmpty) return;

    // Si la longitud cambia, resetear suavizado
    if (_smoothed == null || _smoothed!.length != latest.length) {
      _smoothed = List<double>.from(latest);
    } else {
      // Aplicar EMA por componente
      for (int i = 0; i < latest.length; i++) {
        final prev = _smoothed![i];
        final cur = latest[i];
        _smoothed![i] = _smoothingAlpha * cur + (1.0 - _smoothingAlpha) * prev;
      }
    }

    // Comparar con el último publicado y decidir si publicar
    final prevPublished = landmarksNotifier.value;
    bool shouldPublish = false;

    if (prevPublished.isEmpty || prevPublished.length != _smoothed!.length) {
      shouldPublish = true;
    } else {
      double maxDelta = 0.0;
      final len = math.min(prevPublished.length, _smoothed!.length);
      for (int i = 0; i < len; i++) {
        maxDelta = math.max(maxDelta, (prevPublished[i] - _smoothed![i]).abs());
      }
      if (maxDelta > _movementThreshold) shouldPublish = true;
    }

    if (shouldPublish) {
      // Publicar una copia inmutable para evitar modificaciones externas
      landmarksNotifier.value = List<double>.unmodifiable(_smoothed!);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_subscription == null) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _subscription?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _subscription?.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _throttleTimer?.cancel();
    _subscription?.cancel();
    landmarksNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'camera_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      // Puedes enviar parámetros nativos para solicitar mayor resolución/fps al View nativo
      // 'preferredResolution': '1280x720',
      // 'preferredFps': 30,
    };

    return Scaffold(
      body: Stack(
        children: [
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
              child: Text('Esta función solo está disponible en Android por ahora'),
            ),
          ),

          // Back button
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
