#!/bin/bash

name_project="filament"

version_so="Versión: Debian 12.7"
proyecto="Proyecto: "$name_project
descripcion_proyecto="Descripción del proyecto: Base de filament para los siguientes proyecto."

echo $version_so
echo $proyecto
echo $descripcion_proyecto
echo "......................................................................"

current_username=$(whoami)
current_directory_of_the_bellesa_project=$(pwd)
name_bd="filament"

directory_name_project="proyecto_"$name_project
directory_name_laravelwithfilament="laravelwithfilament"
directory_name_full_stack="fullstack"

directorio_carpeta_raiz="/home/$current_username/Documentos"
carpeta_raiz=$directorio_carpeta_raiz"/"$directory_name_project
subcarpeta_bd=$carpeta_raiz"/bd"
full_stack_subfolder=$carpeta_raiz"/"$directory_name_full_stack
repository_folder_laravelwithfilament=$full_stack_subfolder"/"$directory_name_laravelwithfilament

container_name_bd=$name_project"_bd"
container_name_full_stack=$name_project"_"$directory_name_full_stack
container_name_install_dev_on_full_stack=$name_project"_instalar_dependencias_en_full_stack"

docker_image_name_container_api="juancholll/laravel_filament_debian"
create_container_for_services="create_containers_for_"$name_project"_services.yml"

# Paramos todos los contenedores
echo "Comenzando a parar todos los contenedores ...."

sudo docker stop $container_name_bd
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_bd
fi

sudo docker stop $container_name_full_stack
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_full_stack
fi

sudo docker stop $container_name_install_dev_on_full_stack
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_install_dev_on_full_stack
fi

echo "Se termino de parar todos los contenedores"

echo "......................................................................"

echo "Comenzar a eliminar todos los contenedores ...."

sudo docker rm $container_name_bd
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_bd
fi

sudo docker rm $container_name_full_stack
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_full_stack
fi

sudo docker rm $container_name_install_dev_on_full_stack
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_install_dev_on_full_stack
fi

echo "Se termino de eliminar todos los contenedores"

echo "......................................................................"

echo "Verificando que la carpeta "$directory_name_project" no exista ...."

if [ -d "$carpeta_raiz" ]; then
	echo "La carpeta existe $carpeta_raiz, comenzando a borrar ...."
	sudo rm -r $carpeta_raiz
fi

echo "......................................................................"

echo "Comenzando a crear las carpetas ...."

mkdir $carpeta_raiz
mkdir $subcarpeta_bd
mkdir $full_stack_subfolder
mkdir $repository_folder_laravelwithfilament

echo "Se termino de crear las carpetas"

tree $carpeta_raiz

echo "......................................................................"

echo "Estos eran los permisos cuando creaba las carpetas en el explorador de archivo ...."

echo "drwxr-xr-x  5 juan juan 4096 oct 26 11:02 "$directory_name_project
echo "drwxr-xr-x 3 juan juan 4096 oct 26 11:02 "$subcarpeta_bd
echo "drwxr-xr-x 8  999 juan 4096 oct 26 11:07 "$full_stack_subfolder
echo "drwxr-xr-x 8  999 juan 4096 oct 26 11:07 "$repository_folder_laravelwithfilament
echo "Lo importante es drwxr-xr-x"

echo "......................................................................"

echo "Los permisos de las carpetas creadas son ...."
ls -al $directorio_carpeta_raiz
ls -al $carpeta_raiz
ls -al $full_stack_subfolder

echo "......................................................................"

echo "Comenzando a clonar los repositorios ...."

# Variables para repositorio LARAVELWITHFILAMENT
REPO_API_URL="https://github.com/carlosjuanco/laravelwithfilament.git"
DEST_API_DIR=$repository_folder_laravelwithfilament

# Comando para clonar el repositorio
git clone $REPO_API_URL $DEST_API_DIR

# Mensaje de confirmación
echo "Repositorio clonado en $DEST_API_DIR"

echo "......................................................................"

echo "Comenzando a crear el archivo .env en laravelwithfilament ...."

