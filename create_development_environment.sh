#!/bin/bash

version_so="Versión: Sonoma 14.3"
proyecto="Proyecto: main"
descripcion_proyecto="Descripción del proyecto: Base para todos los proyectos."

echo $version_so
echo $proyecto
echo $descripcion_proyecto
echo "......................................................................"

current_username=$(whoami)

name_project="main"
name_bd="main"
directorio_carpeta_raiz="/Users/$current_username/Documents"
carpeta_raiz="/Users/$current_username/Documents/proyecto_$name_project"

subcarpeta_bd="/Users/$current_username/Documents/proyecto_$name_project/bd"
subcarpeta_api="/Users/$current_username/Documents/proyecto_$name_project/api"
subcarpeta_app="/Users/$current_username/Documents/proyecto_$name_project/app"
carpeta_repositorio_api="/Users/$current_username/Documents/proyecto_$name_project/api/zeus-api"
carpeta_repositorio_app="/Users/$current_username/Documents/proyecto_$name_project/app/meca-app"

current_directory_of_the_bellesa_project=$(pwd)

# Paramos todos los contenedores
echo "Comenzando a parar todos los contenedores ...."

sudo docker stop $name_project"_bd"
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$name_project"_bd"
fi
sudo docker stop $name_project"_app"
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$name_project"_app"
fi
sudo docker stop instalar_dependencias_en_api
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor instalar_dependencias_en_api"
fi
sudo docker stop instalar_dependencias_en_app
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor instalar_dependencias_en_app"
fi
sudo docker stop $name_project"_api"
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$name_project"_api"
fi

echo "Se termino de parar todos los contenedores"

echo "......................................................................"

echo "Comenzar a eliminar todos los contenedores ...."

sudo docker rm $name_project"_bd"
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$name_project"_bd"
fi
sudo docker rm $name_project"_app"
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$name_project"_app"
fi
sudo docker rm $name_project"_api"
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$name_project"_api"
fi
sudo docker rm instalar_dependencias_en_api
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor instalar_dependencias_en_api"
fi
sudo docker rm instalar_dependencias_en_app
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor instalar_dependencias_en_app"
fi

echo "Se termino de eliminar todos los contenedores"

echo "......................................................................"

echo "Verificando que la carpeta proyecto_"$name_project" no exista ...."

if [ -d "$carpeta_raiz" ]; then
	echo "La carpeta existe $carpeta_raiz, comenzando a borrar ...."
	sudo rm -r $carpeta_raiz
fi

echo "......................................................................"

echo "Comenzando a crear las carpetas ...."

mkdir $carpeta_raiz
mkdir $subcarpeta_bd
mkdir $subcarpeta_api
mkdir $subcarpeta_app
mkdir $carpeta_repositorio_api
mkdir $carpeta_repositorio_app

echo "Se termino de crear las carpetas"

tree $carpeta_raiz

echo "......................................................................"

echo "Estos eran los permisos cuando creaba las carpetas en el explorador de archivo ...."

echo "drwxr-xr-x  5 juan juan 4096 oct 26 11:02 proyecto_"$name_project
echo "drwxr-xr-x 3 juan juan 4096 oct 26 11:02 api"
echo "drwxr-xr-x 3 juan juan 4096 oct 26 11:02 app"
echo "drwxr-xr-x 8  999 juan 4096 oct 26 11:07 bd"
echo "drwxr-xr-x 14 juan juan 4096 oct 26 11:03 zeus-api"
echo "drwxr-xr-x 6 juan juan 4096 oct 26 11:04 meca-app"
echo "Lo importante es drwxr-xr-x"

echo "......................................................................"

echo "Los permisos de las carpetas creadas son ...."
ls -al $directorio_carpeta_raiz
ls -al $carpeta_raiz
ls -al $subcarpeta_api
ls -al $subcarpeta_app

echo "......................................................................"

echo "Comenzando a clonar los repositorios ...."

# Variables para repositorio API
REPO_API_URL="https://github.com/carlosjuanco/zeus-api.git"
DEST_API_DIR="/Users/$current_username/Documents/proyecto_$name_project/api/zeus-api"

# Comando para clonar el repositorio
git clone $REPO_API_URL $DEST_API_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_API_DIR"

# Variables para repositorio APP
REPO_APP_URL="https://github.com/carlosjuanco/meca-app.git"
DEST_APP_DIR="/Users/$current_username/Documents/proyecto_$name_project/app/meca-app"

# Comando para clonar el repositorio
git clone $REPO_APP_URL $DEST_APP_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_APP_DIR"

echo "......................................................................"

echo "Comenzando a crear el archivo .env en zeus-api ...."

