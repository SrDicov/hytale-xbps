# hytale-xbps

[![Build and Release](https://github.com/SrDicov/hytale-xbps/actions/workflows/build.yml/badge.svg)](https://github.com/SrDicov/hytale-xbps/actions/workflows/build.yml)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Paquete XBPS no oficial del [Hytale Launcher](https://hytale.com) para Void Linux.

## Instalación

### Método 1: Script automático (recomendado)

```bash
curl -fsSL https://srdicov.github.io/hytale-xbps/install.sh | sudo sh
```

### Método 2: Descarga manual

```bash
wget https://github.com/SrDicov/hytale-xbps/releases/latest/download/hytale-launcher-*.x86_64.xbps
sudo xbps-install -f ./hytale-launcher-*.x86_64.xbps
```

### Método 3: Compilar desde fuente

```bash
git clone https://github.com/SrDicov/hytale-xbps.git
cd hytale-xbps
./build.sh
sudo xbps-install --repository=./docs hytale-launcher-*
```

## Desinstalar

```bash
sudo rm -rf /opt/hytale-launcher /usr/bin/hytale-launcher /usr/share/applications/hytale-launcher.desktop
```

## Actualización

Ejecuta nuevamente el script de instalación o descarga el nuevo `.xbps` desde
[Releases](https://github.com/SrDicov/hytale-xbps/releases/latest).

## Dependencias

gtk+3, webkit2gtk, glib-networking, nss, openssl, cups, pulseaudio, alsa-lib, etc.
Se resuelven automáticamente desde los repos oficiales de Void Linux.

## Estructura

```
.
├── build.sh              # Script de build
├── current               # Última versión empaquetada
├── docs/                 # Paquetes compilados (servidos por GitHub Pages)
│   ├── install.sh        # Script de instalación automática
│   └── *.xbps            # Paquetes XBPS
├── .github/workflows/    # CI/CD automático (cada 24h)
└── LICENSE               # GPL-3.0
```

## Cómo funciona

1. GitHub Actions comprueba la API de Hytale cada 24 horas
2. Si hay nueva versión → descarga, verifica checksum, compila el .xbps
3. Publica un nuevo Release con el paquete como asset
4. Los usuarios descargan e instalan

## Licencia

Los scripts de build están bajo [GPL-3.0](LICENSE).
El binario del Hytale Launcher es propiedad de Hypixel Studios / Riot Games.
Este proyecto no está afiliado ni respaldado por ellos.
