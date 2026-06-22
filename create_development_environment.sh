#!/usr/bin/env bash

# ============================================================================
# CONFIGURACIÓN
# ============================================================================

# Variables principales del proyecto
readonly PROJECT_NAME="main"
readonly PROJECT_DESCRIPTION="Base para todos los proyectos"
readonly OS_VERSION="Debian: 12.7"

# Rutas del sistema
readonly CURRENT_USER=$(whoami)
readonly CURRENT_DIR=$(pwd)
readonly BASE_DIR="/home/$CURRENT_USER/Documentos/proyecto_$PROJECT_NAME"
readonly DOCKER_CONFIGURATION_FILE="/home/${CURRENT_USER}/.docker/config.json"

# Renombrar carpetas repositorio API
RENAME_API_REPOSITORY_FOLDER=$PROJECT_NAME"-api"
RENAME_API_REPOSITORY_MOCKUP_FOLDER=$PROJECT_NAME"-mockup-api"

# Renombrar carpetas repositorio APP
RENAME_APP_REPOSITORY_FOLDER=$PROJECT_NAME"-app"
RENAME_APP_REPOSITORY_MOCKUP_FOLDER=$PROJECT_NAME"-mockup-app"

# Estructura de carpetas
readonly -A DIRECTORIES=(
    ["base_dir"]="$BASE_DIR"
    ["bd"]="$BASE_DIR/bd"
    ["api"]="$BASE_DIR/api"
    ["app"]="$BASE_DIR/app"
    ["zeus_api"]="$BASE_DIR/api/$RENAME_API_REPOSITORY_FOLDER"
    ["meca_app"]="$BASE_DIR/app/$RENAME_APP_REPOSITORY_FOLDER"
    ["api_mockup"]="$BASE_DIR/api/$RENAME_API_REPOSITORY_MOCKUP_FOLDER"
    ["app_mockup"]="$BASE_DIR/app/$RENAME_APP_REPOSITORY_MOCKUP_FOLDER"
)
declare -r DIRECTORIES

# Base de datos
readonly DB_NAME="${PROJECT_NAME}"
readonly MOCKUP_DB_NAME="${PROJECT_NAME}_mockup"
readonly DB_ROOT_PASSWORD="juan"
readonly DB_CONTAINER_IP_WEB_NETWORK="192.168.10.10"
readonly DB_CONTAINER_IP_INTERNAL_NETWORK="192.168.20.10"
readonly DB_PORT="3307"

# Contenedores Docker
declare -A CONTAINERS=(
    ["bd"]="${PROJECT_NAME}_bd"
    ["api"]="${PROJECT_NAME}_api"
    ["app"]="${PROJECT_NAME}_app"
    ["instalar_dependencias_en_api"]="${PROJECT_NAME}_instalar_dependencias_en_api"
    ["instalar_dependencias_en_app"]="${PROJECT_NAME}_instalar_dependencias_en_app"
)
declare -r CONTAINERS

# Configuración de API
readonly API_CONTAINER_NAME="${CONTAINERS[api]}"
readonly API_IMAGE="juancholll/laravel_api_debian:1.0.0"
readonly API_CONTAINER_IP="192.168.20.12"
readonly API_CONTAINER_INSTALL_DEPENDENCIES_IP="192.168.20.11"
readonly API_PORT=8080
readonly API_MOCKUP_PORT=8081

# Configuración de APP
readonly APP_CONTAINER_NAME="${CONTAINERS[app]}"
readonly APP_CONTAINER_IP="192.168.20.14"
readonly APP_CONTAINER_INSTALL_DEPENDENCIES_IP="192.168.20.13"
readonly APP_PORT=8082
readonly APP_PORT_INTERNAL=82
readonly APP_MOCKUP_PORT=8083
readonly APP_MOCKUP_PORT_INTERNAL=83

# Repositorios Git
readonly REPO_API="https://github.com/carlosjuanco/zeus-api.git"
readonly REPO_APP="https://github.com/carlosjuanco/meca-app.git"

