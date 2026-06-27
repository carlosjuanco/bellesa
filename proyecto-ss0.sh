#!/bin/bash

# =============================================================================
# CONFIGURACIÓN
# =============================================================================
OS_TYPE=""

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
            exit 0
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
        exit 1
    else
        print_info "Docker desinstalado correctamente"
        exit 0
    fi
}

# =============================================================================
# 3. PROCESAR ARCHIVO DE CONTROL DE IPS
# =============================================================================

process_control_file() {
    print_header "PROCESANDO CONTROL DE IPs"
    
    CONTROL_FILE="ControlDeIpsDeContenedoresEnDocker.pdf"
    
    if [ ! -f "$CONTROL_FILE" ]; then
        print_warning "No se encontró el archivo $CONTROL_FILE"
        print_info "Se usará una configuración por defecto"
        setup_default_environment
        return
    fi
    
    print_info "Archivo encontrado: $CONTROL_FILE"
    
    # Extraer información del PDF (requiere pdftotext o similar)
    if command -v pdftotext &> /dev/null; then
        print_info "Extrayendo datos del PDF..."
        pdftotext -layout "$CONTROL_FILE" /tmp/control_temp.txt
        parse_control_data
    else
        print_warning "pdftotext no instalado. Instalando..."
        sudo apt-get install -y poppler-utils
        if command -v pdftotext &> /dev/null; then
            pdftotext -layout "$CONTROL_FILE" /tmp/control_temp.txt
            parse_control_data
        else
            print_error "No se pudo instalar pdftotext"
            setup_default_environment
        fi
    fi
}

parse_control_data() {
    if [ -f /tmp/control_temp.txt ]; then
        print_info "Datos extraídos del control de IPs"
        
        # Extraer proyectos y servicios (simplificado para ejemplo)
        # En un caso real, se parsearía el archivo de texto extraído
        
        # Ejemplo de parseo para los proyectos detectados
        PROJECTS=$(grep -E "(MAIN|SDAC|filament|SS0|AOG)" /tmp/control_temp.txt | cut -d' ' -f1 | sort -u)
        
        print_success "Proyectos encontrados:"
        for project in $PROJECTS; do
            echo "  - $project"
        done
        
        # Mostrar IPs por rango
        echo ""
        print_info "Resumen de IPs por rango:"
        echo "  RED 192.168.10.x:"
        grep "192.168.10" /tmp/control_temp.txt | awk '{print "    - " $1 ": " $2}' | sort -u
        echo "  RED 192.168.20.x:"
        grep "192.168.20" /tmp/control_temp.txt | awk '{print "    - " $1 ": " $2}' | sort -u
        
        # Limpiar
        rm -f /tmp/control_temp.txt
    fi
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
    echo "  5) Todos los entornos"
    echo "  6) Salir"
    echo ""
    read -p "Ingrese su opción [1-6]: " ENVIRONMENT_CHOICE
    
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
            deploy_environment "all"
            ;;
        6)
            print_info "Saliendo..."
            exit 0
            ;;
        *)
            print_error "Opción inválida"
            setup_environment
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
            # Puertos externos: 8080-8083, 8484-8487, etc.
            deploy_compose_files "maqueta"
            ;;
        "desarrollo")
            print_info "Configurando entorno para desarrollo"
            # Configuración para desarrollo
            # Puertos externos: 80-83, 84-87, etc.
            deploy_compose_files "desarrollo"
            ;;
        "manual_usuario")
            print_info "Configurando entorno para manual de usuario"
            # Configuración para manual de usuario
            # Puertos externos: 4321, 4322
            deploy_compose_files "manual_usuario"
            ;;
        "produccion")
            print_info "Configurando entorno para producción"
            # Configuración para producción
            deploy_compose_files "produccion"
            ;;
        "all")
            print_info "Levantando todos los entornos"
            deploy_all_environments
            ;;
        *)
            print_error "Entorno desconocido"
            return 1
            ;;
    esac
}

