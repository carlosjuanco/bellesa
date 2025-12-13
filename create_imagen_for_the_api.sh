#!/bin/bash

version_so="Versión: Sonoma 14.3"
proyecto="Proyecto: main"
descripcion_proyecto="Descripción del proyecto: Base para todos los proyectos."

echo $version_so
echo $proyecto
echo $descripcion_proyecto
echo "......................................................................"
# Crear imagen
echo "Creando y levantando la imagen para la API ...."
sudo docker build -t juancholll/laravel_api_macos:1.0.0 .

echo "......................................................................"
echo "Servicio proyecto_api2 levantado correctamente"