# Ramas Git por entorno
declare -A GIT_BRANCHES=(
    ["api"]="${PROJECT_NAME}"
    ["api_mockup"]="mockup"
    ["app"]="${PROJECT_NAME}"
    ["app_mockup"]="mockup"
)

# ============================================================================
# VERIFICANDO AUTENTICACIÓN DE DOCKER
# ============================================================================

# IMPORTANTE: Para autenticación en Docker Hub
# --------------------------------------------
# 1. Ejecutar SIN sudo: docker login
# 2. Ingresar credenciales de Docker Hub
# 3. Las credenciales se guardan en: ~/.docker/config.json
# 4. NO usar sudo con docker login
# --------------------------------------------
check_docker_auth() {
    print_section "VERIFICANDO AUTENTICACIÓN DE DOCKER"
    
    # Verificar si hay credenciales guardadas
    if [ ! -f ${DOCKER_CONFIGURATION_FILE} ]; then
        print_warning "No hay credenciales de Docker guardadas"
        print_info "Ejecuta: docker login"
        return 1
    fi
    
    # Verificar que las credenciales sean válidas
    # También me sirve para indicar que no he iniciado docker
    if ! sudo docker pull hello-world > /dev/null 2>&1; then
        print_warning "Credenciales de Docker expiradas o inválidas"
        print_info "Ejecuta: docker login"
        return 1
    fi
    
    print_success "Autenticación de Docker verificada"
    return 0
}

# ============================================================================
# VERIFICANDO QUE EXISTE LA IMAGEN juancholll/laravel_api_macos:1.0.0
# ============================================================================

create_image_if_not_exists() {
    local IMAGE="${API_IMAGE}"
    
    print_section "VERIFICANDO SI LA IMAGEN $IMAGEN EXISTE LOCALMENTE..."
    
    if sudo docker image inspect "$IMAGE" >/dev/null 2>&1; then
        print_success "La imagen $IMAGE ya existe localmente."
        return 0
    else
        print_warning "La imagen $IMAGE no existe localmente."
        print_info "Construyendo la imagen..."
        
        if sudo docker build -t "$IMAGE" .; then
            print_success "La imagen $IMAGE creada existosamente."
            return 0
        else
            print_error "Error al crear la imagen $IMAGE."
            return 1
        fi
    fi
}

# ============================================================================
# FUNCIONES DE UTILIDAD
# ============================================================================

print_header() {
    echo "========================================"
    echo "$1"
    echo "========================================"
}

print_section() {
    echo "----------------------------------------"
    echo "$1"
    echo "----------------------------------------"
}

print_warning() {
    echo "[WARNING] $1"
}

print_info() {
    echo "[INFO] $1"
}

print_success() {
    echo "[✓] $1"
}

print_error() {
    echo "[ERROR] $1" >&2
}

check_command() {
    if [ $? -ne 0 ]; then
        print_error "$2"
        return 1
    fi
    return 0
}

# ============================================================================
# FUNCIONES PRINCIPALES
# ============================================================================

show_project_info() {
    print_header "INFORMACIÓN DEL PROYECTO"
    echo "Versión del SO: $OS_VERSION"
    echo "Nombre del proyecto: $PROJECT_NAME"
    echo "Descripción: $PROJECT_DESCRIPTION"
    echo ""
}

stop_and_remove_containers() {
    print_section "DETENIENDO Y ELIMINANDO CONTENEDORES"
    
    # Iterar sobre todas las CLAVES del array asociativo
    for clave in "${!CONTAINERS[@]}"; do
        local nombre_contenedor="${CONTAINERS[$clave]}"
        
        print_info "Procesando contenedor [$clave]: $nombre_contenedor"
        
        # Detener contenedor
        if sudo docker stop "$nombre_contenedor" 2>/dev/null; then
            print_success "Contenedor $nombre_contenedor detenido"
        else
            print_info "El contenedor $nombre_contenedor no existe o ya está detenido"
        fi
        
        # Eliminar contenedor
        if sudo docker rm "$nombre_contenedor" 2>/dev/null; then
            print_success "Contenedor $nombre_contenedor eliminado"
        else
            print_info "El contenedor $nombre_contenedor no existe"
        fi
        
        echo ""  # Línea en blanco para separar
    done
}

