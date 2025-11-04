# Asset Compression Tools

Scripts para comprimir imágenes, videos y audio del juego DELTA+ usando ffmpeg.

## Requisitos

- **ffmpeg** instalado y disponible en PATH
  - Windows: Descargar de https://ffmpeg.org/download.html
  - macOS: `brew install ffmpeg`
  - Linux: `sudo apt install ffmpeg` o `sudo yum install ffmpeg`

## Uso

### Windows

```cmd
cd tools
compress-all.bat
```

O ejecutar scripts individuales:
```cmd
compress-images.bat    # Solo imágenes (JPG/PNG)
compress-videos.bat    # Solo videos (WEBM/MP4)
compress-audio.bat     # Solo audio (MP3/M4A)
```

### macOS / Linux

```bash
cd tools
chmod +x *.sh  # Primera vez solamente
./compress-all.sh
```

O ejecutar scripts individuales:
```bash
./compress-images.sh   # Solo imágenes
./compress-videos.sh   # Solo videos
./compress-audio.sh    # Solo audio
```

## Configuración

Puedes ajustar la calidad de compresión editando los scripts:

### Imágenes (`compress-images.bat/.sh`)
- `QUALITY=75` - Calidad JPG (0-100, menor = más compresión)
- `PNG_QUALITY=90` - Nivel de compresión PNG

### Videos (`compress-videos.bat/.sh`)
- `CRF_VP9=35` - CRF para WEBM (18-51, mayor = más compresión)
- `CRF_H264=28` - CRF para MP4 (18-51, mayor = más compresión)

### Audio (`compress-audio.bat/.sh`)
- `MP3_BITRATE=128k` - Bitrate para MP3 (recomendado: 96k-192k)
- `AAC_BITRATE=96k` - Bitrate para M4A/AAC (recomendado: 64k-128k)

## Cómo funciona

1. Los scripts recorren recursivamente las carpetas `assets/` y `game-assets/`
2. Para cada archivo compatible:
   - Crea una versión comprimida temporal
   - Compara el tamaño con el original
   - **Solo reemplaza si el archivo comprimido es más pequeño**
   - Muestra cuántos MB se ahorraron

3. Los archivos originales se sobrescriben solo si hay mejora
4. Después puedes hacer commit de los archivos optimizados

## Notas

- **Primera ejecución puede tardar mucho** (especialmente videos grandes)
- Los scripts son idempotentes: ejecutarlos múltiples veces no causa problemas
- Solo se reemplazan archivos si hay mejora de tamaño (≥5%)
- Se procesan: JPG, JPEG, PNG, WEBM, MP4, MP3, M4A

## Tamaños recomendados después de compresión

- **Imágenes de fondo**: 200-500 KB cada una
- **Videos cortos** (<10 seg): 500 KB - 2 MB
- **Videos largos** (>10 seg): 2-10 MB
- **Audio música**: 1-3 MB por minuto
- **Audio efectos**: 50-200 KB cada uno
