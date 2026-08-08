.DEFAULT_GOAL := help
.PHONY: help build clean repo install-local

SHELL := /bin/bash

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Construye el paquete XBPS si hay nueva versión
	./build.sh

clean: ## Limpiar archivos temporales
	rm -rf work/

repo: build ## Construye y actualiza el índice del repo local
	cd repo && xbps-rindex -a *.xbps 2>/dev/null || true

install-local: build ## Instala el paquete en la máquina local
	sudo xbps-install --repository=$$(pwd)/repo hytale-launcher-$$(cat current | cut -d- -f1)_1

uninstall: ## Desinstala el paquete
	sudo xbps-remove hytale-launcher-$$(cat current | cut -d- -f1)_1

current: ## Muestra la versión actual
	@echo "Versión empaquetada: $$(cat current 2>/dev/null || echo 'ninguna')"