cleanup_project_directory() {
    print_section "LIMPIANDO DIRECTORIO DEL PROYECTO"
    
    if [ -d "$BASE_DIR" ]; then
        print_info "Eliminando directorio existente: $BASE_DIR"
        sudo rm -rf "$BASE_DIR"
        print_success "Directorio eliminado"
    else
        print_info "El directorio $BASE_DIR no existe"
    fi
}

create_project_structure() {
    print_section "CREANDO ESTRUCTURA DEL PROYECTO"
    
    for clave in "${!DIRECTORIES[@]}"; do
        mkdir -p "${DIRECTORIES[$clave]}"
        check_command "No se pudo crear el directorio: $clave"
        print_success "Creado: $clave"
    done
    
    # Mostrar estructura
    if command -v tree &> /dev/null; then
        tree "$BASE_DIR"
    else
        find "$BASE_DIR" -type d | sed 's|[^/]*/|- |g'
    fi
    
    # Mostrar permisos
    print_section "PERMISOS DE CARPETAS"
    ls -la "$BASE_DIR"
}

clone_repositories() {
    print_section "CLONANDO REPOSITORIOS"
    
    # Clonar repositorios de API
    clone_repo "$REPO_API" "${DIRECTORIES[zeus_api]}" "${GIT_BRANCHES[api]}"
    clone_repo "$REPO_API" "${DIRECTORIES[api_mockup]}" "${GIT_BRANCHES[api_mockup]}"
    
    # Clonar repositorios de APP
    clone_repo "$REPO_APP" "${DIRECTORIES[meca_app]}" "${GIT_BRANCHES[app]}"
    clone_repo "$REPO_APP" "${DIRECTORIES[app_mockup]}" "${GIT_BRANCHES[app_mockup]}"
}

clone_repo() {
    local repo_url="$1"
    local dest_dir="$2"
    local branch="$3"
    
    print_info "Clonando $repo_url en $dest_dir (rama: $branch)"
    
    if git clone "$repo_url" "$dest_dir"; then
        cd "$dest_dir" || return 1
        
        if git checkout "$branch" 2>/dev/null; then
            print_success "Repositorio clonado en $dest_dir (rama: $branch)"
            echo ""  # Línea en blanco para separar
        else
            print_error "No se pudo cambiar a la rama $branch"
            return 1
        fi
        
        cd - > /dev/null || return 1
    else
        print_error "Error al clonar el repositorio en $dest_dir"
        return 1
    fi
}

create_env_files() {
    print_section "CREANDO ARCHIVOS DE CONFIGURACIÓN .env"
    
    # API - Desarrollo
    create_api_env_file \
        "${DIRECTORIES[zeus_api]}/.env.example" \
        "${DIRECTORIES[zeus_api]}/.env" \
        "$DB_NAME"
    
    # API - Mockup
    create_api_env_file \
        "${DIRECTORIES[api_mockup]}/.env.example" \
        "${DIRECTORIES[api_mockup]}/.env" \
        "$MOCKUP_DB_NAME"
    
    # APP - Desarrollo
    create_app_env_file \
        "$CURRENT_DIR/env.env" \
        "${DIRECTORIES[meca_app]}/.env" \
        "$API_PORT"
    
    # APP - Mockup
    create_app_env_file \
        "$CURRENT_DIR/env.env" \
        "${DIRECTORIES[app_mockup]}/.env" \
        "$API_MOCKUP_PORT"
}

create_api_env_file() {
    local input_file="$1"
    local output_file="$2"
    local db_name="$3"
    
    if [ ! -f "$input_file" ]; then
        print_error "Archivo de entrada no encontrado: $input_file"
        return 1
    fi
    
    cp "$input_file" "$output_file"
    
    sed -i \
        -e "s|DB_HOST=127.0.0.1|DB_HOST=$DB_CONTAINER_IP_INTERNAL_NETWORK|g" \
        -e "s|DB_DATABASE=laravel|DB_DATABASE=$db_name|g" \
        -e "s|DB_PASSWORD=|DB_PASSWORD=$DB_ROOT_PASSWORD|g" \
        "$output_file"
    
    print_success "Archivo .env creado: $output_file"
}

