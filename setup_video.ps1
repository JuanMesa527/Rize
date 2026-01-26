# Script para preparar video de prueba
# Ejecutar desde: C:\Users\Michael\AndroidStudioProjects\Rize

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Preparar Video de Prueba - Rize" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$videoDir = "assets\videos"
$videoPath = "$videoDir\sample_video.mp4"

# Verificar si ya existe un video
if (Test-Path $videoPath) {
    Write-Host "✓ Ya existe un video de prueba en:" -ForegroundColor Green
    Write-Host "  $videoPath" -ForegroundColor Yellow
    Write-Host ""
    $replace = Read-Host "¿Deseas reemplazarlo? (s/n)"
    if ($replace -ne "s") {
        Write-Host "Manteniendo video actual." -ForegroundColor Yellow
        exit
    }
}

Write-Host ""
Write-Host "Opciones para obtener un video de prueba:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Copiar un video existente desde tu PC" -ForegroundColor White
Write-Host "2. Descargar video de ejemplo (requiere internet)" -ForegroundColor White
Write-Host "3. Instrucciones para grabar tu propio video" -ForegroundColor White
Write-Host "4. Salir" -ForegroundColor White
Write-Host ""

$opcion = Read-Host "Selecciona una opción (1-4)"

switch ($opcion) {
    "1" {
        Write-Host ""
        Write-Host "Abre el diálogo de selección de archivo..." -ForegroundColor Cyan

        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $FileBrowser.Filter = "Videos (*.mp4;*.mov;*.avi)|*.mp4;*.mov;*.avi|Todos los archivos (*.*)|*.*"
        $FileBrowser.Title = "Selecciona un video de prueba"

        if ($FileBrowser.ShowDialog() -eq "OK") {
            $sourceFile = $FileBrowser.FileName
            Write-Host ""
            Write-Host "Copiando video..." -ForegroundColor Yellow
            Copy-Item -Path $sourceFile -Destination $videoPath -Force
            Write-Host "✓ Video copiado exitosamente!" -ForegroundColor Green
            Write-Host "  Ubicación: $videoPath" -ForegroundColor Cyan
        } else {
            Write-Host "Operación cancelada." -ForegroundColor Yellow
        }
    }

    "2" {
        Write-Host ""
        Write-Host "Descargando video de ejemplo..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "NOTA: Este script intentará descargar un video de Pexels." -ForegroundColor Yellow
        Write-Host "Si falla, usa la opción 1 o 3 para obtener tu propio video." -ForegroundColor Yellow
        Write-Host ""

        # URL de ejemplo (puedes cambiar esta URL)
        $videoUrl = "https://videos.pexels.com/video-files/3766421/3766421-hd_1920_1080_24fps.mp4"

        try {
            Write-Host "Descargando desde Pexels..." -ForegroundColor Cyan
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $videoUrl -OutFile $videoPath -UseBasicParsing
            Write-Host "✓ Video descargado exitosamente!" -ForegroundColor Green
            Write-Host "  Ubicación: $videoPath" -ForegroundColor Cyan
        } catch {
            Write-Host "✗ Error al descargar el video." -ForegroundColor Red
            Write-Host "  Usa la opción 1 para copiar un video manualmente." -ForegroundColor Yellow
        }
    }

    "3" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "   Instrucciones para Grabar Video" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Usa la cámara de tu teléfono o PC" -ForegroundColor White
        Write-Host "2. Grábate realizando algún ejercicio (10-30 segundos)" -ForegroundColor White
        Write-Host "3. Asegúrate de que tu cuerpo completo sea visible" -ForegroundColor White
        Write-Host "4. Guarda el video y transfiérelo a tu PC" -ForegroundColor White
        Write-Host "5. Copia el video a: $videoPath" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Sugerencias de ejercicios:" -ForegroundColor Cyan
        Write-Host "  - Sentadillas" -ForegroundColor White
        Write-Host "  - Flexiones" -ForegroundColor White
        Write-Host "  - Jumping jacks" -ForegroundColor White
        Write-Host "  - Estiramiento" -ForegroundColor White
        Write-Host ""
    }

    "4" {
        Write-Host "Saliendo..." -ForegroundColor Yellow
        exit
    }

    default {
        Write-Host "Opción no válida." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Para probar la aplicación:" -ForegroundColor Yellow
Write-Host "  flutter run" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
