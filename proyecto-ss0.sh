#!/bin/bash

# =============================================================================
# CONFIGURACIÓN
# =============================================================================
OS_TYPE=""
OS_PRETTY_NAME=""

PROJECT=""
PROJECT_DESCRIPTION=""
IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK=""
IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK=""
PORT_OUTSIDE_THE_DATABASE_CONTAINER=""
IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API=""
IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP=""
IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV=""
IP_ADDRESS_OF_THE_API_CONTAINER_FOR_THE_MOCKUP=""
PORT_OUTSIDE_CONTAINER_API_FOR_DEV=""
PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP=""
IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV=""
IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_THE_MOCKUP=""
PORT_OUTSIDE_CONTAINER_APP_FOR_DEV=""
PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP=""

DATABASE_PASSWORD=""
CURRENT_DIR=""
BASE_DIR=""
IMAGE_NAME=""
DOCKER_CONFIGURATION_FILE=""
TEMPLATE_FOR_CREATING_BASH_FILE=""
CREATE_A_DEVELOPMENT_ENVIRONMENT=""

# =============================================================================
# Script: deploy_docker_environment.sh
# Descripción: Identifica SO, instala Docker y levanta entornos según
#              ControlDeIpsDeContenedoresEnDocker.pdf
# Versión: 1.0
# =============================================================================

set -e  # Salir en caso de error

# Colores para mejor visualización
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# FUNCIONES AUXILIARES
# =============================================================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# =============================================================================
# 1. IDENTIFICAR SISTEMA OPERATIVO Y VERSIÓN
# =============================================================================

identify_os() {
    print_header "INFORMACIÓN DEL SISTEMA"

: <<'EXPLICACION_UNAME'
    === IDENTIFICACIÓN DEL SISTEMA OPERATIVO CON UNAME ===
    uname -s: Muestra el nombre del kernel
    - Linux: Linux
    - Darwin: macOS
    - MINGW*: Windows (Git Bash)
    - CYGWIN*: Windows (Cygwin)
EXPLICACION_UNAME

    # Detectar sistema operativo con uname
    OS_KERNEL=$(uname -s)

    if [[ "$OS_KERNEL" == "Linux" ]]; then
        OS_TYPE="linux"
        
        # En español complejo: verifica si el archivo /etc/os-release existe en tu sistema, 
        # y si existe, lo "importa" o "ejecuta" para que las variables que contiene estén
        # disponibles en tu script.

        # .: Este es el comando source en Bash. Es un comando incorporado que lee y ejecuta
        # el contenido de un archivo en el entorno de la shell actual.

        # En español: "Si el archivo /etc/os-release existe, entonces haz lo siguiente..."
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS_NAME=$ID
            OS_VERSION=$VERSION_ID
            OS_CODENAME=$VERSION_CODENAME
            OS_PRETTY_NAME=$PRETTY_NAME            
        fi
        
    elif [[ "$OS_KERNEL" == "Darwin" ]]; then
        OS_TYPE="macOS"
        
        OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
        OS_CODENAME=$(sw_vers -productName 2>/dev/null || echo "macOS")
        OS_PRETTY_NAME="macOS $OS_VERSION"
        
    else
        echo "Error: Sistema operativo '$OS_KERNEL' no soportado"
        exit 1
    fi

    # Mostrar información
    print_info "Tipo: $OS_TYPE"
    print_info "Kernel: $OS_KERNEL"
    print_info "Versión: $OS_VERSION"
    print_info "Nombre: $OS_PRETTY_NAME"
    [[ -n "$OS_CODENAME" ]] && echo "Codename: $OS_CODENAME"
}

# =============================================================================
# 2. VERIFICAR/INSTALAR DOCKER/DESINSTALAR DOCKER
# =============================================================================

check_docker() {
    print_header "VERIFICANDO DOCKER"
    
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | sed 's/,//')
        print_success "Docker ya está instalado: $DOCKER_VERSION"

        if [[ "$OS_TYPE" == "linux" ]]; then 
            print_info "¿Deseas desinstalar Docker?"
            read -p "Ingrese si o no: " UNINSTALL_DOCKER
            
            case $UNINSTALL_DOCKER in
                si)
                    uninstall_docker
                    check_docker
                    ;;
            esac
        fi

        return 0
    else
        print_warning "Docker no está instalado"
        if [[ "$OS_TYPE" == "linux" ]]; then 
            install_docker
        elif [[ "$OS_TYPE" == "macOS" ]]; then
            print_warning "Tienes que instalarlo desde la página oficial"
            print_warning "Es el único sistema operativo que funciona bien su versión de escritorio"
            exit 1
        fi
    fi
}