create_app_env_file() {
    local input_file="$1"
    local output_file="$2"
    local api_port="$3"
    
    if [ ! -f "$input_file" ]; then
        print_error "Archivo de entrada no encontrado: $input_file"
        return 1
    fi
    
    cp "$input_file" "$output_file"
    
    sed -i "s|8081|$api_port|g" "$output_file"
    
    print_success "Archivo .env creado: $output_file"
}

update_database_init_file() {
    print_section "ACTUALIZANDO ARCHIVO DE INICIALIZACIÓN DE BD"
    
    local init_file="${DIRECTORIES[zeus_api]}/database/init.sql"
    
    if [ -f "$init_file" ]; then
        sed -i \
            -e "s|nombreDeLaBaseDeDatosParaElDesarrollo|$DB_NAME|g" \
            -e "s|nombreDeLaBaseDeDatosParaLaMaqueta|$MOCKUP_DB_NAME|g" \
            "$init_file"
        
        print_success "Archivo init.sql actualizado"
    else
        print_error "Archivo init.sql no encontrado: $init_file"
    fi
}

generate_docker_compose_files() {
    print_section "GENERANDO ARCHIVOS DOCKER COMPOSE"
    
    generate_install_services_file
    generate_run_services_file
}

generate_install_services_file() {
    # Generar archivo de instalación para la API

    local source_file="$CURRENT_DIR/install_dependencies_in_api.yml"
    local dest_file="$CURRENT_DIR/create_containers_to_install_dependencies_on_the_${PROJECT_NAME}_api.yml"
    
    if [ ! -f "$source_file" ]; then
        print_error "Archivo fuente no encontrado: $source_file"
        return 1
    fi
    
    cp "$source_file" "$dest_file"
    
    # Reemplazos en el archivo YML

    # La variable ${CONTAINERS[instalar_dependencias_en_api]}, se pone dos veces, pero
    # uno es el nombre del servicio en docker compose y el segundo es el nombre del 
    # contenedor, pero ambos tienen el mismo nombre
    sed -i \
        -e "s|iasd_mysql:|${PROJECT_NAME}_mysql:|g" \
        -e "s|instalar_dependencias_en_api:|${CONTAINERS[instalar_dependencias_en_api]}:|g" \
        -e "s|container_name: iasd_bd|container_name: ${CONTAINERS[bd]}|g" \
        -e "s|/home/juan/Documentos/proyecto_iasd|$BASE_DIR|g" \
        -e "s|image: juancholll/laravel_api|image: $API_IMAGE|g" \
        -e "s|container_name: instalar_dependencias_en_api|container_name: ${CONTAINERS[instalar_dependencias_en_api]}|g" \
        -e "s|ipv4_address: 192.168.10.10|ipv4_address: ${DB_CONTAINER_IP_WEB_NETWORK}|g" \
        -e "s|ipv4_address: 192.168.20.10|ipv4_address: ${DB_CONTAINER_IP_INTERNAL_NETWORK}|g" \
        -e "s|3307:3306|${DB_PORT}:3306|g" \
        -e "s|/zeus-api|/${RENAME_API_REPOSITORY_FOLDER}|g" \
        -e "s|/mockup|/${RENAME_API_REPOSITORY_MOCKUP_FOLDER}|g" \
        -e "s|ipv4_address: 192.168.20.11|ipv4_address: ${API_CONTAINER_INSTALL_DEPENDENCIES_IP}|g" \
        "$dest_file"
    
    print_success "Archivo de instalación generado: $dest_file"

    # Generar archivo de instalación para la APP

    source_file="$CURRENT_DIR/install_dependencies_in_app.yml"
    dest_file="$CURRENT_DIR/create_containers_to_install_dependencies_on_the_${PROJECT_NAME}_app.yml"
    
    if [ ! -f "$source_file" ]; then
        print_error "Archivo fuente no encontrado: $source_file"
        return 1
    fi
    
    cp "$source_file" "$dest_file"
    
    # Reemplazos en el archivo YML

    # La variable ${CONTAINERS[instalar_dependencias_en_app]}, se pone dos veces, pero
    # uno es el nombre del servicio en docker compose y el segundo es el nombre del 
    # contenedor, pero ambos tienen el mismo nombre
    sed -i \
        -e "s|proyectoBellesa|${CURRENT_DIR}|g" \
        -e "s|instalar_dependencias_en_app:|${CONTAINERS[instalar_dependencias_en_app]}:|g" \
        -e "s|/home/juan/Documentos/proyecto_iasd|$BASE_DIR|g" \
        -e "s|container_name: instalar_dependencias_en_app|container_name: ${CONTAINERS[instalar_dependencias_en_app]}|g" \
        -e "s|/meca-app|/${RENAME_APP_REPOSITORY_FOLDER}|g" \
        -e "s|/mockup|/${RENAME_APP_REPOSITORY_MOCKUP_FOLDER}|g" \
        -e "s|ipv4_address: 192.168.20.13|ipv4_address: ${APP_CONTAINER_INSTALL_DEPENDENCIES_IP}|g" \
        "$dest_file"
    
    print_success "Archivo de instalación generado: $dest_file"
}

