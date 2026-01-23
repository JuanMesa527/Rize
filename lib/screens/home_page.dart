import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rize_project/screens/pose_detector_view.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A11CB), // Purple
              Color(0xFF2575FC), // Blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 50),
              // Logo Placeholder - Space to be changed for an image later
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lightning icon (placeholder for logo)
                    Transform.rotate(
                      angle: 0.1,
                      child: const Icon(
                        Icons.bolt,
                        size: 50,
                        color: Color(0xFF6A11CB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Rize',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6A11CB), // Matches purple
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Content Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    // Three dumbbells
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.fitness_center, color: Color(0xFFFFD500), size: 30),
                        SizedBox(width: 10),
                        Icon(Icons.fitness_center, color: Color(0xFFFFD500), size: 30),
                        SizedBox(width: 10),
                        Icon(Icons.fitness_center, color: Color(0xFFFFD500), size: 30),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tu mejor versión\ncomienza hoy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cada repetición te acerca a tus metas.\n¡Es momento de levantarte!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Button
              Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 48.0),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFB300), // Amber/Orange
                        Color(0xFFFF4081), // Pink
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        // Request camera permission
                        var status = await Permission.camera.request();

                        if (status.isGranted) {
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PoseDetectorView(),
                              ),
                            );
                          }
                        } else if (status.isPermanentlyDenied) {
                          openAppSettings();
                        } else {
                          // Handle denied permission (show snackbar, etc.)
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Se necesita permiso de cámara para continuar'),
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Center(
                        child: Text(
                          'Empezar',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

