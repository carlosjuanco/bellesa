#!/bin/bash

sistema_operativo="Sistema operativo: Windows"
version_so="Versión: 11"
fecha="Fecha: 19 de diciembre del 2024"
proyecto="Proyecto: iasd"
descripcion_proyecto="Descripción del proyecto: Proyecto iglesia adventista del séptimo día"

echo $sistema_operativo
echo $version_so
echo $fecha
echo $proyecto
echo $descripcion_proyecto
echo "......................................................................"

current_username=$(whoami)

directorio_carpeta_raiz="/home/$current_username/Documentos"

carpeta_raiz="/home/$current_username/Documentos/proyecto_iasd"

subcarpeta_bd="/home/$current_username/Documentos/proyecto_iasd/bd"
subcarpeta_api="/home/$current_username/Documentos/proyecto_iasd/api"
subcarpeta_app="/home/$current_username/Documentos/proyecto_iasd/app"
carpeta_repositorio_api="/home/$current_username/Documentos/proyecto_iasd/api/zeus-api"
carpeta_repositorio_app="/home/$current_username/Documentos/proyecto_iasd/app/meca-app"

# Paramos todos los contenedores
echo "Comenzando a parar todos los contenedores ...."

sudo docker stop iasd_bd
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor iasd_bd"
fi
sudo docker stop iasd_app
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor iasd_app"
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
sudo docker stop iasd_api
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor iasd_api"
fi

echo "Se termino de parar todos los contenedores"

echo "......................................................................"

echo "Comenzar a eliminar todos los contenedores ...."

sudo docker rm iasd_bd
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor iasd_bd"
fi
sudo docker rm iasd_app
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor iasd_app"
fi
sudo docker rm iasd_api
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor iasd_api"
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

echo "Verificando que la carpeta proyecto_iasd no exista ...."

if [ -d "$carpeta_raiz" ]; then
	echo "La carpeta exite $carpeta_raiz, comenzando a borrar ...."
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

echo "drwxr-xr-x  5 juan juan 4096 oct 26 11:02 proyecto_iasd"
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
DEST_API_DIR="/home/$current_username/Documentos/proyecto_iasd/api/zeus-api"

# Comando para clonar el repositorio
git clone $REPO_API_URL $DEST_API_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_API_DIR"

# Variables para repositorio APP
REPO_APP_URL="https://github.com/carlosjuanco/meca-app.git"
DEST_APP_DIR="/home/$current_username/Documentos/proyecto_iasd/app/meca-app"

# Comando para clonar el repositorio
git clone $REPO_APP_URL $DEST_APP_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_APP_DIR"

echo "......................................................................"
echo "Comenzando a crear el archivo .env en zeus-api ...."

input="/home/$current_username/Documentos/proyecto_iasd/api/zeus-api/.env.example"
out="/home/$current_username/Documentos/proyecto_iasd/api/zeus-api/.env"
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
	  		echo "DB_DATABASE=iasd" >> $out
	  	elif [ $linea = $db_password ]; then
	  		echo "DB_PASSWORD=juan" >> $out
		else
			echo $linea >> $out
		fi
	fi
done < $input

echo "Se termino de crear el archivo .env en zeus-api"
echo "......................................................................"
echo "Comenzando a crear el archivo windows11_install_services.yml ...."
file_install_services_original="/home/$current_username/Documentos/bellesa/debian_up_servicios.yml"
file_install_services="/home/$current_username/Documentos/bellesa/windows11_install_services.yml"

touch $file_install_services

# Se puede asignar el contenido del archivo sin las comillas dobles, pero no se respetan los
# saltos de lineas y tabulaciones.
contenido_file_install_services_original="$(cat $file_install_services_original)"

contenido_nuevo=${contenido_file_install_services_original//"/home/juan/"/"/home/$current_username/"}

# Se puede asignar el contenido del archivo sin las comillas dobles, pero no se respetan los
# saltos de lineas y tabulaciones.
echo "$contenido_nuevo" >> "$file_install_services"

echo "Se termino de crear el archivo windows11_install_services.yml"
echo "......................................................................"
echo "Comenzando a levantar los servicios ...."
sudo docker-compose -f windows11_install_services.yml up -d
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
sudo docker-compose -f windows11_running_services.yml up -d
echo "......................................................................"
sudo docker logs -f iasd_api
sudo docker logs -f iasd_app