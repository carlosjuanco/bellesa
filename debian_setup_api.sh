#!/bin/bash

# Variables para repositorio API
REPO_API_URL="https://github.com/carlosjuanco/zeus-api.git"
DEST_API_DIR="/home/juan/Documentos/proyecto_iasd/api/zeus-api"

# Comando para clonar el repositorio
git clone $REPO_API_URL $DEST_API_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_API_DIR"

# Variables para repositorio APP
REPO_APP_URL="https://github.com/carlosjuanco/meca-app.git"
DEST_APP_DIR="/home/juan/Documentos/proyecto_iasd/app/meca-app"

# Comando para clonar el repositorio
git clone $REPO_APP_URL $DEST_APP_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_APP_DIR"
