#!/bin/bash

# =============================================================================
# CONFIGURACIÓN
# =============================================================================
OS_TYPE=""
OS_PRETTY_NAME=""

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

# =============================================================================
# 3. PROCESAR ARCHIVO DE CONTROL DE IPS
# =============================================================================

ip_control_in_containers() {
    print_header "CONFIGURANDO PARÁMETROS DEL PROYECTO"
    print_info "Iniciando el reeemplazo de ips, puertos, rutas y contraseñas "
        
    # =============================================================================
    # Orden
    # =============================================================================
    # Proyecto
    PROJECT="$1"
    # Descripción del proyecto
    PROJECT_DESCRIPTION="$2"

    # IP para el contenedor de la base de datos, red pública
    IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK="$3"
    # IP para el contenedor de la base de datos, red interna
    IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK="$4"
    # Puerto afuera del contenedor de la base de datos
    PORT_OUTSIDE_THE_DATABASE_CONTAINER="$5"
    # IP del contenedor instalar dependencias en api
    IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API="$6"
    # IP del contenedor instalar dependencias en app
    IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP="$7"
    # IP del contenedor API para DEV
    IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV="$8"
    # IP del contenedor API para la maqueta
    IP_ADDRESS_OF_THE_API_CONTAINER_FOR_THE_MOCKUP="$9"
    # Puerto afuera del contenedor API para DEV
    PORT_OUTSIDE_CONTAINER_API_FOR_DEV="${10}"
    # Puerto afuera del contenedor API para la maqueta
    PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP="${11}"
    # IP del contenedor APP para DEV
    IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV="${12}"
    # IP del contenedor APP para la maqueta
    IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_THE_MOCKUP="${13}"
    # Puerto afuera del contenedor APP para DEV
    PORT_OUTSIDE_CONTAINER_APP_FOR_DEV="${14}"
    # Puerto afuera del contenedor APP para la maqueta
    PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP="${15}"

    # Puerto dentro del contenedor APP para DEV
    PORT_INSIDE_CONTAINER_APP_FOR_DEV="${16}"
    # Puerto afuera del contenedor APP para la maqueta
    PORT_INSIDE_CONTAINER_APP_FOR_MOCKUP="${17}"

    # =============================================================================
    # Hasta aquí
    # =============================================================================

    # Función: check_docker_auth
    # Línea original: ! docker pull hello-world > /dev/null 2>&1
    VERIFY_THAT_THE_CREDENTIALS_ARE_VALID=""
    # Contraseña de la base de datos
    DATABASE_PASSWORD="${18}"

    # Rutas del sistema
    readonly CURRENT_DIR=$(pwd)
    BASE_DIR=${CURRENT_DIR/bellesa/proyecto_$PROJECT} # Reemplazar la primera coincidencia

    if [[ "$OS_TYPE" == "linux" ]]; then 
        # Si estamos en el servidor VPS
        if echo "$CURRENT_DIR" | grep -q "Documentos"; then
            DOCKER_CONFIGURATION_FILE=${CURRENT_DIR/Documentos\/bellesa/.docker/config.json}
        else
            DOCKER_CONFIGURATION_FILE=${CURRENT_DIR/bellesa/.docker/config.json}
        fi

        # Nombre de la imagen
        IMAGE_NAME="juancholll/laravel_api_debian:1.0.0"
        # Escapar el caracter &
        VERIFY_THAT_THE_CREDENTIALS_ARE_VALID="! sudo docker pull hello-world > /dev/null 2>\&1"
    elif [[ "$OS_TYPE" == "macOS" ]]; then
        DOCKER_CONFIGURATION_FILE=${CURRENT_DIR/Documents\/bellesa/.docker/config.json}

        # Nombre de la imagen
        IMAGE_NAME="juancholll/laravel_api_macos:1.0.0"
        # Escapar el caracter &
        VERIFY_THAT_THE_CREDENTIALS_ARE_VALID="! docker pull hello-world > /dev/null 2>\&1"
    fi

    TEMPLATE_FOR_CREATING_BASH_FILE="$CURRENT_DIR/template-for-creating-bash-file.txt"
    CREATE_A_DEVELOPMENT_ENVIRONMENT="$CURRENT_DIR/create-a-development-environment.sh"

    # Mostrar configuración
    echo ""
    print_info "Configuración establecida:"
    echo "  ┌─────────────────────────────────────────────────────────────"
    echo "  │ PROYECTO: $PROJECT_NAME"
    echo "  │ DESCRIPCIÓN: $PROJECT_DESCRIPTION"
    echo "  ├─────────────────────────────────────────────────────────────"
    echo "  │ BASE DE DATOS:"
    echo "  │   IP Red Web:     $IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK"
    echo "  │   IP Red Interna: $IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK"
    echo "  │   Puerto:         $PORT_OUTSIDE_THE_DATABASE_CONTAINER"
    echo "  │   Password:       ${DATABASE_PASSWORD:0:4}****"
    echo "  ├─────────────────────────────────────────────────────────────"
    echo "  │ API:"
    echo "  │   IP del contenedor instalar dependencias:   $IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API"
    echo "  │   IP del contenedor para dev:                $IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV"
    echo "  │   Puerto DEV:                                $PORT_OUTSIDE_CONTAINER_API_FOR_DEV"
    echo "  │   Puerto Mockup:                             $PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP"
    echo "  ├─────────────────────────────────────────────────────────────"
    echo "  │ APP:"
    echo "  │   IP del contenedor instalar dependencias:   $IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP"
    echo "  │   IP del contenedor para dev:                $IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV"
    echo "  │   Puerto DEV:                                $PORT_OUTSIDE_CONTAINER_APP_FOR_DEV:$PORT_INSIDE_CONTAINER_APP_FOR_DEV"
    echo "  │   Puerto Mockup:                             $PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP:$PORT_INSIDE_CONTAINER_APP_FOR_MOCKUP"
    echo "  └─────────────────────────────────────────────────────────────"
    echo ""

    # Exportar variables para uso global
    export PROJECT
    export PROJECT_DESCRIPTION
    export IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK
    export IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK
    export PORT_OUTSIDE_THE_DATABASE_CONTAINER
    export IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API
    export IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP
    export IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV
    export IP_ADDRESS_OF_THE_API_CONTAINER_FOR_THE_MOCKUP
    export PORT_OUTSIDE_CONTAINER_API_FOR_DEV
    export PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP
    export IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV
    export IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_THE_MOCKUP
    export PORT_OUTSIDE_CONTAINER_APP_FOR_DEV
    export PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP
    export PORT_INSIDE_CONTAINER_APP_FOR_DEV
    export PORT_INSIDE_CONTAINER_APP_FOR_MOCKUP

    export VERIFY_THAT_THE_CREDENTIALS_ARE_VALID
    export DATABASE_PASSWORD
    export CURRENT_DIR
    export BASE_DIR
    export IMAGE_NAME
    export DOCKER_CONFIGURATION_FILE
    export TEMPLATE_FOR_CREATING_BASH_FILE
    export CREATE_A_DEVELOPMENT_ENVIRONMENT

    print_success "Se termino de reemplazar informacion del proyecto"
}

