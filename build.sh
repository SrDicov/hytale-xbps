#!/bin/bash
# build.sh — Genera el paquete XBPS de Hytale Launcher desde la API oficial.
# Destino: instalar en otra máquina Void Linux.
# Uso: cd ~/hytale-xbps && ./build.sh
#
# Variables opcionales:
#   XBPS_CREATE  — ruta a xbps-create (default: xbps-create en PATH)
#   XBPS_RINDEX  — ruta a xbps-rindex (default: xbps-rindex en PATH)
#   ARCH         — arquitectura destino (default: x86_64)
#   REPO_URL     — URL base del repositorio (default: https://hytale.com)

set -euo pipefail

# --- Rutas ---
SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="$SCRIPTDIR/work"
REPODIR="$SCRIPTDIR/repo"
ROOTFS="$WORKDIR/rootfs"
CURRENT_FILE="$SCRIPTDIR/current"
API_URL="https://launcher.hytale.com/version/release/launcher.json"

# --- Configurables ---
XBPS_CREATE="${XBPS_CREATE:-xbps-create}"
XBPS_RINDEX="${XBPS_RINDEX:-xbps-rindex}"
ARCH="${ARCH:-x86_64}"
MAINTAINER="${MAINTAINER:-dicov <dicov@localhost>}"
REPO_URL="${REPO_URL:-https://hytale.com}"

# --- Verificar dependencias ---
for tool in curl jq unzip sha256sum install "$XBPS_CREATE" "$XBPS_RINDEX"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "ERROR: '$tool' no encontrado en PATH" >&2
        exit 1
    fi
done

# --- Limpiar trabajo anterior ---
rm -rf "$ROOTFS"
mkdir -p "$ROOTFS/opt/hytale-launcher" \
         "$ROOTFS/usr/bin" \
         "$ROOTFS/usr/share/applications"

# --- 1. Consultar versión actual en la API ---
echo "→ Consultando $API_URL ..."
JSON="$(curl -fsSL --max-time 30 "$API_URL")"

VERSION="$(printf '%s' "$JSON" | jq -r '.version')"
DOWNLOAD_URL="$(printf '%s' "$JSON" | jq -r '.download_url.linux.amd64.url')"
EXPECTED_SHA="$(printf '%s' "$JSON" | jq -r '.download_url.linux.amd64.sha256')"

if [[ -z "$VERSION" || "$VERSION" == "null" ]]; then
    echo "ERROR: no se pudo leer la versión de la API" >&2
    exit 1
fi

echo "  versión: $VERSION"
echo "  url:     $DOWNLOAD_URL"
echo "  sha256:  $EXPECTED_SHA"

# --- 2. Comparar con la última empaquetada ---
if [[ -f "$CURRENT_FILE" ]] && [[ "$(cat "$CURRENT_FILE")" == "$VERSION" ]]; then
    echo "✓ Ya está empaquetado ($VERSION). Nada que hacer."
    exit 0
fi

# --- 3. Descargar el zip versionado ---
ZIPFILE="$WORKDIR/hytale-launcher-${VERSION}.zip"
echo "→ Descargando ..."
curl -fsSL --max-time 120 -o "$ZIPFILE" "$DOWNLOAD_URL"

# --- 4. Verificar checksum ---
ACTUAL_SHA="$(sha256sum "$ZIPFILE" | awk '{print $1}')"
if [[ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]]; then
    echo "ERROR: SHA256 no coincide" >&2
    echo "  esperado: $EXPECTED_SHA" >&2
    echo "  obtenido: $ACTUAL_SHA" >&2
    rm -f "$ZIPFILE"
    exit 1
fi
echo "  sha256 OK"

# --- 5. Extraer y armar árbol DESTDIR ---
echo "→ Extrayendo ..."
unzip -q -o "$ZIPFILE" -d "$WORKDIR/extracted/"

# El zip contiene solo el binario suelto
BIN_SRC="$WORKDIR/extracted/hytale-launcher"
if [[ ! -f "$BIN_SRC" ]]; then
    echo "ERROR: no se encontró hytale-launcher dentro del zip" >&2
    exit 1
fi

install -m 0755 "$BIN_SRC" "$ROOTFS/opt/hytale-launcher/hytale-launcher"

# Wrapper con la variable de entorno requerida
cat > "$ROOTFS/usr/bin/hytale-launcher" <<'EOF'
#!/bin/sh
export WEBKIT_DISABLE_COMPOSITING_MODE=1
exec /opt/hytale-launcher/hytale-launcher "$@"
EOF
chmod 0755 "$ROOTFS/usr/bin/hytale-launcher"

# Entrada de menú (sin icono, el zip no lo trae)
cat > "$ROOTFS/usr/share/applications/hytale-launcher.desktop" <<'EOF'
[Desktop Entry]
Name=Hytale Launcher
Exec=hytale-launcher
Terminal=false
Type=Application
StartupWMClass=Hytale
Comment=Official Hytale launcher
Categories=Game;
Icon=hytale-launcher
EOF

# --- 6. Crear el paquete .xbps ---
# Formato de versión para XBPS: guiones bajos, revision _1
# Strip commit hash for XBPS-compatible version
VERSION_PKG="${VERSION%%-*}"
PKGVER="${VERSION_PKG}_1"
PKGNAME="hytale-launcher"

echo "→ Creando paquete $PKGNAME-$PKGVER ($ARCH) ..."

"$XBPS_CREATE" \
    -A "$ARCH" \
    -n "$PKGNAME-$PKGVER" \
    -s "Official Hytale launcher (native Linux binary)" \
    -l "Proprietary" \
    -H "$REPO_URL" \
    -m "$MAINTAINER" \
    -S "Hytale launcher official native Linux build packaged for Void Linux" \
    -D "gtk+3 webkit2gtk glib-networking gsettings-desktop-schemas nss nspr openssl cups pulseaudio alsa-lib libdrm libxkbcommon at-spi2-atk atk pango cairo freetype fontconfig expat dbus xdg-utils hicolor-icon-theme libstdc++" \
    "$ROOTFS"

# --- 7. Mover al repo local y re-indexar ---
XBPS_FILE="$PKGNAME-$PKGVER.$ARCH.xbps"
if [[ ! -f "$XBPS_FILE" ]]; then
    echo "ERROR: xbps-create no generó $XBPS_FILE" >&2
    exit 1
fi

mv "$XBPS_FILE" "$REPODIR/"
"$XBPS_RINDEX" -a "$REPODIR/$XBPS_FILE"

# --- 8. Registrar versión ---
printf '%s' "$VERSION" > "$CURRENT_FILE"

# --- Listo ---
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Paquete generado: $REPODIR/$XBPS_FILE"
echo "  Versión: $VERSION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Para instalar en la máquina Void:"
echo "  1. Copiar el .xbps:"
echo "       scp $REPODIR/$XBPS_FILE void-machine:/tmp/"
echo "  2. En la máquina Void:"
echo "       sudo xbps-install --repository=/tmp $PKGNAME-$PKGVER"
echo
echo "O monta el repo local como repositorio remoto:"
echo "       sudo xbps-install --repository=$REPODIR $PKGNAME-$PKGVER"
