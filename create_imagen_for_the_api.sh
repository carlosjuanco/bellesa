#!/bin/bash

name_project="image_for_filament"

version_so="Versión: Debian 12.7"
proyecto="Proyecto: "$name_project
descripcion_proyecto="Descripción del proyecto: Base de filament para los siguientes proyecto."

echo $version_so
echo $proyecto
echo $descripcion_proyecto
echo "......................................................................"

current_username=$(whoami)
current_directory_of_the_bellesa_project=$(pwd)

directory_name_project="proyecto_"$name_project
directorio_carpeta_raiz="/home/$current_username/Documentos"
carpeta_raiz=$directorio_carpeta_raiz"/"$directory_name_project
subcarpeta_api=$carpeta_raiz"/api"

container_name_for_filament_image=$name_project

create_container_for_services="create_containers_for_"$name_project"_services.yml"

# Paramos todos los contenedores
echo "Comenzando a parar todos los contenedores ...."

sudo docker stop $container_name_for_filament_image
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_for_filament_image
fi

echo "Se termino de parar todos los contenedores"

echo "......................................................................"

echo "Comenzar a eliminar todos los contenedores ...."

sudo docker rm $container_name_for_filament_image
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_for_filament_image
fi
echo "Se termino de eliminar todos los contenedores"

echo "......................................................................"

echo "Verificando que la carpeta "$directory_name_project" no exista ...."

if [ -d "$carpeta_raiz" ]; then
	echo "La carpeta exite $carpeta_raiz, comenzando a borrar ...."
	sudo rm -r $carpeta_raiz
fi

echo "......................................................................"

echo "Comenzando a crear las carpetas ...."

mkdir $carpeta_raiz
mkdir $subcarpeta_api

echo "Se termino de crear las carpetas"

tree $carpeta_raiz

echo "......................................................................"

echo "Estos eran los permisos cuando creaba las carpetas en el explorador de archivo ...."

echo "drwxr-xr-x  5 juan juan 4096 oct 26 11:02 "$directory_name_project
echo "drwxr-xr-x 3 juan juan 4096 oct 26 11:02 "$subcarpeta_api
echo "Lo importante es drwxr-xr-x"

echo "......................................................................"

echo "Los permisos de las carpetas creadas son ...."
ls -al $directorio_carpeta_raiz
ls -al $carpeta_raiz
ls -al $subcarpeta_api

echo "......................................................................"
echo "Comenzando a crear el archivo "$create_container_for_services" .v..."
echo "......................................................................"
origen="$current_directory_of_the_bellesa_project/automate_image_for_api.yml"
destino="$current_directory_of_the_bellesa_project/"$create_container_for_services

#v Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

sed -i "s|proyecto_api:|"$name_project":|g" "$destino"
sed -i "s|container_name: proyecto_api2|container_name: "$container_name_for_filament_image"|g" "$destino"
sed -i "s|/home/juan/Documentos/proyecto_main|"$carpeta_raiz"|g" "$destino"

echo "Se termino de crear el archivo "$create_container_for_services
echo "......................................................................"

echo "Comenzando a crear la imagen para la API ...."
sudo docker-compose -f $create_container_for_services up -d

sudo docker logs -f $container_name_for_filament_image

echo "......................................................................"
echo "Se termino de levantar el servicio "$container_name_for_filament_image", sí muestra el siguiente mensaje"
echo "Setting up zip (3.0-13)"
echo "......................................................................"
echo "Eliminar el archivo $create_container_for_services ...."
sudo rm $create_container_for_services