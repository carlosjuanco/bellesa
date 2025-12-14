#!/bin/bash

# ============================================================================
# CONFIGURACIÓN
# ============================================================================

# Variables principales del proyecto
readonly PROJECT_NAME="sdac"
readonly PROJECT_DESCRIPTION="Crear un entorno de desarrollo para el proyecto Iglesia Adventista del Séptimo día."
readonly OS_VERSION="Sonoma 14.3"

# Rutas del sistema
readonly CURRENT_USER=$(whoami)
readonly CURRENT_DIR=$(pwd)
readonly BASE_DIR="/Users/$CURRENT_USER/Documents/proyecto_$PROJECT_NAME"

# Estructura de carpetas
readonly DIRECTORIES=(
    "$BASE_DIR"
    "$BASE_DIR/bd"
    "$BASE_DIR/api"
    "$BASE_DIR/app"
    "$BASE_DIR/api/zeus-api"
    "$BASE_DIR/app/meca-app"
    "$BASE_DIR/api/mockup"
    "$BASE_DIR/app/mockup"
    "$BASE_DIR/app/user-manual"
)

# Base de datos
readonly DB_NAME="sdac"
readonly MOCKUP_DB_NAME="${PROJECT_NAME}_mockup"
readonly DB_ROOT_PASSWORD="juan"
readonly DB_CONTAINER_IP="192.168.20.15"

# Contenedores Docker
readonly CONTAINERS=(
    "${PROJECT_NAME}_bd"
    "${PROJECT_NAME}_api"
    "${PROJECT_NAME}_app"
    "${PROJECT_NAME}_instalar_dependencias_en_api"
    "${PROJECT_NAME}_instalar_dependencias_en_app"
)

# Configuración de API
readonly API_CONTAINER_NAME="${PROJECT_NAME}_api"
readonly API_IMAGE="juancholll/laravel_api_macos"
readonly API_CONTAINER_IP="192.168.20.18"
readonly API_PORT=8082
readonly API_MOCKUP_PORT=8083

# Configuración de APP
readonly APP_CONTAINER_NAME="${PROJECT_NAME}_app"
readonly APP_PORT=8084
readonly APP_MOCKUP_PORT=8085
readonly USER_MANUAL_PORT=4321

# Repositorios Git
readonly REPO_API="https://github.com/carlosjuanco/zeus-api.git"
readonly REPO_APP="https://github.com/carlosjuanco/meca-app.git"

# Ramas Git por entorno
declare -A GIT_BRANCHES=(
    ["api_dev"]="${PROJECT_NAME}-dev"
    ["api_mockup"]="${PROJECT_NAME}-mockup"
    ["app_dev"]="${PROJECT_NAME}-dev"
    ["app_mockup"]="${PROJECT_NAME}-mockup"
    ["app_manual"]="${PROJECT_NAME}-user-manual-with-starlight"
)

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
    
    for container in "${CONTAINERS[@]}"; do
        print_info "Procesando contenedor: $container"
        
        # Detener contenedor
        if sudo docker stop "$container" 2>/dev/null; then
            print_success "Contenedor $container detenido"
        else
            print_info "El contenedor $container no existe o ya está detenido"
        fi
        
        # Eliminar contenedor
        if sudo docker rm "$container" 2>/dev/null; then
            print_success "Contenedor $container eliminado"
        else
            print_info "El contenedor $container no existe"
        fi
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
    
    for dir in "${DIRECTORIES[@]}"; do
        mkdir -p "$dir"
        check_command "No se pudo crear el directorio: $dir"
        print_success "Creado: $dir"
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
    clone_repo "$REPO_API" "$BASE_DIR/api/zeus-api" "${GIT_BRANCHES[api_dev]}"
    # clone_repo "$REPO_API" "$BASE_DIR/api/mockup" "${GIT_BRANCHES[api_mockup]}"
    
    # # Clonar repositorios de APP
    # clone_repo "$REPO_APP" "$BASE_DIR/app/meca-app" "${GIT_BRANCHES[app_dev]}"
    # clone_repo "$REPO_APP" "$BASE_DIR/app/mockup" "${GIT_BRANCHES[app_mockup]}"
    # clone_repo "$REPO_APP" "$BASE_DIR/app/user-manual" "${GIT_BRANCHES[app_manual]}"
}

clone_repo() {
    local repo_url="$1"
    local dest_dir="$2"
    local branch="$3"

     # DEPURACIÓN: Mostrar parámetros recibidos
    echo "=== DEBUG ==="
    echo "Parámetro 1 (URL): $repo_url"
    echo "Parámetro 2 (Destino): $dest_dir"
    echo "Parámetro 3 (Rama): $branch"
    echo "=============="
    
    print_info "Clonando $repo_url en $dest_dir (rama: $branch)"
    
    # if git clone "$repo_url" "$dest_dir"; then
    #     cd "$dest_dir" || return 1
        
    #     if git checkout "$branch" 2>/dev/null; then
    #         print_success "Repositorio clonado en $dest_dir (rama: $branch)"
    #     else
    #         print_error "No se pudo cambiar a la rama $branch"
    #         return 1
    #     fi
        
    #     cd - > /dev/null || return 1
    # else
    #     print_error "Error al clonar el repositorio en $dest_dir"
    #     return 1
    # fi
}