install_docker() {
    print_header "INSTALANDO DOCKER"
        
    # Instalar dependencias
    print_info "Instalando dependencias..."
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl
    
    # Configurar GPG key
    print_info "Configurando GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # Configurar repositorio
    print_info "Configurando repositorio Docker..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Actualizar e instalar
    print_info "Instalando Docker..."
    sudo apt-get update -y
    
    # Versión específica (ajustable según necesidades)
    # Para Debian 12 Bookworm
    VERSION_STRING="5:26.0.0-1~debian.12~bookworm"
    
    sudo apt-get install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Verificar instalación
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | sed 's/,//')
        print_success "Docker instalado correctamente: $DOCKER_VERSION"
    else
        print_error "Fallo en la instalación de Docker"
        exit 1
    fi
}

uninstall_docker() {
    # Desinstalar docker solo funciona en ambientes Linux.
    # Solo en debian he probado la desinstalación de docker.

    print_info "1.- Detén todos los contenedores y servicios"

    sudo systemctl stop docker
    sudo systemctl stop docker.socket

    print_info "2.- Elimina los paquetes de Docker"
    
    sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo apt purge -y docker.io docker-compose

    print_info "3.- Elimina también dependencias no usadas"

    sudo apt autoremove -y
    sudo apt autoclean

    print_info "4.- Limpia todos los datos de Docker"

    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/docker
    sudo rm -rf /run/docker
    sudo rm -rf /var/run/docker.sock

    print_info "5.- Verifica que se desinstaló correctamente"
    
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
        print_info "Docker desinstalado correctamente"
    fi
}

# =============================================================================
# 3. PROCESAR ARCHIVO DE CONTROL DE IPS
# =============================================================================

ip_control_in_containers() {
    print_header "CONTROL DE IPS EN CONTENEDORES"
        
    # =============================================================================
    # Deberá llenarse solo en base al proyecto
    # Control De Ips De Contenedores En Docker
    # =============================================================================
    # Proyecto
    PROJECT="ss0"
    # Descripción del proyecto
    PROJECT_DESCRIPTION="Sistema web para la supervisión escolar 077"

    # IP para el contenedor de la base de datos, red interna
    IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK="192.168.10.10"
    # IP para el contenedor de la base de datos, red pública
    IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK="192.168.20.10"
    # Puerto afuera del contenedor de la base de datos
    PORT_OUTSIDE_THE_DATABASE_CONTAINER="3307"
    # IP del contenedor instalar dependencias en api
    IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API="192.168.20.11"
    # IP del contenedor instalar dependencias en app
    IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP="192.168.20.12"
    # IP del contenedor API para DEV
    IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV="192.168.20.13"
    # IP del contenedor API para la maqueta
    IP_ADDRESS_OF_THE_API_CONTAINER_FOR_THE_MOCKUP="192.168.20.13"
    # Puerto afuera del contenedor API para DEV
    PORT_OUTSIDE_CONTAINER_API_FOR_DEV="8080"
    # Puerto afuera del contenedor API para la maqueta
    PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP="8081"
    # IP del contenedor APP para DEV
    IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV="192.168.20.14"
    # IP del contenedor APP para la maqueta
    IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_THE_MOCKUP="192.168.20.14"
    # Puerto afuera del contenedor APP para DEV
    PORT_OUTSIDE_CONTAINER_APP_FOR_DEV="8082"
    # Puerto afuera del contenedor APP para la maqueta
    PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP="8083"

    # Puerto dentro del contenedor APP para DEV
    PORT_INSIDE_CONTAINER_APP_FOR_DEV="82"
    # Puerto afuera del contenedor APP para la maqueta
    PORT_INSIDE_CONTAINER_APP_FOR_MOCKUP="83"

    # =============================================================================
    # Hasta aquí en el futuro debe llenarse automaticamente en base al proyecto
    # Control De Ips De Contenedores En Docker
    # =============================================================================

    # Contraseña de la base de datos
    DATABASE_PASSWORD="juan"

    # Rutas del sistema
    readonly CURRENT_DIR=$(pwd)
    BASE_DIR=${CURRENT_DIR/bellesa/proyecto_$PROJECT} # Reemplazar la primera coincidencia
    print_info $BASE_DIR

    if [[ "$OS_TYPE" == "linux" ]]; then 
        # Si estamos en el servidor VPS
        if echo "$CURRENT_DIR" | grep -q "Documentos"; then
            print_info "La palabra 'Documentos' existe, estamos en una computadora normal con Linux"
            DOCKER_CONFIGURATION_FILE=${CURRENT_DIR/Documentos\/bellesa/.docker/config.json}
        else
            print_info "La palabra 'Documentos' NO existe, estamos en un servidor sin entorno de escritorio"
            DOCKER_CONFIGURATION_FILE=${CURRENT_DIR/bellesa/.docker/config.json}
        fi

        print_info $DOCKER_CONFIGURATION_FILE  
        # Nombre de la imagen
        IMAGE_NAME="juancholll/laravel_api_debian:1.0.0"
    elif [[ "$OS_TYPE" == "macOS" ]]; then
        DOCKER_CONFIGURATION_FILE=${CURRENT_DIR/Documents\/bellesa/.docker/config.json}
        print_info $DOCKER_CONFIGURATION_FILE  

        # Nombre de la imagen
        IMAGE_NAME="juancholll/laravel_api_macos:1.0.0"
    fi

    TEMPLATE_FOR_CREATING_BASH_FILE="$CURRENT_DIR/create-a-development-environment.txt"
    CREATE_A_DEVELOPMENT_ENVIRONMENT="$CURRENT_DIR/create-a-development-environment.sh"
}