# ============================================================================
# FUNCIÓN: CARGAR PROYECTO DESDE ARCHIVO
# ============================================================================

load_project_from_file() {
    local project_file="$1"
    
    if [ ! -f "$project_file" ]; then
        print_error "Archivo de proyecto no encontrado: $project_file"
        return 1
    fi
    
    print_info "Cargando configuración desde: $project_file"
    
    # Leer el archivo línea por línea y extraer valores
    while IFS='=' read -r key value; do
        # Ignorar líneas vacías y comentarios
        if [[ -z "$key" ]] || [[ "$key" == \#* ]]; then
            continue
        fi
        
        # Limpiar espacios y comillas
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | sed 's/^"//;s/"$//')
        
        # Asignar variables según la clave
        case "$key" in
            "PROJECT") PROJECT_NAME="$value" ;;
            "PROJECT_DESCRIPTION") PROJECT_DESCRIPTION="$value" ;;
            "IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK") 
                IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK="$value" ;;
            "IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK") 
                IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK="$value" ;;
            "PORT_OUTSIDE_THE_DATABASE_CONTAINER") 
                PORT_OUTSIDE_THE_DATABASE_CONTAINER="$value" ;;
            "IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API") 
                IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API="$value" ;;
            "IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP") 
                IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP="$value" ;;
            "IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV") 
                IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV="$value" ;;
            "IP_ADDRESS_OF_THE_API_CONTAINER_FOR_THE_MOCKUP") 
                IP_ADDRESS_OF_THE_API_CONTAINER_FOR_THE_MOCKUP="$value" ;;
            "PORT_OUTSIDE_CONTAINER_API_FOR_DEV") 
                PORT_OUTSIDE_CONTAINER_API_FOR_DEV="$value" ;;
            "PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP") 
                PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP="$value" ;;
            "IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV") 
                IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV="$value" ;;
            "IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_THE_MOCKUP") 
                IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_THE_MOCKUP="$value" ;;
            "PORT_OUTSIDE_CONTAINER_APP_FOR_DEV") 
                PORT_OUTSIDE_CONTAINER_APP_FOR_DEV="$value" ;;
            "PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP") 
                PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP="$value" ;;
            "PORT_INSIDE_CONTAINER_APP_FOR_DEV") 
                PORT_INSIDE_CONTAINER_APP_FOR_DEV="$value" ;;
            "PORT_INSIDE_CONTAINER_APP_FOR_MOCKUP") 
                PORT_INSIDE_CONTAINER_APP_FOR_MOCKUP="$value" ;;
            "DATABASE_PASSWORD") 
                DATABASE_PASSWORD="$value" ;;
        esac
    done < "$project_file"
    
    # Llamar a ip_control_in_containers con los parámetros cargados
    ip_control_in_containers \
        "$PROJECT_NAME" \
        "$PROJECT_DESCRIPTION" \
        "$IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK" \
        "$IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK" \
        "$PORT_OUTSIDE_THE_DATABASE_CONTAINER" \
        "$IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_API" \
        "$IP_ADDRESS_OF_THE_CONTAINER_TO_INSTALL_DEPENDENCIES_IN_THE_APP" \
        "$IP_ADDRESS_OF_THE_API_CONTAINER_FOR_DEV" \
        "$IP_ADDRESS_OF_THE_API_CONTAINER_FOR_THE_MOCKUP" \
        "$PORT_OUTSIDE_CONTAINER_API_FOR_DEV" \
        "$PORT_OUTSIDE_CONTAINER_API_FOR_MOCKUP" \
        "$IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_DEV" \
        "$IP_ADDRESS_OF_THE_APP_CONTAINER_FOR_THE_MOCKUP" \
        "$PORT_OUTSIDE_CONTAINER_APP_FOR_DEV" \
        "$PORT_OUTSIDE_CONTAINER_APP_FOR_MOCKUP" \
        "$PORT_INSIDE_CONTAINER_APP_FOR_DEV" \
        "$PORT_INSIDE_CONTAINER_APP_FOR_MOCKUP" \
        "$DATABASE_PASSWORD"
}