generate_run_services_file() {
    # Generar archivo de ejecución para la API

    local source_file="$CURRENT_DIR/run_services_in_the_api.yml"
    local dest_file="$CURRENT_DIR/run_${PROJECT_NAME}_services_in_the_api.yml"
    
    if [ ! -f "$source_file" ]; then
        print_error "Archivo fuente no encontrado: $source_file"
        return 1
    fi
    
    cp "$source_file" "$dest_file"
    
    # Reemplazos en el archivo YML
    sed -i \
        -e "s|iasd_api:|${PROJECT_NAME}_api:|g" \
        -e "s|image: juancholll/laravel_api|image: $API_IMAGE|g" \
        -e "s|container_name: iasd_api|container_name: $API_CONTAINER_NAME|g" \
        -e "s|/home/juan/Documentos/proyecto_iasd|$BASE_DIR|g" \
        -e "s|ipv4_address: 192.168.20.12|ipv4_address: $API_CONTAINER_IP|g" \
        -e "s|puertoAfueraAPI1:puertoAdentroAPI1|${API_PORT}:82|g" \
        -e "s|puertoAfueraAPI2:puertoAdentroAPI2|${API_MOCKUP_PORT}:83|g" \
        -e "s|/zeus-api|/${RENAME_API_REPOSITORY_FOLDER}|g" \
        -e "s|/mockup|/${RENAME_API_REPOSITORY_MOCKUP_FOLDER}|g" \
        -e "s|--host=192.168.20.12 --port=80|--host=$API_CONTAINER_IP --port=82|g" \
        -e "s|--host=192.168.20.12 --port=81|--host=$API_CONTAINER_IP --port=83|g" \
        "$dest_file"
    
    print_success "Archivo de ejecución generado: $dest_file"

    # Generar archivo de ejecución para la APP

    source_file="$CURRENT_DIR/run_services_in_the_app.yml"
    dest_file="$CURRENT_DIR/run_${PROJECT_NAME}_services_in_the_app.yml"
    
    if [ ! -f "$source_file" ]; then
        print_error "Archivo fuente no encontrado: $source_file"
        return 1
    fi
    
    cp "$source_file" "$dest_file"
    
    # Reemplazos en el archivo YML
    sed -i \
        -e "s|iasd_app:|${PROJECT_NAME}_app:|g" \
        -e "s|/home/juan/Documentos/proyecto_iasd|$BASE_DIR|g" \
        -e "s|container_name: iasd_app|container_name: $APP_CONTAINER_NAME|g" \
        -e "s|ipv4_address: 192.168.20.14|ipv4_address: $APP_CONTAINER_IP|g" \
        -e "s|puertoAfueraAPP1:puertoAdentroAPP1|$APP_PORT:$APP_PORT_INTERNAL|g" \
        -e "s|puertoAfueraAPP2:puertoAdentroAPP2|$APP_MOCKUP_PORT:$APP_MOCKUP_PORT_INTERNAL|g" \
        -e "s|/meca-app|/${RENAME_APP_REPOSITORY_FOLDER}|g" \
        -e "s|/mockup|/${RENAME_APP_REPOSITORY_MOCKUP_FOLDER}|g" \
        -e "s|npm run serve -- --port 82|npm run serve -- --port $APP_MOCKUP_PORT_INTERNAL|g" \
        -e "s|npm run serve -- --port 81|npm run serve -- --port $APP_PORT_INTERNAL|g" \
        "$dest_file"
    
    print_success "Archivo de ejecución generado: $dest_file"
}

