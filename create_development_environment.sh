#!/bin/bash

name_project="filament"

version_so="Versión: Sonoma 14.3"
proyecto="Proyecto: "$name_project
descripcion_proyecto="Descripción del proyecto: Base de filament para los siguientes proyecto, bueno eso espero."

echo $version_so
echo $proyecto
echo $descripcion_proyecto
echo "......................................................................"

current_username=$(whoami)
current_directory_of_the_bellesa_project=$(pwd)
name_bd="filament"

directorio_carpeta_raiz="/Users/$current_username/Documents"
carpeta_raiz=$directorio_carpeta_raiz"/proyecto_$name_project"
subcarpeta_bd=$carpeta_raiz"/bd"
subcarpeta_all=$carpeta_raiz"/all"
carpeta_repositorio_laravelwithfilament=$subcarpeta_all"/laravelwithfilament"

container_name_bd=$name_project"_bd"
container_name_all=$name_project"_all"
container_name_install_dev_on_all=$name_project"_instalar_dependencias_en_all"
docker_image_name_container_api="juancholll/laravel_api_macos"

# Paramos todos los contenedores
echo "Comenzando a parar todos los contenedores ...."

sudo docker stop $container_name_bd
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_bd
fi

sudo docker stop $container_name_all
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_all
fi

sudo docker stop $container_name_install_dev_on_all
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_install_dev_on_all
fi

echo "Se termino de parar todos los contenedores"

echo "......................................................................"

echo "Comenzar a eliminar todos los contenedores ...."

sudo docker rm $container_name_bd
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_bd
fi

sudo docker rm $container_name_all
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_all
fi

sudo docker rm $container_name_install_dev_on_all
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_install_dev_on_all
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
mkdir $subcarpeta_all
mkdir $carpeta_repositorio_laravelwithfilament

echo "Se termino de crear las carpetas"

tree $carpeta_raiz

echo "......................................................................"

echo "Estos eran los permisos cuando creaba las carpetas en el explorador de archivo ...."

echo "drwxr-xr-x  5 juan juan 4096 oct 26 11:02 proyecto_"$name_project
echo "drwxr-xr-x 3 juan juan 4096 oct 26 11:02 all"
echo "drwxr-xr-x 8  999 juan 4096 oct 26 11:07 bd"
echo "Lo importante es drwxr-xr-x"

echo "......................................................................"

echo "Los permisos de las carpetas creadas son ...."
ls -al $directorio_carpeta_raiz
ls -al $carpeta_raiz
ls -al $subcarpeta_all
ls -al $carpeta_repositorio_laravelwithfilament

echo "......................................................................"

echo "Comenzando a clonar los repositorios ...."

# Variables para repositorio LARAVELWITHFILAMENT
REPO_API_URL="https://github.com/carlosjuanco/laravelwithfilament.git"
DEST_API_DIR=$carpeta_repositorio_laravelwithfilament

# Comando para clonar el repositorio
git clone $REPO_API_URL $DEST_API_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_API_DIR"

echo "......................................................................"

echo "Comenzando a crear el archivo .env en laravelwithfilament ...."

input=$carpeta_repositorio_laravelwithfilament"/.env.example"
out=$carpeta_repositorio_laravelwithfilament"/.env"
touch $out
db_host="DB_HOST=127.0.0.1"
db_port="DB_PORT=3306"
db_database="DB_DATABASE=laravel"
db_password="DB_PASSWORD="

while read linea
do
    # echo $linea
    if [ -z "$linea" ]; then
        echo $linea >> $out
    else
        if [ $linea = $db_host ]; then
            echo "DB_HOST=192.168.20.20" >> $out
        elif [ $linea = $db_port ]; then
            echo "DB_PORT=3306" >> $out
        elif [ $linea = $db_database ]; then
            echo "DB_DATABASE="$name_bd >> $out
        elif [ $linea = $db_password ]; then
            echo "DB_PASSWORD=juan" >> $out
        else
            echo $linea >> $out
        fi
    fi
done < $input

echo "Se termino de crear el archivo .env en laravelwithfilament"

echo "......................................................................"
# Objetivo: copiar el contenido del archivo (install_services.yml) y 
echo "Comenzando a crear el archivo create_containers_for_services.yml ...."
echo "......................................................................"

origen=$current_directory_of_the_bellesa_project"/install_services.yml"
destino=$current_directory_of_the_bellesa_project"/create_containers_for_services.yml"

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|container_name: iasd_bd|container_name: "$container_name_bd"|g" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|/home/juan/Documentos/proyecto_iasd|"$carpeta_raiz"|g" "$destino"

sed -i '' "s|image: juancholll/laravel_api|image: "$docker_image_name_container_api"|g" "$destino"
sed -i '' "s|container_name: instalar_dependencias_en_api|container_name: "$container_name_install_dev_on_all"|g" "$destino"

echo "Se termino de crear el archivo create_containers_for_services.yml"
echo "......................................................................"
# Objetivo: copiar el contenido del archivo (run_services.yml) y 
echo "Comenzando a crear el archivo run_services2.yml ...."
echo "......................................................................"

origen=$current_directory_of_the_bellesa_project"/run_services.yml"
destino=$current_directory_of_the_bellesa_project"/run_services2.yml"

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|image: juancholll/laravel_api|image: "$docker_image_name_container_api"|g" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|container_name: iasd_api|container_name: "$container_name_all"|g" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|/home/juan/Documentos/proyecto_iasd|"$carpeta_raiz"|g" "$destino"

echo "Se termino de crear el archivo run_services2.yml"
echo "......................................................................"

echo "Comenzando a instalar los servicios ...."
sudo docker-compose -f create_containers_for_services.yml up -d
sudo docker logs -f $container_name_install_dev_on_all
echo "......................................................................"
echo "Se termino de instalar el servicio "$container_name_install_dev_on_all", sí muestra el siguiente mensaje"
echo "INFO  Seeding database."
echo "......................................................................"
echo "Parar el servicio "$container_name_install_dev_on_all" ...."
sudo docker stop $container_name_install_dev_on_all
echo "......................................................................"
echo "Corriendo servicios ...."
sudo docker-compose -f run_services2.yml up -d
echo "......................................................................"
sudo docker logs -f $container_name_all
echo "......................................................................"
echo "Eliminar archivo create_containers_for_services.yml ...."
sudo rm create_containers_for_services.yml
echo "......................................................................"
echo "Eliminar archivo run_services2.yml ...."
sudo rm run_services2.yml
echo "......................................................................"