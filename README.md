Versión: Sonoma 14.3
Proyecto: main.
Descripción del proyecto: Base para todos los proyectos.

Requisitos
-Docker desktop = 4.29.0
-Docker engine = 26.0.0
-Workbench ó
-dbeaver >= 23.1.5.202308201919
-git >= 2.39.2

# -------------------------------------------------------------------
# Clonar el repositorio bellesa
# -------------------------------------------------------------------

# 1.-Ubicarse en el directorio Documentos
cd Documents
# 2.-Descargar el repositorio bellesa
git clone https://github.com/carlosjuanco/bellesa.git
# 3.-Entrar en la carpeta bellesa
cd bellesa

# -------------------------------------------------------------------
# En caso que no tengamos el contenedor que tiene instalado PHP8.1.28
# y composer 2.5.8, lo podemos realizar con los pasos siguientes:
# -------------------------------------------------------------------

# 1.-Entramos en el proyecto bellesa.
# 2.-Ejecutar el archivo bash
./create_imagen_for_the_api.sh

# -------------------------------------------------------------------
# Sí ya tenemos el contenedor que tiene instalado PHP8.1.28 y composer
# 2.5.8, entonces seguimos los pasos siguientes:
# -------------------------------------------------------------------

# 1.-Ejecutar el archivo bash
./create_development_environment.sh