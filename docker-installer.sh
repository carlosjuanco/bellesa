# -------------------------------------------------------------------
# Fuente: https://docs.docker.com/engine/install/debian/
# -------------------------------------------------------------------


# -------------------------------------------------------------------
# Bajar actualizaciones
# -------------------------------------------------------------------

sudo apt-get update -y

# -------------------------------------------------------------------
# Add Docker's official GPG key
# -------------------------------------------------------------------

sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# -------------------------------------------------------------------
# Add the repository to Apt sources
# -------------------------------------------------------------------

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
# La linea anterior me muestra como escribir en mas de una linea con
# el comando echo y asignarlo a un archivo

# -------------------------------------------------------------------
# Add the repository to Apt sources
# -------------------------------------------------------------------

VERSION_STRING=5:26.0.0-1~debian.12~bookworm
sudo apt install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin -y

# -------------------------------------------------------------------
# Iniciar el servicio de doker
# -------------------------------------------------------------------

sudo systemctl start docker

# -------------------------------------------------------------------
# Mostrar la versión de docker
# -------------------------------------------------------------------

sudo docker -v

# -------------------------------------------------------------------
# Verificar que la instalación se haya realizado correctamente
# ejecutando la imagen hello-world
# -------------------------------------------------------------------

sudo docker run hello-world

# -------------------------------------------------------------------
# Instalar docker-compose
# -------------------------------------------------------------------
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version