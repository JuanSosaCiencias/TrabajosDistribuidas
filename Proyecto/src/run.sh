#!/bin/bash
# Script para compilar y ejecutar el proyecto en iex, con ejecución automática de Main.run(10, 1)

# Compilar el proyecto
mix compile

# Ejecutar el proyecto en iex y llamar automáticamente a Main.run(10, 1)
echo "Main.run(10, 1)" | iex -S mix
