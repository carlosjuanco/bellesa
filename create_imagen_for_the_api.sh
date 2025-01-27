#!/bin/bash

version_so="Versión: Sonoma 14.3"
proyecto="Proyecto: main"
descripcion_proyecto="Descripción del proyecto: Base para todos los proyectos."

echo $version_so
echo $proyecto
echo $descripcion_proyecto
echo "......................................................................"

current_username=$(whoami)

directorio_carpeta_raiz="/Users/$current_username/Documents"

carpeta_raiz="/Users/$current_username/Documents/proyecto_main"
subcarpeta_api="/Users/$current_username/Documents/proyecto_main/api"

current_directory_of_the_bellesa_project=$(pwd)

# Paramos todos los contenedores
echo "Comenzando a parar todos los contenedores ...."

sudo docker stop proyecto_api2
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor iasd_bd"
fi

echo "Se termino de parar todos los contenedores"

echo "......................................................................"

echo "Comenzar a eliminar todos los contenedores ...."

sudo docker rm proyecto_api2
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor iasd_bd"
fi
echo "Se termino de eliminar todos los contenedores"

echo "......................................................................"

echo "Verificando que la carpeta proyecto_main no exista ...."

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

echo "drwxr-xr-x  5 juan juan 4096 oct 26 11:02 proyecto_main"
echo "drwxr-xr-x 3 juan juan 4096 oct 26 11:02 api"
echo "Lo importante es drwxr-xr-x"

echo "......................................................................"

echo "Los permisos de las carpetas creadas son ...."
ls -al $directorio_carpeta_raiz
ls -al $carpeta_raiz
ls -al $subcarpeta_api

echo "......................................................................"
# Objetivo: copiar el contenido del archivo (automate_image_for_api.yml) y 
# reemplazar una cadena específica ("/home/juan/Documentos/") con otra ("/Users/$current_username/Documents/") 
# luego escribir el resultado en un nuevo archivo (create_imagen_for_the_api2.yml).

# El comando "sed" utiliza la opción -i para editar el archivo de destino 
# en lugar de imprimir el resultado en la consola.

# La expresión regular s|/home/juan/Documentos/|/Users/$current_username/Documents/|g reemplaza la cadena "/home/juan/Documentos/" 
# con "/Users/$current_username/Documents/" de manera global (g) en el archivo de destino.

echo "Comenzando a crear el archivo create_imagen_for_the_api2.yml ...."
echo "......................................................................"
origen="$current_directory_of_the_bellesa_project/automate_image_for_api.yml"
destino="$current_directory_of_the_bellesa_project/create_imagen_for_the_api2.yml"

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|/home/juan/Documentos|/Users/$current_username/Documents|g" "$destino"

echo "Se termino de crear el archivo create_imagen_for_the_api2.yml"
echo "......................................................................"

echo "Comenzando a crear la imagen para la API ...."
docker-compose -f create_imagen_for_the_api2.yml up -d

docker logs -f proyecto_api2

echo "......................................................................"
echo "Se termino de levantar el servicio proyecto_api2, sí muestra el siguiente mensaje"
echo "Setting up zip (3.0-13)"
echo "......................................................................"
echo "Eliminar el archivo create_imagen_for_the_api2.yml ...."
rm create_imagen_for_the_api2.yml