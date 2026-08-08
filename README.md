# hytale-xbps

[![Build and Release](https://github.com/SrDicov/hytale-xbps/actions/workflows/build.yml/badge.svg)](https://github.com/SrDicov/hytale-xbps/actions/workflows/build.yml)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Paquete XBPS no oficial del [Hytale Launcher](https://hytale.com) para Void Linux.

## Instalación

### Método 1: Desde GitHub Release (recomendado)

```bash
# Descargar el .xbps
wget https://github.com/SrDicov/hytale-xbps/releases/latest/download/hytale-launcher-*.x86_64.xbps

# Instalar
sudo xbps-install hytale-launcher-*.x86_64.xbps
```

### Método 2: Compilar manualmente

```bash
git clone https://github.com/SrDicov/hytale-xbps.git
cd hytale-xbps
./build.sh
sudo xbps-install --repository=./docs hytale-launcher-*
```

## Desinstalar

```bash
sudo xbps-remove hytale-launcher
```

## Dependencias

gtk+3, webkit2gtk, glib-networking, nss, openssl, cups, pulseaudio, alsa-lib, etc.
Se resuelven automáticamente desde los repos oficiales de Void Linux.

## Actualización automática

GitHub Actions comprueba la API de Hytale cada 24 horas. Si hay nueva versión,
se compila y publica automáticamente un nuevo Release.

## Estructura

```
.
├── build.sh              # Script de build
├── Makefile              # Atajos (make build, make clean)
├── docs/                 # Paquetes compilados (GitHub Pages)
├── .github/workflows/    # CI/CD
└── LICENSE               # GPL-3.0
```

## Licencia

GPL-3.0 para los scripts de build. El binario del Hytale Launcher es propiedad
de Hypixel Studios / Riot Games. Este proyecto no está afiliado con ellos.
