#!/bin/bash

name_project="sdac"

version_so="Versión: Sonoma 14.3"
proyecto="Proyecto: "$name_project
descripcion_proyecto="Descripción del proyecto: Crear un entorno de desarrollo para el proyecto Iglesia Adventista del Séptimo día."

echo $version_so
echo $proyecto
echo $descripcion_proyecto
echo "......................................................................"

current_username=$(whoami)
current_directory_of_the_bellesa_project=$(pwd)
name_bd="sdac"
name_of_the_mockup_database=$name_project"_mockup"

directorio_carpeta_raiz="/Users/$current_username/Documents"
carpeta_raiz=$directorio_carpeta_raiz"/proyecto_"$name_project
subcarpeta_bd=$carpeta_raiz"/bd"
subcarpeta_api=$carpeta_raiz"/api"
subcarpeta_app=$carpeta_raiz"/app"
carpeta_repositorio_api=$subcarpeta_api"/zeus-api"
carpeta_repositorio_app=$subcarpeta_app"/meca-app"
folder_to_host_the_app_repository_and_run_the_mockup=$subcarpeta_app"/mockup"
folder_to_host_the_api_repository_and_run_the_mockup=$subcarpeta_api"/mockup"

container_name_bd=$name_project"_bd"

container_name_api=$name_project"_api"
api_container_ip="192.168.20.18"

container_name_app=$name_project"_app"
container_name_install_dev_on_api=$name_project"_instalar_dependencias_en_api"
container_name_install_dev_on_app=$name_project"_instalar_dependencias_en_app"

docker_image_name_container_api="juancholll/laravel_api_macos"
api_port_number=8082
api_port_number_for_the_mockup=8083
app_port_number=8084
app_port_number_for_the_mockup=8085
port_number_for_the_user_manual=4321
database_container_ip="192.168.20.15"
root_user_password="juan"

# Paramos todos los contenedores
echo "Comenzando a parar todos los contenedores ...."

sudo docker stop $container_name_bd
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_bd
fi
sudo docker stop $container_name_app
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_app
fi
sudo docker stop $container_name_api
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_api
fi
sudo docker stop $container_name_install_dev_on_api
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_install_dev_on_api
fi
sudo docker stop $container_name_install_dev_on_app
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_install_dev_on_app
fi

echo "Se termino de parar todos los contenedores"

echo "......................................................................"

echo "Comenzar a eliminar todos los contenedores ...."

sudo docker rm $container_name_bd
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_bd
fi
sudo docker rm $container_name_app
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_app
fi
sudo docker rm $container_name_api
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_api
fi
sudo docker rm $container_name_install_dev_on_api
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_install_dev_on_api
fi
sudo docker rm $container_name_install_dev_on_app
if [ $? -ne 0 ]; then
    echo ".....El Error response from daemon: No such container"
    echo ".....Se debe a que no existe el contenedor "$container_name_install_dev_on_app
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
mkdir $folder_to_host_the_app_repository_and_run_the_mockup
mkdir $folder_to_host_the_api_repository_and_run_the_mockup

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
DEST_API_DIR=$carpeta_repositorio_api
BRANCH_NAME=$name_project"-dev"

# Comando para clonar el repositorio
git clone $REPO_API_URL $DEST_API_DIR
# Verificar si el clon fue exitoso
if [ $? -eq 0 ]; then
    echo "Repositorio clonado correctamente en $DEST_API_DIR"

    # Cambiar al directorio del repositorio
    cd $DEST_API_DIR

    # Cambiar a la rama especificada
    git checkout $BRANCH_NAME

    echo "Ahora estás en la rama $BRANCH_NAME"
else
    echo "Error al clonar el repositorio"
fi

# Variables para repositorio API, pero para ejecutar la maqueta
DEST_API_DIR=$folder_to_host_the_api_repository_and_run_the_mockup
BRANCH_NAME=$name_project"-mockup"

# Comando para clonar el repositorio
git clone $REPO_API_URL $DEST_API_DIR
# Verificar si el clon fue exitoso
if [ $? -eq 0 ]; then
    echo "Repositorio clonado correctamente en $DEST_API_DIR"

    # Cambiar al directorio del repositorio
    cd $DEST_API_DIR

    # Cambiar a la rama especificada
    git checkout $BRANCH_NAME

    echo "Ahora estás en la rama $BRANCH_NAME"
else
    echo "Error al clonar el repositorio"
fi

# Variables para repositorio APP
REPO_APP_URL="https://github.com/carlosjuanco/meca-app.git"
DEST_APP_DIR=$carpeta_repositorio_app

# Comando para clonar el repositorio
git clone $REPO_APP_URL $DEST_APP_DIR
# Verificar si el clon fue exitoso
if [ $? -eq 0 ]; then
    echo "Repositorio clonado correctamente en $DEST_APP_DIR"

    # Cambiar al directorio del repositorio
    cd $DEST_APP_DIR

    # Cambiar a la rama especificada
    git checkout $BRANCH_NAME

    echo "Ahora estás en la rama $BRANCH_NAME"