run_services() {
    print_section "INSTALANDO Y EJECUTANDO SERVICIOS"
    
    local installation_file_for_the_app="$CURRENT_DIR/create_containers_to_install_dependencies_on_the_${PROJECT_NAME}_app.yml"
    local installation_file_for_the_api="$CURRENT_DIR/create_containers_to_install_dependencies_on_the_${PROJECT_NAME}_api.yml"
    local execution_file_for_the_api="$CURRENT_DIR/run_${PROJECT_NAME}_services_in_the_api.yml"
    local execution_file_for_the_app="$CURRENT_DIR/run_${PROJECT_NAME}_services_in_the_app.yml"
    
    # Instalar dependencias
    
    if sudo docker-compose -f "$installation_file_for_the_api" up -d; then
        print_success "Servicios instalados en la API"
        
        # Monitorear logs de instalación
        monitor_installation_logs "API"
        
        # Detener contenedores de instalación
        stop_installation_containers "API"
    else
        print_error "Error al instalar servicios"
        return 1
    fi

    if sudo docker-compose -f "$installation_file_for_the_app" up -d; then
        print_success "Servicios instalados en la APP"
        
        # Monitorear logs de instalación
        monitor_installation_logs "APP"
        
        # Detener contenedores de instalación
        stop_installation_containers "APP"
    else
        print_error "Error al instalar servicios"
        return 1
    fi
    
    # Ejecutar servicios principales
    print_info "Iniciando servicios principales..."
    if sudo docker-compose -f "$execution_file_for_the_api" up -d; then
        print_success "Servicios iniciados"
        
        # Monitorear logs iniciales
        monitor_initial_logs "API"
    else
        print_error "Error al iniciar servicios"
        return 1
    fi

    if sudo docker-compose -f "$execution_file_for_the_app" up -d; then
        print_success "Servicios iniciados"
        
        # Monitorear logs iniciales
        monitor_initial_logs "APP"
    else
        print_error "Error al iniciar servicios"
        return 1
    fi
    
    # Limpiar archivos temporales
    print_section "LIMPIANDO ARCHIVOS TEMPORALES"
    cleanup_temp_files "$installation_file_for_the_api"
    cleanup_temp_files "$installation_file_for_the_app"
    cleanup_temp_files "$execution_file_for_the_api"
    cleanup_temp_files "$execution_file_for_the_app"
}

monitor_installation_logs() {
    if [ "$1" = "API" ]; then
        print_info "Monitoreando instalación de API..."
        
        npm_count=0
        # Leer línea por línea
        while IFS= read -r line; do
            echo "$line" # Mostrar
            
            if grep -q "FillInTheValuesForThePermissionsFieldSeeder.*DONE" <<< "$line"; then
                ((npm_count++))
            fi

            if [ "$npm_count" -eq 2 ]; then
                print_success "Instalación de API completada"
                break
            fi
        done < <(sudo docker logs -f "${CONTAINERS[instalar_dependencias_en_api]}" 2>&1)
        
        print_info "Monitoreando instalación de APP..."
    elif [ "$1" = "APP" ]; then
        npm_count=0

        # Leer línea por línea
        while IFS= read -r line; do
            echo "$line" # Mostrar
            
            if grep -q "added 987 packages" <<< "$line"; then
                ((npm_count++))
            fi
            
            if [ "$npm_count" -eq 2 ]; then
                print_success "¡Added packages! APP completada"
                break
            fi
        done < <(sudo docker logs -f "${CONTAINERS[instalar_dependencias_en_app]}" 2>&1)
    fi

}

