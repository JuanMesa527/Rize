# ❓ Preguntas Frecuentes (FAQ)

## 🎯 Funcionalidad General

### ¿Qué hace esta app?
Detecta la pose corporal (33 puntos) en tiempo real usando la cámara o analizando videos grabados.

### ¿Qué cambió con esta actualización?
Antes solo funcionaba con cámara en vivo. Ahora también puedes subir videos para analizarlos.

### ¿Sigue funcionando el modo de cámara en vivo?
¡Sí! El modo original está intacto. Ahora tienes dos opciones para elegir.

---

## 🎬 Sobre Videos

### ¿Qué formato de video debo usar?
- **Formato recomendado:** MP4 (H.264)
- **Otros formatos:** MOV, AVI (pueden funcionar)
- **Resolución:** 720p o superior
- **Duración:** 10-30 segundos ideal

### ¿Dónde consigo videos de prueba?
1. **Graba tu propio video** (lo mejor)
2. **Descarga de internet:**
   - Pexels.com (gratis, busca "workout")
   - Pixabay.com (dominio público)
3. **Usa el script:** `.\setup_video.ps1`

### ¿Puedo usar videos largos?
Sí, pero el procesamiento será más lento. Recomendamos empezar con videos cortos (10-30 seg).

### ¿El video debe mostrar el cuerpo completo?
Sí, para mejor detección. MediaPipe necesita ver la mayoría de los puntos clave.

---

## 🔧 Problemas Técnicos

### No puedo seleccionar videos de la galería
**Solución:**
1. Ve a Configuración del dispositivo
2. Apps → Rize → Permisos
3. Activa "Almacenamiento" o "Archivos y multimedia"

### La app crashea al abrir un video
**Posibles causas:**
- Video demasiado grande (intenta con uno más corto)
- Formato no compatible (convierte a MP4)
- Falta de memoria (cierra otras apps)

**Solución:**
```bash
flutter clean
flutter pub get
flutter run
```

### El procesamiento es muy lento
**Normal si:**
- Video es largo (>1 minuto)
- Resolución muy alta (4K)
- Dispositivo antiguo

**Mejora:**
- Usa videos más cortos
- Reduce resolución a 720p
- Ya está configurado para usar GPU

### No veo el overlay de pose en el video
**Verifica:**
1. El video tiene una persona visible
2. La persona está de cuerpo completo
3. Buena iluminación en el video
4. Los logs no muestran errores: `flutter logs`

---

## 💻 Desarrollo

### ¿Cómo veo los logs?
```bash
flutter logs
```

### ¿Cómo limpio el proyecto?
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### ¿Dónde están los archivos importantes?

**Flutter:**
- `lib/screens/pose_detector_view.dart` - UI principal

**Kotlin:**
- `CameraView.kt` - Modo cámara en vivo
- `VideoView.kt` - Modo video
- `PoseLandmarkerHelper.kt` - MediaPipe (ambos modos)
- `MainActivity.kt` - Configuración

### ¿Cómo agrego nuevas funcionalidades?
1. Estudia `RESUMEN_CAMBIOS.md` para entender la arquitectura
2. Revisa `CONFIGURACION_VIDEO.md` para detalles técnicos
3. Modifica los archivos necesarios
4. Prueba con `flutter run`

---

## 🎨 Personalización

### ¿Puedo cambiar los colores?
**Sí, edita:**

**Botones de selección:**
`lib/screens/pose_detector_view.dart` líneas 84, 94

**Overlay de pose:**
`android/.../OverlayView.kt` método `initPaints()`

### ¿Puedo cambiar el tamaño de los puntos?
**Sí, en** `OverlayView.kt`:
```kotlin
pointPaint.strokeWidth = 8f  // Cambia este valor
linePaint.strokeWidth = 4f   // Y este
```

### ¿Puedo agregar más opciones de detección?
¡Claro! La arquitectura está diseñada para ser extensible:
1. Crea una nueva clase similar a `VideoView.kt`
2. Registra en `MainActivity.kt`
3. Agrega opción en `pose_detector_view.dart`

---

## 📱 Uso de la App

### ¿Cuál modo debo usar?
**Cámara en vivo:** 
- Para entrenar en tiempo real
- Ver tu forma inmediatamente
- Ejercicios en el momento

**Video:**
- Analizar técnica después
- Revisar movimientos específicos
- Comparar diferentes intentos

### ¿Puedo pausar el análisis de video?
Actualmente no, pero es una mejora sugerida para el futuro.