create_env_files() {
    print_section "CREANDO ARCHIVOS DE CONFIGURACIÓN .env"
    
    # API - Desarrollo
    create_api_env_file \
        "$BASE_DIR/api/zeus-api/.env.example" \
        "$BASE_DIR/api/zeus-api/.env" \
        "$DB_NAME"
    
    # API - Mockup
    create_api_env_file \
        "$BASE_DIR/api/mockup/.env.example" \
        "$BASE_DIR/api/mockup/.env" \
        "$MOCKUP_DB_NAME"
    
    # APP - Desarrollo
    create_app_env_file \
        "$CURRENT_DIR/env.env" \
        "$BASE_DIR/app/meca-app/.env" \
        "$API_PORT"
    
    # APP - Mockup
    create_app_env_file \
        "$CURRENT_DIR/env.env" \
        "$BASE_DIR/app/mockup/.env" \
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
    
    sed -i '' \
        -e "s|DB_HOST=127.0.0.1|DB_HOST=$DB_CONTAINER_IP|g" \
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
    
    sed -i '' "s|8081|$api_port|g" "$output_file"
    
    print_success "Archivo .env creado: $output_file"
}

update_database_init_file() {
    print_section "ACTUALIZANDO ARCHIVO DE INICIALIZACIÓN DE BD"
    
    local init_file="$BASE_DIR/api/zeus-api/database/init.sql"
    
    if [ -f "$init_file" ]; then
        sed -i '' \
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
    local source_file="$CURRENT_DIR/install_services.yml"
    local dest_file="$CURRENT_DIR/create_containers_for_services_${PROJECT_NAME}.yml"
    
    if [ ! -f "$source_file" ]; then
        print_error "Archivo fuente no encontrado: $source_file"
        return 1
    fi
    
    cp "$source_file" "$dest_file"
    
    # Reemplazos en el archivo YML
    sed -i '' \
        -e "s|iasd_mysql:|${PROJECT_NAME}_mysql:|g" \
        -e "s|instalar_dependencias_en_api:|${PROJECT_NAME}_instalar_dependencias_en_api:|g" \
        -e "s|instalar_dependencias_en_app:|${PROJECT_NAME}_instalar_dependencias_en_app:|g" \
        -e "s|container_name: iasd_bd|container_name: ${PROJECT_NAME}_bd|g" \
        -e "s|/home/juan/Documentos/proyecto_iasd|$BASE_DIR|g" \
        -e "s|image: juancholll/laravel_api|image: $API_IMAGE|g" \
        -e "s|container_name: instalar_dependencias_en_api|container_name: ${PROJECT_NAME}_instalar_dependencias_en_api|g" \
        -e "s|container_name: instalar_dependencias_en_app|container_name: ${PROJECT_NAME}_instalar_dependencias_en_app|g" \
        -e "s|ipv4_address: 192.168.10.10|ipv4_address: 192.168.10.15|g" \
        -e "s|ipv4_address: 192.168.20.10|ipv4_address: 192.168.20.15|g" \
        -e "s|3307:3306|3308:3306|g" \
        -e "s|ipv4_address: 192.168.20.11|ipv4_address: 192.168.20.16|g" \
        -e "s|ipv4_address: 192.168.20.13|ipv4_address: 192.168.20.17|g" \
        "$dest_file"
    
    print_success "Archivo de instalación generado: $dest_file"
}

generate_run_services_file() {
    local source_file="$CURRENT_DIR/run_services.yml"
    local dest_file="$CURRENT_DIR/run_services2.yml"
    
    if [ ! -f "$source_file" ]; then
        print_error "Archivo fuente no encontrado: $source_file"
        return 1
    fi
    
    cp "$source_file" "$dest_file"
    
    # Reemplazos en el archivo YML
    sed -i '' \
        -e "s|iasd_api:|${PROJECT_NAME}_api:|g" \
        -e "s|iasd_app:|${PROJECT_NAME}_app:|g" \
        -e "s|image: juancholll/laravel_api|image: $API_IMAGE|g" \
        -e "s|container_name: iasd_api|container_name: $API_CONTAINER_NAME|g" \
        -e "s|/home/juan/Documentos/proyecto_iasd|$BASE_DIR|g" \
        -e "s|container_name: iasd_app|container_name: $APP_CONTAINER_NAME|g" \
        -e "s|ipv4_address: 192.168.20.12|ipv4_address: $API_CONTAINER_IP|g" \
        -e "s|puertoAfueraAPI1:puertoAdentroAPI1|${API_PORT}:82|g" \
        -e "s|puertoAfueraAPI2:puertoAdentroAPI2|${API_MOCKUP_PORT}:83|g" \
        -e "s|--host=192.168.20.12 --port=80|--host=$API_CONTAINER_IP --port=82|g" \
        -e "s|--host=192.168.20.12 --port=81|--host=$API_CONTAINER_IP --port=83|g" \
        -e "s|ipv4_address: 192.168.20.14|ipv4_address: 192.168.20.19|g" \
        -e "s|puertoAfueraAPP1:puertoAdentroAPP1|${APP_PORT}:84|g" \
        -e "s|puertoAfueraAPP2:puertoAdentroAPP2|${APP_MOCKUP_PORT}:85|g" \
        -e "s|puertoAfueraAPP3:puertoAdentroAPP3|${USER_MANUAL_PORT}:4321|g" \
        -e "s|npm run serve -- --port 81|npm run serve -- --port 84|g" \
        -e "s|npm run serve -- --port 82|npm run serve -- --port 85|g" \
        "$dest_file"
    
    print_success "Archivo de ejecución generado: $dest_file"
}

