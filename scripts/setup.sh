#!/bin/bash

# RNI - Script de instalación automática
# Razonamiento-Natural-Integrado para OpenClaw

set -euo pipefail

echo "🚀 Instalando Razonamiento-Natural-Integrado (RNI)"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar comandos
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}❌ Error: $1 no está instalado${NC}"
        echo "Instala con: $2"
        exit 1
    fi
    echo -e "${GREEN}✅ $1 instalado${NC}"
}

# Función para ejecutar con verificación
run_check() {
    echo -e "${YELLOW}▶️  Ejecutando: $1${NC}"
    if eval "$1"; then
        echo -e "${GREEN}✅ Completado${NC}"
    else
        echo -e "${RED}❌ Falló: $1${NC}"
        exit 1
    fi
}

# Verificar requisitos
echo -e "\n📋 Verificando requisitos..."
check_command "node" "https://nodejs.org/"
check_command "npm" "https://npmjs.com/"
check_command "git" "https://git-scm.com/"

# Instalar OpenClaw
echo -e "\n📦 Instalando OpenClaw..."
run_check "npm install -g openclaw@latest"

# Instalar AutoDream
echo -e "\n🌙 Instalando AutoDream..."
run_check "npm install -g openclaw-autodream"

# Verificar instalación
echo -e "\n🔍 Verificando instalaciones..."
run_check "openclaw --version"
run_check "autodream --version"

# Crear directorio workspace si no existe
WORKSPACE_DIR="$HOME/.openclaw/workspace"
echo -e "\n📁 Configurando workspace en: $WORKSPACE_DIR"
mkdir -p "$WORKSPACE_DIR"

# Copiar configuración RNI
echo -e "\n⚙️  Configurando RNI..."
if [ -f "$WORKSPACE_DIR/.autodream.json" ]; then
    echo -e "${YELLOW}⚠️  .autodream.json ya existe, haciendo backup...${NC}"
    cp "$WORKSPACE_DIR/.autodream.json" "$WORKSPACE_DIR/.autodream.json.backup-$(date +%Y%m%d-%H%M%S)"
fi

# Copiar template de configuración
cp .autodream.json.template "$WORKSPACE_DIR/.autodream.json"
echo -e "${GREEN}✅ Configuración RNI copiada${NC}"

# Crear archivo de estado si no existe
if [ ! -f "$WORKSPACE_DIR/.autodream-state.json" ]; then
    cp .autodream-state.json.example "$WORKSPACE_DIR/.autodream-state.json"
    echo -e "${GREEN}✅ Archivo de estado creado${NC}"
fi

# Configurar cron job para AutoDream
echo -e "\n⏰ Configurando cron job para consolidación automática..."
CRON_JOB="0 2 * * * cd $WORKSPACE_DIR && autodream run --config .autodream.json --state .autodream-state.json >> memory/autodream-cron.log 2>&1"

# Verificar si ya existe el cron job
if crontab -l 2>/dev/null | grep -q "autodream run"; then
    echo -e "${YELLOW}⚠️  Cron job ya existe, omitiendo...${NC}"
else
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo -e "${GREEN}✅ Cron job configurado (ejecuta a las 2 AM diario)${NC}"
fi

# Crear directorio memory si no existe
mkdir -p "$WORKSPACE_DIR/memory"

# Configurar Engram/QMD (búsqueda semántica)
echo -e "\n🧠 Configurando Engram/QMD..."
if ! openclaw config get engram.enabled > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Engram no configurado, activando...${NC}"
    run_check "openclaw config set engram.enabled true"
    run_check "openclaw config set engram.memoryDir \"memory/local\""
    run_check "openclaw config set engram.autoExtract true"
    run_check "openclaw config set engram.extractOnSave true"
    echo -e "${GREEN}✅ Engram/QMD configurado${NC}"
else
    echo -e "${GREEN}✅ Engram/QMD ya está configurado${NC}"
fi

# Crear estructura de directorios para Engram
mkdir -p "$WORKSPACE_DIR/memory/local"

# Verificar instalación completa
echo -e "\n🔧 Verificación final..."
run_check "cd $WORKSPACE_DIR && autodream stats --config .autodream.json"

echo -e "\n${GREEN}🎉 RNI instalado exitosamente!${NC}"
echo ""
echo "📋 Resumen de instalación:"
echo "  • OpenClaw: ✅ Instalado"
echo "  • AutoDream: ✅ Instalado"
echo "  • Configuración RNI: ✅ Copiada"
echo "  • Cron job: ✅ Configurado (2 AM diario)"
echo "  • Workspace: $WORKSPACE_DIR"
echo ""
echo "🚀 Para comenzar:"
echo "  1. Ejecuta: cd $WORKSPACE_DIR"
echo "  2. Edita .autodream.json para personalizar categorías"
echo "  3. Usa OpenClaw normalmente - RNI trabajará en segundo plano"
echo ""
echo "📊 Para ver estadísticas:"
echo "  autodream stats --config .autodream.json"
echo ""
echo "🔄 La primera consolidación automática será a las 2 AM"
echo "   (o ejecuta manualmente: autodream run --config .autodream.json)"