stop_installation_containers() {
    if [ "$1" = "API" ]; then
        local api_install_container="${CONTAINERS[instalar_dependencias_en_api]}"
        
        print_info "Deteniendo contenedores de instalación..."
        sudo docker stop "$api_install_container"
        print_success "Contenedores de instalación detenidos"
    elif [ "$1" = "APP" ]; then
        local app_install_container="${CONTAINERS[instalar_dependencias_en_app]}"
        
        print_info "Deteniendo contenedores de instalación..."
        sudo docker stop "$app_install_container"
        print_success "Contenedores de instalación detenidos"
    fi
}

monitor_initial_logs() {
    if [ "$1" = "API" ]; then
        print_info "Monitoreando inicio de servicios..."
        
        # Mostrar logs iniciales de API
        print_section "LOGS INICIALES - API"

        npm_count=0

        while IFS= read -r line; do
            echo "$line" # Mostrar
            
            if grep -q "Press.*Ctrl+C to stop the server" <<< "$line"; then
                ((npm_count++))
                if [ "$npm_count" -eq 2 ]; then
                    print_success "¡2 Press Ctrl+C to stop the server encontrados!"
                    print_success "¡Servicios de la API levantados!"
                    break
                fi
            fi
        done < <(sudo docker logs -f "${API_CONTAINER_NAME}" 2>&1)
    elif [ "$1" = "APP" ]; then
        # Mostrar logs iniciales de APP
        print_section "LOGS INICIALES - APP"
        # sudo docker logs -f "${APP_CONTAINER_NAME}"

        npm_count=0

        while IFS= read -r line; do
            echo "$line" # Mostrar
            
            if grep -q "http://localhost:${APP_PORT_INTERNAL}/" <<< "$line"; then
                ((npm_count++))
            elif grep -q "http://localhost:${APP_MOCKUP_PORT_INTERNAL}/" <<< "$line"; then
                ((npm_count++))
            elif [ "$npm_count" -eq 2 ]; then
                print_success "¡Se levantaron los servicios en la APP!"
                break
            fi
        done < <(sudo docker logs -f "${APP_CONTAINER_NAME}" 2>&1)
    fi
}

cleanup_temp_files() {
    local file="$1"
    
    if [ -f "$file" ]; then
        rm -f "$file"
        print_success "Archivo eliminado: $file"
    fi    
}

show_final_summary() {
    print_header "INSTALACIÓN COMPLETA"
    echo ""
    echo "RESUMEN:"
    echo "----------------------------------------"
    echo "• Proyecto: $PROJECT_NAME"
    echo "• Directorio base: $BASE_DIR"
    echo ""
    echo "SERVICIOS DISPONIBLES:"
    echo "----------------------------------------"
    echo "• API Desarrollo:      http://localhost:$API_PORT"
    echo "• API Mockup:          http://localhost:$API_MOCKUP_PORT"
    echo "• APP Desarrollo:      http://localhost:$APP_PORT"
    echo "• APP Mockup:          http://localhost:$APP_MOCKUP_PORT"
    echo ""
    echo "CONTENEDORES ACTIVOS:"
    echo "----------------------------------------"
    sudo docker ps --filter "name=$PROJECT_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "Para ver los logs en tiempo real:"
    echo "  sudo docker logs -f ${PROJECT_NAME}_api"
    echo "  sudo docker logs -f ${PROJECT_NAME}_app"
    echo ""
}

# ============================================================================
# FLUJO PRINCIPAL
# ============================================================================

main() {
    if ! check_docker_auth; then
        print_error "Problema con autenticación de Docker"
        exit 1
    fi

    if ! create_image_if_not_exists; then
        print_error "Problema al contruir la imagen ${API_IMAGE}"
        exit 1
    fi

    show_project_info
    
    # Fase 1: Preparación
    stop_and_remove_containers
    cleanup_project_directory
    create_project_structure
    
    # Fase 2: Configuración
    clone_repositories
    create_env_files
    update_database_init_file
    generate_docker_compose_files
    
    # Fase 3: Ejecución
    run_services
    
    # Fase 4: Resumen final
    show_final_summary
}

# Ejecutar script principal
main