### ¿Se guardan los datos de pose?
Actualmente se envían a Flutter pero no se guardan. Puedes implementar guardado en JSON.

### ¿Puedo exportar los datos?
No implementado aún, pero es fácil agregar:
1. Captura los landmarks en Flutter
2. Serializa a JSON
3. Guarda en archivo

---

## 🚀 Rendimiento

### ¿Cuántos FPS procesa en modo en vivo?
~30 FPS en dispositivos modernos con GPU.

### ¿Cuánto tarda en procesar un video?
Aproximadamente el tiempo real del video. Un video de 30 segundos tarda ~30 segundos.

### ¿Usa mucha batería?
Sí, la detección de pose es intensiva. Normal en apps de fitness/AR.

### ¿Necesito internet?
No, todo se procesa localmente en el dispositivo.

---

## 🔐 Privacidad y Seguridad

### ¿Mis videos se suben a internet?
No, todo el procesamiento es local.

### ¿Se guardan mis datos?
No, los datos solo existen en memoria mientras usas la app.

### ¿Qué permisos necesita la app?
- **CAMERA**: Para modo en vivo
- **READ_EXTERNAL_STORAGE**: Para leer videos
- **READ_MEDIA_VIDEO**: Para Android 13+ (acceso a videos)

---

## 📊 Datos Técnicos

### ¿Qué puntos detecta?
33 puntos de landmarks (ver diagrama en TUTORIAL_RAPIDO.md):
- Rostro: 11 puntos
- Torso: 6 puntos
- Brazos: 8 puntos
- Piernas: 8 puntos

### ¿Qué datos recibe Flutter?
Cada frame envía 132 valores (33 puntos × 4 valores):
- X: Posición horizontal (0-1)
- Y: Posición vertical (0-1)
- Z: Profundidad relativa
- Visibility: Confianza (0-1)

### ¿Qué es MediaPipe?
Framework de Google para ML en tiempo real. Usado por muchas apps de fitness/AR.

---

## 🎯 Próximos Pasos

### ¿Qué puedo hacer con los datos?
Ideas:
1. **Contador de repeticiones** (detectar sentadillas, flexiones)
2. **Análisis de forma** (ángulos correctos)
3. **Comparación** (tu técnica vs. profesional)
4. **Gamificación** (puntos por buena forma)
5. **Gráficos** (visualizar movimiento en el tiempo)

### ¿Cómo implemento detección de ejercicios?
1. Captura los landmarks
2. Calcula ángulos entre puntos clave
3. Define rangos para cada ejercicio
4. Cuenta cuando se cumplen las condiciones

**Ejemplo - Sentadilla:**
```dart
// Ángulo de rodilla < 90° = abajo
// Ángulo de rodilla > 160° = arriba
// Contar transiciones completas
```

### ¿Hay tutoriales para MediaPipe?
Sí:
- [Documentación oficial](https://developers.google.com/mediapipe)
- [Ejemplos de pose](https://google.github.io/mediapipe/solutions/pose)
- Código de esta app (bien comentado)

---

## 🐛 Errores Comunes

### "No such file or directory: pose_landmarker_lite.task"
**Solución:** Verifica que el modelo esté en `android/app/src/main/assets/`

### "Permission denied"
**Solución:** Otorga permisos en configuración del dispositivo

### "Platform view not found"
**Solución:** 
```bash
flutter clean
flutter pub get
flutter run
```

### Errores de compilación Kotlin
**Solución:** Verifica que todos los archivos .kt se hayan creado correctamente

---

## 📞 Obtener Ayuda

### Archivos de ayuda:
1. **TUTORIAL_RAPIDO.md** - Tutorial paso a paso
2. **CONFIGURACION_VIDEO.md** - Guía técnica completa
3. **RESUMEN_CAMBIOS.md** - Arquitectura y cambios
4. **FAQ.md** - Este archivo

### Ver logs detallados:
```bash
flutter logs
```

### Buscar errores específicos:
```bash
flutter logs | grep "Error\|Exception"
```

### Limpiar completamente:
```bash
flutter clean
cd android
./gradlew clean
cd ..
rm -rf build/
flutter pub get
flutter run
```

---

## 🎉 ¡Listo!

Si tu pregunta no está aquí:
1. Revisa los archivos de documentación
2. Busca en los logs: `flutter logs`
3. Revisa el código (está bien comentado)

**¡Disfruta tu app mejorada!** 🚀