input="/Users/$current_username/Documents/proyecto_$name_project/api/zeus-api/.env.example"
out="/Users/$current_username/Documents/proyecto_$name_project/api/zeus-api/.env"
touch $out
db_host="DB_HOST=127.0.0.1"
db_database="DB_DATABASE=laravel"
db_password="DB_PASSWORD="

while read linea
do
	# echo $linea
	if [ -z "$linea" ]; then
		echo $linea >> $out
	else
		if [ $linea = $db_host ]; then
	  		echo "DB_HOST=192.168.20.10" >> $out
	  	elif [ $linea = $db_database ]; then
	  		echo "DB_DATABASE="$name_bd >> $out
	  	elif [ $linea = $db_password ]; then
	  		echo "DB_PASSWORD=juan" >> $out
		else
			echo $linea >> $out
		fi
	fi
done < $input

echo "Se termino de crear el archivo .env en zeus-api"

echo "......................................................................"

# Objetivo: copiar el contenido del archivo (debian_up_servicios.yml) y 
# reemplazar una cadena específica ("/Users/juan/") con otra ("/Users/$current_username/") 
# luego escribir el resultado en un nuevo archivo (create_containers_for_services.yml).

# El comando "sed" utiliza la opción -i para editar el archivo de destino 
# en lugar de imprimir el resultado en la consola.

# La expresión regular s|/Users/juan/Documentos/|/Users/$current_username/|g reemplaza la cadena "/Users/juan/Documents" 
# con "/Users/$current_username/Documents" de manera global (g) en el archivo de destino.

echo "Comenzando a crear el archivo create_containers_for_services.yml ...."
echo "......................................................................"
origen=$current_directory_of_the_bellesa_project"/debian_up_servicios.yml"
destino=$current_directory_of_the_bellesa_project"/create_containers_for_services.yml"

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|/home/juan/Documentos/proyecto_iasd|/Users/$current_username/Documents/proyecto_$name_project|g" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|container_name: iasd_bd|container_name: "$name_project"_bd|g" "$destino"

sed -i '' "s|image: juancholll/laravel_api|image: juancholll/iasd_api|g" "$destino"

echo "Se termino de crear el archivo create_containers_for_services.yml"
echo "......................................................................"

# Objetivo: copiar el contenido del archivo (debian_run_servicios.yml) y 
echo "Comenzando a crear el archivo run_services.yml ...."
echo "......................................................................"
origen=$current_directory_of_the_bellesa_project"/debian_run_servicios.yml"
destino=$current_directory_of_the_bellesa_project"/run_services.yml"

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|/home/juan/Documentos/proyecto_iasd|/Users/$current_username/Documents/proyecto_$name_project|g" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|image: juancholll/laravel_api|image: juancholll/iasd_api|g" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|container_name: iasd_api|container_name: "$name_project"_api|g" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|container_name: iasd_app|container_name: "$name_project"_app|g" "$destino"

echo "Se termino de crear el archivo run_services.yml"
echo "......................................................................"
# Objetivo: copiar cambiar el nombre de la base de datos (init.sql) y 
echo "Comenzando a modificar nombre de la base de datos init.sql ...."
echo "......................................................................"
destino=$carpeta_repositorio_api"/database/init.sql"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|iasd|$name_bd|g" "$destino"

echo "......................................................................"
echo "Comenzando a levantar los servicios ...."
sudo docker-compose -f create_containers_for_services.yml up -d
sudo docker logs -f instalar_dependencias_en_api
echo "......................................................................"
echo "Se termino de levantar el servicio instalar_dependencias_en_api, sí muestra el siguiente mensaje"
echo "Database\Seeders\AddComponentNameInformationInVueSeeder ....... 2.00 ms DONE"
echo "......................................................................"
sudo docker logs -f instalar_dependencias_en_app
echo "......................................................................"
echo "Se termino de levantar el servicio instalar_dependencias_en_app, sí muestra el siguiente mensaje"
echo "npm notice"
echo "......................................................................"
echo "Parar el servicio instalar_dependencias_en_api ...."
sudo docker stop instalar_dependencias_en_api
echo "......................................................................"
echo "Parar el servicio instalar_dependencias_en_app ...."
sudo docker stop instalar_dependencias_en_app
echo "......................................................................"
echo "Corriendo servicios ...."
sudo docker-compose -f run_services.yml up -d
echo "......................................................................"
sudo docker logs -f iasd_api
sudo docker logs -f iasd_app
echo "......................................................................"
echo "Eliminar archivo create_containers_for_services.yml ...."
sudo rm create_containers_for_services.yml
echo "......................................................................"
echo "Eliminar archivo run_services.yml ...."
sudo rm run_services.yml
echo "......................................................................"
echo "Eliminar contenedor instalar_dependencias_en_api ...."
sudo docker rm instalar_dependencias_en_api
echo "......................................................................"
echo "Eliminar contenedor instalar_dependencias_en_app ...."
sudo docker rm instalar_dependencias_en_app