deploy_compose_files() {
    local env=$1
    
    # Aquí se crearían los archivos docker-compose para cada proyecto
    # Basado en los datos del control de IPs
    
    print_info "Creando archivos docker-compose para $env"
    
    # Crear directorio de configuración
    mkdir -p docker_configs
    
    # Ejemplo de creación de compose para MAIN
    cat > docker_configs/docker-compose-main-${env}.yml << EOF
version: '3.8'

services:
  main_bd:
    image: mysql:8.0
    container_name: main_bd_${env}
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: main_db
    ports:
      - "3306:3306"
    networks:
      main_network:
        ipv4_address: 192.168.10.10

  main_api:
    image: main_api:latest
    container_name: main_api_${env}
    ports:
      - "80${env:+0}$(get_env_suffix $env):8080"
    networks:
      main_network:
        ipv4_address: 192.168.20.12

  main_app:
    image: main_app:latest
    container_name: main_app_${env}
    ports:
      - "82${env:+0}$(get_env_suffix $env):8080"
    networks:
      main_network:
        ipv4_address: 192.168.20.14

networks:
  main_network:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.20.0/24
EOF

    print_success "Archivo docker-compose creado para MAIN en $env"
    
    # Similar para otros proyectos (SDAC, Filament, SS0, AOG)
    create_compose_for_project "sdac" "$env"
    create_compose_for_project "filament" "$env"
    create_compose_for_project "ss0" "$env"
    create_compose_for_project "aog" "$env"
}

get_env_suffix() {
    local env=$1
    case $env in
        "maqueta") echo "m" ;;
        "desarrollo") echo "d" ;;
        "manual_usuario") echo "u" ;;
        "produccion") echo "p" ;;
        *) echo "" ;;
    esac
}

create_compose_for_project() {
    local project=$1
    local env=$2
    
    # Simplificado - en la práctica se crearían todos los servicios
    cat > docker_configs/docker-compose-${project}-${env}.yml << EOF
version: '3.8'

services:
  ${project}_bd:
    image: mysql:8.0
    container_name: ${project}_bd_${env}
    ports:
      - "3307:3306"
    networks:
      ${project}_network:
        ipv4_address: 192.168.10.15

networks:
  ${project}_network:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.10.0/24
EOF

    print_success "Archivo docker-compose creado para ${project^^} en $env"
}

deploy_all_environments() {
    print_info "Levantando todos los entornos"
    for env in "maqueta" "desarrollo" "manual_usuario" "produccion"; do
        deploy_environment "$env"
    done
}

setup_default_environment() {
    print_warning "Usando configuración por defecto"
    print_info "Creando estructura básica de docker-compose"
    
    # Crear docker-compose base
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  web:
    image: nginx:alpine
    container_name: web_default
    ports:
      - "8080:80"
    networks:
      - default_network

  db:
    image: mysql:8.0
    container_name: db_default
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: default_db
    ports:
      - "3306:3306"
    networks:
      - default_network

networks:
  default_network:
    driver: bridge
EOF
    
    print_success "Archivo docker-compose por defecto creado"
}

# =============================================================================
# 5. VERIFICACIÓN FINAL
# =============================================================================

final_check() {
    print_header "VERIFICACIÓN FINAL"
    
    # Verificar que Docker esté funcionando
    if sudo docker ps &> /dev/null; then
        print_success "Docker está funcionando correctamente"
    else
        print_warning "Docker no está respondiendo. Reiniciando..."
        sudo systemctl restart docker
        if sudo docker ps &> /dev/null; then
            print_success "Docker reiniciado correctamente"
        else
            print_error "Docker no funciona. Verifique manualmente"
        fi
    fi
    
    # Verificar docker-compose
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version)
        print_success "Docker Compose: $COMPOSE_VERSION"
    elif docker compose version &> /dev/null; then
        COMPOSE_VERSION=$(docker compose version)
        print_success "Docker Compose: $COMPOSE_VERSION (plugin)"
    else
        print_warning "Docker Compose no encontrado"
    fi
    
    print_success "Entorno listo para usar"
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
    process_control_file
    echo ""
    setup_environment
    echo ""
    final_check
    
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