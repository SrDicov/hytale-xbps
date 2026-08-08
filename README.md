# hytale-xbps

[![Build and Release](https://github.com/SrDicov/hytale-xbps/actions/workflows/build.yml/badge.svg)](https://github.com/SrDicov/hytale-xbps/actions/workflows/build.yml)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Paquete XBPS no oficial del [Hytale Launcher](https://hytale.com) para Void Linux.

## 🚀 Instalación rápida

```bash
# Añadir el repositorio
echo "repository=https://github.com/SrDicov/hytale-xbps/releases/latest/download" | \
  sudo tee /etc/xbps.d/99-hytale.conf

# Instalar
sudo xbps-install -S hytale-launcher
```

Para actualizar cuando haya una nueva versión:
```bash
sudo xbps-install -Su hytale-launcher
```

## 📦 Desinstalar

```bash
sudo xbps-remove hytale-launcher
```

## 🔧 Compilar manualmente

```bash
git clone https://github.com/SrDicov/hytale-xbps.git
cd hytale-xbps
./build.sh
sudo xbps-install --repository=./repo hytale-launcher-<version>
```

## 📋 Dependencias

Las dependencias se resuelven automáticamente desde los repos oficiales de Void Linux:
gtk+3, webkit2gtk, glib-networking, nss, openssl, cups, pulseaudio, alsa-lib, entre otros.

## 🔄 Actualización automática

GitHub Actions comprueba la API de Hytale cada 6 horas. Si detecta una nueva versión,
compila automáticamente el paquete y publica un nuevo Release.

## 📄 Estructura

```
.
├── build.sh              # Script principal de build
├── Makefile              # Atajos (make build, make clean, make repo)
├── current               # Última versión empaquetada
├── repo/                 # Paquetes compilados (se generan con build.sh)
├── .github/workflows/    # CI/CD automático
└── LICENSE               # GPL-3.0
```

## ⚖️ Licencia

El código de este proyecto está licenciado bajo [GNU GPL v3.0](LICENSE).

El binario del Hytale Launcher es propiedad de Hypixel Studios.
Este proyecto no está afiliado ni respaldado por ellos.