# =============================================================================
# 4. GESTIÓN DE ENTORNOS
# =============================================================================

setup_environment() {
    print_header "SELECCIONAR ENTORNO A LEVANTAR"
    
    echo "Seleccione el entorno que desea levantar:"
    echo "  1) Entorno para maqueta (prototipo)"
    echo "  2) Entorno para desarrollo de software"
    echo "  3) Entorno para manual de usuario"
    echo "  4) Entorno para producción"
    echo "  5) Salir"
    echo ""
    read -p "Ingrese su opción [1-5]: " ENVIRONMENT_CHOICE
    
    case $ENVIRONMENT_CHOICE in
        1)
            deploy_environment "maqueta"
            ;;
        2)
            deploy_environment "desarrollo"
            ;;
        3)
            deploy_environment "manual_usuario"
            ;;
        4)
            deploy_environment "produccion"
            ;;
        5)
            print_info "Saliendo..."
            exit 0
            ;;
    esac
}

deploy_environment() {
    local env_type=$1
    
    print_header "LEVANTANDO ENTORNO: $env_type"
    
    # En función del entorno, configurar diferentes parámetros
    case $env_type in
        "maqueta")
            print_info "Configurando entorno para maqueta"
            # Configuración para maqueta
            deploy_bash_file "maqueta"
            ;;
        "desarrollo")
            print_info "Configurando entorno para desarrollo"
            # Configuración para desarrollo
            deploy_bash_file "desarrollo"
            ;;
        "manual_usuario")
            print_info "Configurando entorno para manual de usuario"
            # Configuración para manual de usuario
            deploy_bash_file "manual_usuario"
            ;;
        "produccion")
            print_info "Configurando entorno para producción"
            # Configuración para producción
            deploy_bash_file "produccion"
            ;;
    esac
}