input=$repository_folder_laravelwithfilament"/.env.example"
out=$repository_folder_laravelwithfilament"/.env"
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
echo "Comenzando a crear el archivo $create_container_for_services ...."
echo "......................................................................"

origen=$current_directory_of_the_bellesa_project"/install_services.yml"
destino=$current_directory_of_the_bellesa_project"/"$create_container_for_services

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
ed -i "s|iasd_mysql:|"$name_project"_mysql:|g" "$destino"
sed -i "s|instalar_dependencias_en_api:|"$container_name_install_dev_on_full_stack":|g" "$destino"
sed -i "s|container_name: iasd_bd|container_name: "$container_name_bd"|g" "$destino"
sed -i "s|/home/juan/Documentos/proyecto_iasd|"$carpeta_raiz"|g" "$destino"
sed -i "s|image: juancholll/laravel_api|image: "$docker_image_name_container_api"|g" "$destino"
sed -i "s|container_name: instalar_dependencias_en_api|container_name: "$container_name_install_dev_on_full_stack"|g" "$destino"
sed -i "s|/api|/"$directory_name_full_stack"|g" "$destino"
sed -i "s|zeus-api|"$directory_name_laravelwithfilament"|g" "$destino"
sed -i "s|ipv4_address: 192.168.10.10|ipv4_address: 192.168.10.20|g" "$destino"
sed -i "s|ipv4_address: 192.168.20.10|ipv4_address: 192.168.20.20|g" "$destino"
sed -i "s|3307:3306|3309:3306|g" "$destino"
sed -i "s|ipv4_address: 192.168.20.11|ipv4_address: 192.168.20.21|g" "$destino"

echo "Se termino de crear el archivo "$create_container_for_services
echo "......................................................................"
# Objetivo: copiar el contenido del archivo (run_services.yml) y 
echo "Comenzando a crear el archivo run_services2.yml ...."
echo "......................................................................"

origen=$current_directory_of_the_bellesa_project"/run_services.yml"
destino=$current_directory_of_the_bellesa_project"/run_services2.yml"

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i "s|iasd_api:|"$name_project"_api:|g" "$destino"
sed -i "s|image: juancholll/laravel_api|image: "$docker_image_name_container_api"|g" "$destino"
sed -i "s|container_name: iasd_api|container_name: "$container_name_full_stack"|g" "$destino"
sed -i "s|/home/juan/Documentos/proyecto_iasd|"$carpeta_raiz"|g" "$destino"
sed -i "s|/api|/"$directory_name_full_stack"|g" "$destino"
sed -i "s|zeus-api|"$directory_name_laravelwithfilament"|g" "$destino"
sed -i "s|ipv4_address: 192.168.20.12|ipv4_address: 192.168.20.22|g" "$destino"
sed -i "s|8080:80|8084:84|g" "$destino"
sed -i "s|--host=192.168.20.12 --port=80|--host=192.168.20.22 --port=84|g" "$destino"

echo "Se termino de crear el archivo run_services2.yml"
echo "......................................................................"

echo "Comenzando a instalar los servicios ...."
sudo docker-compose -f $create_container_for_services up -d
sudo docker logs -f $container_name_install_dev_on_full_stack
echo "......................................................................"
echo "Se termino de instalar el servicio "$container_name_install_dev_on_full_stack", sí muestra el siguiente mensaje"
echo "INFO  Seeding database."
echo "......................................................................"
echo "Parar el servicio "$container_name_install_dev_on_full_stack" ...."
sudo docker stop $container_name_install_dev_on_full_stack
echo "......................................................................"
echo "Corriendo servicios ...."
sudo docker-compose -f run_services2.yml up -d
echo "......................................................................"
sudo docker logs -f $container_name_full_stack
echo "......................................................................"
echo "Eliminar archivo $create_container_for_services ...."
sudo rm $create_container_for_services
echo "......................................................................"
echo "Eliminar archivo run_services2.yml ...."
sudo rm run_services2.yml
echo "......................................................................"