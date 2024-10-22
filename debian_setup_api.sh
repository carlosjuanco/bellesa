#!/bin/bash

# Variables
REPO_URL="https://github.com/carlosjuanco/zeus-api.git"
DEST_DIR="/home/juan/Documentos/proyecto_iasd/api/zeus-api"

# Comando para clonar el repositorio
git clone $REPO_URL $DEST_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_DIR"