run_services() {
    print_section "INSTALANDO Y EJECUTANDO SERVICIOS"
    
    local install_file="$CURRENT_DIR/create_containers_for_services_${PROJECT_NAME}.yml"
    local run_file="$CURRENT_DIR/run_services2.yml"
    
    # Instalar dependencias
    print_info "Instalando servicios..."
    if sudo docker-compose -f "$install_file" up -d; then
        print_success "Servicios instalados"
        
        # Monitorear logs de instalación
        monitor_installation_logs
        
        # Detener contenedores de instalación
        stop_installation_containers
    else
        print_error "Error al instalar servicios"
        return 1
    fi
    
    # Ejecutar servicios principales
    print_info "Iniciando servicios principales..."
    if sudo docker-compose -f "$run_file" up -d; then
        print_success "Servicios iniciados"
        
        # Monitorear logs iniciales
        monitor_initial_logs
    else
        print_error "Error al iniciar servicios"
        return 1
    fi
    
    # Limpiar archivos temporales
    cleanup_temp_files "$install_file" "$run_file"
}

monitor_installation_logs() {
    local api_install_container="${PROJECT_NAME}_instalar_dependencias_en_api"
    local app_install_container="${PROJECT_NAME}_instalar_dependencias_en_app"
    
    print_info "Monitoreando instalación de API..."
    if sudo docker logs -f "$api_install_container" 2>&1 | grep -q "Database\\\\Seeders\\\\FillInTheValuesForThePermissionsFieldSeeder.*DONE"; then
        print_success "Instalación de API completada"
    fi
    
    print_info "Monitoreando instalación de APP..."
    if sudo docker logs -f "$app_install_container" 2>&1 | grep -q "npm notice"; then
        print_success "Instalación de APP completada"
    fi
}

stop_installation_containers() {
    local api_install_container="${PROJECT_NAME}_instalar_dependencias_en_api"
    local app_install_container="${PROJECT_NAME}_instalar_dependencias_en_app"
    
    print_info "Deteniendo contenedores de instalación..."
    sudo docker stop "$api_install_container" "$app_install_container"
    print_success "Contenedores de instalación detenidos"
}

monitor_initial_logs() {
    print_info "Monitoreando inicio de servicios..."
    
    # Mostrar logs iniciales de API
    print_section "LOGS INICIALES - API"
    timeout 10s sudo docker logs -f "$API_CONTAINER_NAME" 2>&1 | head -20
    
    # Mostrar logs iniciales de APP
    print_section "LOGS INICIALES - APP"
    timeout 10s sudo docker logs -f "$APP_CONTAINER_NAME" 2>&1 | head -20
}

cleanup_temp_files() {
    local install_file="$1"
    local run_file="$2"
    
    print_section "LIMPIANDO ARCHIVOS TEMPORALES"
    
    if [ -f "$install_file" ]; then
        rm -f "$install_file"
        print_success "Archivo eliminado: $install_file"
    fi
    
    if [ -f "$run_file" ]; then
        rm -f "$run_file"
        print_success "Archivo eliminado: $run_file"
    fi
}

show_final_summary() {
    print_header "INSTALACIÓN COMPLETADA"
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
    echo "• Manual de usuario:   http://localhost:$USER_MANUAL_PORT"
    echo ""
    echo "CONTENEDORES ACTIVOS:"
    echo "----------------------------------------"
    sudo docker ps --filter "name=$PROJECT_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "Para ver los logs en tiempo real:"
    echo "  sudo docker logs -f ${PROJECT_NAME}_api"
    echo "  sudo docker logs -f ${PROJECT_NAME}_app"
    echo ""
    echo "Para detener todos los servicios:"
    echo "  sudo docker-compose -f run_services2.yml down"
}

# ============================================================================
# FLUJO PRINCIPAL
# ============================================================================

main() {
    show_project_info
    
    # Fase 1: Preparación
    stop_and_remove_containers
    cleanup_project_directory
    create_project_structure
    
    # Fase 2: Configuración
    clone_repositories
    # create_env_files
    # update_database_init_file
    # generate_docker_compose_files
    
    # Fase 3: Ejecución
    # run_services
    
    # Fase 4: Resumen final
    # show_final_summary
}

# Ejecutar script principal
main