else
    echo "Error al clonar el repositorio"
fi

echo "......................................................................"
# Variables para repositorio APP, pero para ejecutar la maqueta
DEST_APP_DIR=$folder_to_host_the_app_repository_and_run_the_mockup
BRANCH_NAME=$name_project"-mockup"

# Comando para clonar el repositorio
git clone $REPO_APP_URL $DEST_APP_DIR
# Verificar si el clon fue exitoso
if [ $? -eq 0 ]; then
    echo "Repositorio clonado correctamente en $DEST_APP_DIR"

    # Cambiar al directorio del repositorio
    cd $DEST_APP_DIR

    # Cambiar a la rama especificada
    git checkout $BRANCH_NAME

    echo "Ahora estás en la rama $BRANCH_NAME"
else
    echo "Error al clonar el repositorio"
fi
echo "......................................................................"
# Volvemos a la carpeta de bellesa

# Aprendizaje: Al momento de ejecutarse este archivo, realmente si cambiamos de ruta, ya que no encontró los archivos "create_containers_for_services_.yml"
# y "run_services2.yml", pero en mi terminal me seguia mostrando que si estabamos en la ruta bellesa, entonces, para que pueda encontrar los archivos,
# vuelvo a regresar

cd $current_directory_of_the_bellesa_project
echo "......................................................................"

echo "Comenzando a crear el archivo .env en zeus-api ...."

input=$carpeta_repositorio_api"/.env.example"
out=$carpeta_repositorio_api"/.env"
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
	  		echo "DB_HOST="$database_container_ip >> $out
	  	elif [ $linea = $db_database ]; then
	  		echo "DB_DATABASE="$name_bd >> $out
	  	elif [ $linea = $db_password ]; then
	  		echo "DB_PASSWORD="$root_user_password >> $out
		else
			echo $linea >> $out
		fi
	fi
done < $input

echo "Se termino de crear el archivo .env en zeus-api"

echo "......................................................................"

echo "Comenzando a crear el archivo .env en mockup ...."

input=$folder_to_host_the_api_repository_and_run_the_mockup"/.env.example"
out=$folder_to_host_the_api_repository_and_run_the_mockup"/.env"
cp "$input" "$out"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|DB_HOST=127.0.0.1|DB_HOST="$database_container_ip"|g" "$out"
sed -i '' "s|DB_DATABASE=laravel|DB_DATABASE="$name_of_the_mockup_database"|g" "$out"
sed -i '' "s|DB_PASSWORD=|DB_PASSWORD="$root_user_password"|g" "$out"

echo "......................................................................"

echo "Comenzando a crear el archivo .env en meca-app ...."

input=$current_directory_of_the_bellesa_project"/env.env"
out=$carpeta_repositorio_app"/.env"
cp "$input" "$out"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|8081|"$api_port_number"|g" "$out"

echo "Se termino de crear el archivo .env en zeus-api"

echo "......................................................................"

echo "Comenzando a crear el archivo create_containers_for_services_$name_project.yml ...."
echo "......................................................................"
origen=$current_directory_of_the_bellesa_project"/install_services.yml"
destino=$current_directory_of_the_bellesa_project"/create_containers_for_services_"$name_project".yml"

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|iasd_mysql:|"$name_project"_mysql:|g" "$destino"
sed -i '' "s|instalar_dependencias_en_api:|"$name_project"_instalar_dependencias_en_api:|g" "$destino"
sed -i '' "s|instalar_dependencias_en_app:|"$name_project"_instalar_dependencias_en_app:|g" "$destino"
sed -i '' "s|container_name: iasd_bd|container_name: "$container_name_bd"|g" "$destino"
sed -i '' "s|/home/juan/Documentos/proyecto_iasd|$carpeta_raiz|g" "$destino"
sed -i '' "s|image: juancholll/laravel_api|image: "$docker_image_name_container_api"|g" "$destino"
sed -i '' "s|container_name: instalar_dependencias_en_api|container_name: "$container_name_install_dev_on_api"|g" "$destino"
sed -i '' "s|container_name: instalar_dependencias_en_app|container_name: "$container_name_install_dev_on_app"|g" "$destino"
sed -i '' "s|ipv4_address: 192.168.10.10|ipv4_address: 192.168.10.15|g" "$destino"
sed -i '' "s|ipv4_address: 192.168.20.10|ipv4_address: 192.168.20.15|g" "$destino"
sed -i '' "s|3307:3306|3308:3306|g" "$destino"
sed -i '' "s|ipv4_address: 192.168.20.11|ipv4_address: 192.168.20.16|g" "$destino"
sed -i '' "s|ipv4_address: 192.168.20.13|ipv4_address: 192.168.20.17|g" "$destino"

