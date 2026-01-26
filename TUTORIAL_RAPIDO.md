# 🎯 Tutorial Rápido - Uso de la Aplicación

## 🚀 Inicio Rápido

### 1️⃣ Pantalla Inicial
```
┌─────────────────────────────────┐
│         🏠 RIZE                 │
│                                 │
│   ┌─────────────────────────┐  │
│   │  ⚡ Comenzar            │  │
│   │     Entrenamiento       │  │
│   └─────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```
👆 Presiona el botón naranja/rosa

---

### 2️⃣ Pantalla de Selección (NUEVA)
```
┌─────────────────────────────────┐
│   🎯 Detección de Pose          │
│                                 │
│      Elige una opción           │
│                                 │
│   ┌─────────────────────────┐  │
│   │ 🎥 Cámara en Vivo      →│  │
│   │ Usa la cámara en        │  │
│   │ tiempo real             │  │
│   └─────────────────────────┘  │
│                                 │
│   ┌─────────────────────────┐  │
│   │ 📹 Subir Video         →│  │
│   │ Analiza un video desde  │  │
│   │ tu dispositivo          │  │
│   └─────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```

---

### 3️⃣ Opción A: Cámara en Vivo
```
┌─────────────────────────────────┐
│  ← 🎥 LIVE                      │
│                                 │
│    ╔═════════════════╗          │
│    ║   👤 TÚ         ║          │
│    ║   ┃╲ ╱┃        ║          │
│    ║   ┃ ○ ┃ ← Esqueleto       │
│    ║   ┃╱ ╲┃        ║          │
│    ║    ┃ ┃         ║          │
│    ║   ╱ ╲           ║          │
│    ╚═════════════════╝          │
│                                 │
│  Detección en tiempo real ✅    │
└─────────────────────────────────┘
```
✅ Funcionalidad original
✅ Usa cámara frontal
✅ Detección instantánea

---

### 3️⃣ Opción B: Subir Video (NUEVO)
```
┌─────────────────────────────────┐
│  ← 📹 VIDEO   🎬 Frames: 245   │
│                                 │
│    ╔═════════════════╗          │
│    ║   🎥 VIDEO       ║          │
│    ║   ┃╲ ╱┃        ║          │
│    ║   ┃ ○ ┃ ← Esqueleto       │
│    ║   ┃╱ ╲┃        ║          │
│    ║    ┃ ┃         ║          │
│    ║   ╱ ╲           ║          │
│    ╚═════════════════╝          │
│                                 │
│  ⏸ Pausa  ⏩ Adelante           │
└─────────────────────────────────┘
```
✅ Selecciona video de tu galería
✅ Procesamiento frame por frame
✅ Ve el progreso en tiempo real

---

## 📱 Flujo Completo

```
   Abrir App
      ↓
   Presionar "Comenzar Entrenamiento"
      ↓
   ┌──────────────────┐
   │  Elegir Opción   │
   └────┬────────┬────┘
        │        │
   ┌────↓──┐ ┌──↓──────┐
   │Cámara│ │ Video    │
   │Live  │ │(Galería) │
   └───┬──┘ └──┬───────┘
       │       │
       │       ↓
       │   Seleccionar
       │   Video MP4
       │       │
       └───┬───┘
           ↓
   Ver Detección de Pose
   con Esqueleto Overlay
```

---

## 🎬 Preparar Video de Prueba

### Método 1: Script Automático
```powershell
.\setup_video.ps1
```
El script te guiará paso a paso.

### Método 2: Manual
1. Graba un video de 10-30 segundos
2. Asegúrate de estar visible de cuerpo completo
3. Guarda como MP4
4. Copia a: `assets/videos/sample_video.mp4`

### Método 3: Usar la App
1. Ejecuta `flutter run`
2. Selecciona "Subir Video"
3. Elige cualquier video de tu galería
4. ¡Listo!

---

## 🎯 Diferencias entre Modos

| Característica | Cámara en Vivo | Subir Video |
|---------------|----------------|-------------|
| **Fuente** | Cámara frontal | Archivo MP4 |
| **Tiempo real** | ✅ Sí | ❌ No (procesado) |
| **Control** | ❌ No | ✅ Ver, pausar |
| **Análisis** | Instantáneo | Frame a frame |
| **Mejor para** | Ejercicio en vivo | Analizar técnica |

---

## 🔍 Qué Detecta la App

### 33 Puntos de Landmarks:
```
       0 (Nariz)
      / | \
     /  |  \
   11   12  (Hombros)
    |    |
   13   14  (Codos)
    |    |
   15   16  (Muñecas)
    
   23   24  (Caderas)
    |    |
   25   26  (Rodillas)
    |    |
   27   28  (Tobillos)
```

Cada punto tiene:
- **X, Y**: Posición en pantalla
- **Z**: Profundidad
- **Visibility**: Confianza (0-1)

---

## 💡 Consejos de Uso

### Para Cámara en Vivo:
1. ✅ Buena iluminación
2. ✅ Fondo despejado
3. ✅ Cuerpo completo visible
4. ✅ Mantente en el centro

### Para Videos:
1. ✅ Videos cortos (10-30 seg)
2. ✅ Formato MP4
3. ✅ Buena calidad (720p+)
4. ✅ Persona visible de cuerpo completo

---

## 🐛 Troubleshooting Rápido

### Error al abrir cámara:
```bash
# Otorga permisos de cámara en Settings → Apps → Rize
```

### No puedo seleccionar video:
```bash
# Otorga permisos de almacenamiento
# Settings → Apps → Rize → Permissions
```

### App crashea:
```bash
flutter clean
flutter pub get
flutter run
```

### Ver logs:
```bash
flutter logs
```

---

## 🎉 ¡Listo para Usar!

Ahora tienes dos formas de detectar poses:
1. **En vivo** - Para entrenar en tiempo real
2. **Con video** - Para analizar tu técnica

**Próximo paso:** ¡Ejecuta la app y pruébala!

```bash
flutter run
```

🚀 **¡Disfruta tu app mejorada!**
