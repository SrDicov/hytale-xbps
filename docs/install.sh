#!/bin/bash
# install.sh — Instala o actualiza Hytale Launcher desde GitHub Releases
# Uso: curl -fsSL https://srdicov.github.io/hytale-xbps/install.sh | sh

set -euo pipefail

REPO="SrDicov/hytale-xbps"
GITHUB_API="https://api.github.com/repos/${REPO}/releases/latest"
INSTALL_DIR="/opt/hytale-launcher"
BIN_DIR="/usr/bin"
DESKTOP_DIR="/usr/share/applications"

echo "→ Buscando última versión..."

# Obtener URL de descarga
DOWNLOAD_URL=$(curl -fsSL "$GITHUB_API" | grep '"browser_download_url"' | grep '\.xbps"' | head -1 | sed 's/.*: *"\(.*\)".*/\1/')

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "ERROR: no se pudo obtener la URL de descarga" >&2
    exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")
echo "  descargando: $FILENAME"

# Descargar a tmp
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

curl -fsSL -o "$TMPDIR/$FILENAME" "$DOWNLOAD_URL"

# Extraer el .xbps (es un tar comprimido con zstd)
cd "$TMPDIR"
zstd -d -c "$FILENAME" | tar -xf -

# Verificar que somos root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: este script necesita ejecutarse como root (sudo)" >&2
    exit 1
fi

# Instalar archivos
echo "→ Instalando..."
mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR"
install -m 0755 opt/hytale-launcher/hytale-launcher "$INSTALL_DIR/hytale-launcher"
install -m 0755 usr/bin/hytale-launcher "$BIN_DIR/hytale-launcher"
cp usr/share/applications/hytale-launcher.desktop "$DESKTOP_DIR/"

echo "✓ Hytale Launcher instalado correctamente"
echo "  Ejecuta 'hytale-launcher' para iniciar"