echo "Se termino de crear el archivo create_containers_for_services_$name_project.yml"
echo "......................................................................"

# Objetivo: copiar el contenido del archivo (run_services.yml) y 
echo "Comenzando a crear el archivo run_services2.yml ...."
echo "......................................................................"
origen=$current_directory_of_the_bellesa_project"/run_services.yml"
destino=$current_directory_of_the_bellesa_project"/run_services2.yml"

# Copiar el contenido del archivo de origen al archivo de destino
cp "$origen" "$destino"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|iasd_api:|"$name_project"_api:|g" "$destino"
sed -i '' "s|iasd_app:|"$name_project"_app:|g" "$destino"
sed -i '' "s|image: juancholll/laravel_api|image: "$docker_image_name_container_api"|g" "$destino"
sed -i '' "s|container_name: iasd_api|container_name: "$container_name_api"|g" "$destino"
sed -i '' "s|/home/juan/Documentos/proyecto_iasd|"$carpeta_raiz"|g" "$destino"
sed -i '' "s|container_name: iasd_app|container_name: "$container_name_app"|g" "$destino"
sed -i '' "s|ipv4_address: 192.168.20.12|ipv4_address: "$api_container_ip"|g" "$destino"
sed -i '' "s|puertoAfueraAPI1:puertoAdentroAPI1|"$api_port_number":82|g" "$destino"
sed -i '' "s|puertoAfueraAPI2:puertoAdentroAPI2|"$api_port_number_for_the_mockup":83|g" "$destino"
sed -i '' "s|--host=192.168.20.12 --port=80|--host="$api_container_ip" --port=82|g" "$destino"
sed -i '' "s|--host=192.168.20.12 --port=81|--host="$api_container_ip" --port=83|g" "$destino"
sed -i '' "s|ipv4_address: 192.168.20.14|ipv4_address: 192.168.20.19|g" "$destino"
sed -i '' "s|puertoAfueraAPP1:puertoAdentroAPP1|"$app_port_number":84|g" "$destino"
sed -i '' "s|puertoAfueraAPP2:puertoAdentroAPP2|"$app_port_number_for_the_mockup":85|g" "$destino"
# Dejar abierto el puerto 4321 y en el contenedor 4321, para abrir el navegador
# y tener la documentación
sed -i '' "s|puertoAfueraAPP3:puertoAdentroAPP3|"$port_number_for_the_user_manual":4321|g" "$destino"
sed -i '' "s|npm run serve -- --port 81|npm run serve -- --port 84|g" "$destino"
sed -i '' "s|npm run serve -- --port 82|npm run serve -- --port 85|g" "$destino"

echo "Se termino de crear el archivo run_services2.yml"

echo "......................................................................"
# Objetivo: copiar cambiar el nombre de la base de datos (init.sql) y 
echo "Comenzando a modificar nombre de la base de datos init.sql ...."
echo "......................................................................"
destino=$carpeta_repositorio_api"/database/init.sql"

# Reemplazar la cadena en el archivo de destino
sed -i '' "s|nombreDeLaBaseDeDatosParaElDesarrollo|$name_bd|g" "$destino"
sed -i '' "s|nombreDeLaBaseDeDatosParaLaMaqueta|$name_of_the_mockup_database|g" "$destino"

echo "......................................................................"
echo "Comenzando a instalar los servicios ...."
sudo docker-compose -f "create_containers_for_services_"$name_project".yml" up -d
sudo docker logs -f $container_name_install_dev_on_api
echo "......................................................................"
echo "Se termino de instalar el servicio $container_name_install_dev_on_api, sí muestra el siguiente mensaje"
echo "Database\Seeders\FillInTheValuesForThePermissionsFieldSeeder ....... 2.00 ms DONE"
echo "......................................................................"
sudo docker logs -f $container_name_install_dev_on_app
echo "......................................................................"
echo "Se termino de instalar el servicio $container_name_install_dev_on_app, sí muestra el siguiente mensaje"
echo "npm notice"
echo "......................................................................"
echo "Parar el servicio $container_name_install_dev_on_api ...."
sudo docker stop $container_name_install_dev_on_api
echo "......................................................................"
echo "Parar el servicio $container_name_install_dev_on_app ...."
sudo docker stop $container_name_install_dev_on_app
echo "......................................................................"
echo "Corriendo servicios ...."
sudo docker-compose -f run_services2.yml up -d
echo "......................................................................"
sudo docker logs -f $container_name_api
sudo docker logs -f $container_name_app
echo "......................................................................"
echo "Eliminar archivo create_containers_for_services_"$name_project".yml ...."
#sudo rm "create_containers_for_services_"$name_project".yml"
echo "......................................................................"
echo "Eliminar archivo run_services2.yml ...."
#sudo rm run_services2.yml
echo "......................................................................"