deploy_bash_file() {
    local env_type=$1
    
    print_header "CREANDO ARHIVO: create-a-development-environment.sh"
    
    # En función del entorno, configurar diferentes parámetros
    case $env_type in
        "maqueta")
            if [ ! -f "$TEMPLATE_FOR_CREATING_BASH_FILE" ]; then
                print_error "Archivo de entrada no encontrado: $TEMPLATE_FOR_CREATING_BASH_FILE"
                return 1
            fi
            
            cp "$TEMPLATE_FOR_CREATING_BASH_FILE" "$CREATE_A_DEVELOPMENT_ENVIRONMENT"
            
            if [[ "$OS_TYPE" == "linux" ]]; then 
                SED_INLINE="-i"
            elif [[ "$OS_TYPE" == "macOS" ]]; then
                SED_INLINE="-i ''"
            fi

            # Construir el comando sed
            SED_CMD="sed $SED_INLINE"

            $SED_CMD \
                -e "s|{{ PROJECT_NAME }}|'$PROJECT'|g" \
                -e "s|{{ PROJECT_DESCRIPTION }}|'$PROJECT_DESCRIPTION'|g" \
                -e "s|{{ OS_VERSION }}|'$OS_PRETTY_NAME'|g" \
                -e "s|{{ BASE_DIR }}|'$BASE_DIR'|g" \
                -e "s|{{ DOCKER_CONFIGURATION_FILE }}|'$DOCKER_CONFIGURATION_FILE'|g" \
                -e "s|{{ DB_ROOT_PASSWORD }}|'$DATABASE_PASSWORD'|g" \
                -e "s|{{ DB_CONTAINER_IP_WEB_NETWORK }}|'$IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK'|g" \
                -e "s|{{ DB_CONTAINER_IP_INTERNAL_NETWORK }}|'$IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK'|g" \
                -e "s|{{ DB_PORT }}|$PORT_OUTSIDE_THE_DATABASE_CONTAINER|g" \
                -e "s|{{ API_IMAGE }}|'$IMAGE_NAME'|g" \
                -e "s|{{ API_CONTAINER_IP }}|'$IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV'|g" \
                -e "s|{{ API_CONTAINER_INSTALL_DEPENDENCIES_IP }}|'$IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API'|g" \
                -e "s|{{ API_PORT }}|$PORT_OUTSIDE_CONTAINER_API_FOR_DEV|g" \
                -e "s|{{ API_MOCKUP_PORT }}|$PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP|g" \
                -e "s|{{ APP_CONTAINER_IP }}|'$IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV'|g" \
                -e "s|{{ APP_CONTAINER_INSTALL_DEPENDENCIES_IP }}|'$IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP'|g" \
                -e "s|{{ APP_PORT }}|$PORT_OUTSIDE_CONTAINER_APP_FOR_DEV|g" \
                -e "s|{{ APP_MOCKUP_PORT }}|$PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP|g" \
                -e "s|{{ APP_PORT_INTERNAL }}|$PORT_INSIDE_CONTAINER_APP_FOR_DEV|g" \
                -e "s|{{ APP_MOCKUP_PORT_INTERNAL }}|$PORT_INSIDE_CONTAINER_APP_FOR_MOCKUP|g" \
                "$CREATE_A_DEVELOPMENT_ENVIRONMENT"
            
            print_success "Archivo creado: $CREATE_A_DEVELOPMENT_ENVIRONMENT"
            ;;
        "desarrollo")
            print_info "Configurando entorno para desarrollo"
            # Configuración para desarrollo
            deploy_bash_file "desarrollo"
            ;;
        "manual_usuario")
            print_info "Configurando entorno para manual de usuario"
            # Configuración para manual de usuario
            deploy_bash_file "manual_usuario"
            ;;
        "produccion")
            print_info "Configurando entorno para producción"
            # Configuración para producción
            deploy_bash_file "produccion"
            ;;
    esac
}

# =============================================================================
# 6. FUNCIÓN PRINCIPAL (MAIN)
# =============================================================================

main() {
    print_header "DEPLOYMENT DE ENTORNO DOCKER"
    print_info "Iniciando configuración del entorno de desarrollo"
    echo ""
    
    # Ejecutar en orden
    identify_os
    echo ""
    check_docker
    echo ""
    ip_control_in_containers
    echo ""
    setup_environment
    
    print_header "¡CONFIGURACIÓN COMPLETADA!"
    print_info "Para ver los contenedores en ejecución: docker ps"
    print_info "Para detener todos los contenedores: docker compose down"
    echo ""
}

# =============================================================================
# EJECUCIÓN
# =============================================================================

: <<'EXPLICACION_EUID'
    Verificar que se ejecute como usuario normal (no root)

    Verifica si el script se está ejecutando con privilegios de superusuario (root).
    Si es así, muestra una advertencia y detiene la ejecución del script para evitar
    que se ejecute como root.

    Aprendiendo Paso a Paso

    Vamos a desglosar cada parte para que entiendas perfectamente qué está pasando:

    1. if [[ $EUID -eq 0 ]]; then

    if: Inicia una estructura condicional.
    [[ ... ]]: Es una construcción de Bash para evaluar condiciones. Es más potente y seguro que los corchetes simples [ ... ].
    $EUID: Es una variable de entorno especial en Linux/Unix que contiene el ID de usuario efectivo del proceso que está ejecutando el script.

    EUID significa Effective User ID.
    Si el script lo ejecuta root, el valor de $EUID es 0.
    Si lo ejecuta un usuario normal (como "juan", "maria"), $EUID tiene un número diferente (ej. 1000, 1001, etc.).
    -eq 0: Es un operador de comparación numérica que significa "es igual a 0".
    then: Marca el comienzo del bloque de código que se ejecutará si la condición es verdadera (es decir, si $EUID es igual a 0, lo que significa que el usuario es root).
EXPLICACION_EUID

if [[ $EUID -eq 0 ]]; then
    print_warning "Ejecutando como root. Se recomienda ejecutar como usuario normal"
    exit 1
fi

# Ejecutar script
main