#!/bin/bash
# Desinstalar docker solo funciona en ambientes Linux.
# Solo en debian he probado la desinstalación de docker.

echo  "1.- Detén todos los contenedores y servicios"

sudo systemctl stop docker
sudo systemctl stop docker.socket

echo  "2.- Elimina los paquetes de Docker"

sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt purge -y docker.io docker-compose

echo  "3.- Elimina también dependencias no usadas"

sudo apt autoremove -y
sudo apt autoclean

echo  "4.- Limpia todos los datos de Docker"

sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf /run/docker
sudo rm -rf /var/run/docker.sock

echo "5.- Verifica que se desinstaló correctamente"

# Al ejecutar sudo docker --version, deberia regresar "command not found"
# Es decir hubo un error

# Sintaxis          Significado                             ¿Es correcto?
# 2> /dev/null    Redirige el stderr (error 2) a /dev/null    ✅ Correcto
# 2&> /dev/null   ❌ Sintaxis incorrecta                     ❌ Error
# &> /dev/null      Redirige stdout y stderr a /dev/null    ✅ Correcto (más simple)
# > /dev/null 2>&1  Redirige stdout y stderr a /dev/null    ✅ Correcto (tradicional)
if command -v docker &> /dev/null; then 
    print_warning "Algo paso en la desinstalación de docker"
else
    echo "Docker desinstalado correctamente"
fi