# ============================================================================
# FUNCIÓN: SELECCIONAR PROYECTO
# ============================================================================

select_project() {
    print_header "SELECCIÓN DE PROYECTO"
    
    # Buscar archivos de proyecto
    local project_files=(project-*.txt)
    
    if [ ${#project_files[@]} -eq 0 ]; then
        print_error "No se encontraron archivos de proyecto (project-*.txt)"
        return 1
    fi
    
    # Mostrar proyectos disponibles
    echo "Proyectos disponibles:"
    echo ""
    
    local i=1
    for file in "${project_files[@]}"; do
        # Extraer nombre del proyecto del archivo
        local project_name=$(grep "^PROJECT=" "$file" 2>/dev/null | cut -d'=' -f2 | xargs)
        local project_desc=$(grep "^PROJECT_DESCRIPTION=" "$file" 2>/dev/null | cut -d'=' -f2 | xargs)
        
        if [ -z "$project_name" ]; then
            project_name="${file%.txt}"
            project_name="${project_name#project-}"
        fi
        
        echo "  $i) $project_name - ${project_desc:-Sin descripción}"
        echo "     Archivo: $file"
        ((i++))
    done
    
    echo ""
    echo "  0) Salir"
    echo ""
    
    local choice
    read -p "Seleccione un proyecto [0-${#project_files[@]}]: " choice
    
    if [[ "$choice" == "0" ]]; then
        print_info "Saliendo..."
        exit 0
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#project_files[@]}" ]; then
        local selected_file="${project_files[$((choice-1))]}"
        print_success "Proyecto seleccionado: $selected_file"
        echo ""
        load_project_from_file "$selected_file"
        return 0
    else
        print_error "Opción inválida"
        return 1
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
    
    print_info "Creando arhivo: create-a-development-environment.sh"
    
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
            SED_CMD="sed $SED_INLINE "

            # Usar la función para usar correcamente "sed -i ''" en este archivo
            # debido a que se manejaba las comillas simples en una variable
            # pero esto causaba que se creaban dos archivos.
            # Sin embargo para la sustitucion en el archivo final,
            # funciona correctamente
            run_sed "$CREATE_A_DEVELOPMENT_ENVIRONMENT" \
                -e "s|{{ PROJECT_NAME }}|'$PROJECT'|g" \
                -e "s|{{ PROJECT_DESCRIPTION }}|'$PROJECT_DESCRIPTION'|g" \
                -e "s|{{ OS_VERSION }}|'$OS_PRETTY_NAME'|g" \
                -e "s|{{ BASE_DIR }}|'$BASE_DIR'|g" \
                -e "s|{{ DOCKER_CONFIGURATION_FILE }}|'$DOCKER_CONFIGURATION_FILE'|g" \
                -e "s|{{ DB_ROOT_PASSWORD }}|'$DATABASE_PASSWORD'|g" \
                -e "s|{{ DB_CONTAINER_IP_WEB_NETWORK }}|'$IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK'|g" \
                -e "s|{{ DB_CONTAINER_IP_INTERNAL_NETWORK }}|'$IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK'|g" \
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
                -e "s|{{ VERIFY_THAT_THE_CREDENTIALS_ARE_VALID }}|$VERIFY_THAT_THE_CREDENTIALS_ARE_VALID|g" \
                -e "s|sed -i |$SED_CMD|g" \

            run_sed "$CREATE_A_DEVELOPMENT_ENVIRONMENT" \
                -e "s|{{ EXPORTAR_VARIABLE_PARA_DEFINIR_USUARIO }}||g" \

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
            SED_CMD="sed $SED_INLINE "

            # Usar la función para usar correcamente "sed -i ''" en este archivo
            # debido a que se manejaba las comillas simples en una variable
            # pero esto causaba que se creaban dos archivos.
            # Sin embargo para la sustitucion en el archivo final,
            # funciona correctamente
            run_sed "$CREATE_A_DEVELOPMENT_ENVIRONMENT" \
                -e "s|{{ PROJECT_NAME }}|'$PROJECT'|g" \
                -e "s|{{ PROJECT_DESCRIPTION }}|'$PROJECT_DESCRIPTION'|g" \
                -e "s|{{ OS_VERSION }}|'$OS_PRETTY_NAME'|g" \
                -e "s|{{ BASE_DIR }}|'$BASE_DIR'|g" \
                -e "s|{{ DOCKER_CONFIGURATION_FILE }}|'$DOCKER_CONFIGURATION_FILE'|g" \
                -e "s|{{ DB_ROOT_PASSWORD }}|'$DATABASE_PASSWORD'|g" \
                -e "s|{{ DB_CONTAINER_IP_WEB_NETWORK }}|'$IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_PUBLIC_NETWORK'|g" \
                -e "s|{{ DB_CONTAINER_IP_INTERNAL_NETWORK }}|'$IP_ADDRESS_FOR_THE_DATABASE_CONTAINER_INTERNAL_NETWORK'|g" \
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
                -e "s|{{ VERIFY_THAT_THE_CREDENTIALS_ARE_VALID }}|$VERIFY_THAT_THE_CREDENTIALS_ARE_VALID|g" \
                -e "s|sed -i |$SED_CMD|g"

            # PASO 1: Tu terminal (el host)
            run_sed "$CREATE_A_DEVELOPMENT_ENVIRONMENT" \
                -e "s|{{ ENVIRONMENT }}|$env_type|g" \
                -e "s|sudo docker|docker|g" \

            print_success "Archivo creado: $CREATE_A_DEVELOPMENT_ENVIRONMENT"
            ;;
    esac
}

# Definir una función que maneje la llamada a sed según el SO
run_sed() {
    local file="$1"
    shift  # Remover el primer argumento (el archivo)
    
    if [[ "$OS_TYPE" == "linux" ]]; then 
        sed -i "$@" "$file"
    elif [[ "$OS_TYPE" == "macOS" ]]; then
        sed -i '' "$@" "$file"
    fi
}

run_file_to_create_a_development_environment() {
    print_header "Ejecutar archivo 'crear un entorno de desarrollo'"
    if [[ "$OS_TYPE" == "linux" ]]; then 
        sudo chmod a+x $CREATE_A_DEVELOPMENT_ENVIRONMENT
        $CREATE_A_DEVELOPMENT_ENVIRONMENT
    elif [[ "$OS_TYPE" == "macOS" ]]; then
        chmod a+x $CREATE_A_DEVELOPMENT_ENVIRONMENT
        # Lo ejecuto sin el punto, debido a que tiene toda la ruta
        $CREATE_A_DEVELOPMENT_ENVIRONMENT
    fi
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
    # Seleccionar proyecto
    if ! select_project; then
        print_error "Error al seleccionar proyecto"
        exit 1
    fi
    echo ""
    setup_environment
    
    print_success "¡CONFIGURACIÓN COMPLETADA!"
    echo ""
    run_file_to_create_a_development_environment
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