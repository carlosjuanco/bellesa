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

input="/home/juan/Documentos/proyecto_iasd/api/zeus-api/.env.example"
out="/home/juan/Documentos/proyecto_iasd/api/zeus-api/.env"
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