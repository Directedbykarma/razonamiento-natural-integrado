#!/bin/bash

# RNI - Script de verificación del sistema
# Verifica que RNI esté instalado y funcionando correctamente
# Autor: DirectedbyKarma

set -euo pipefail

echo "🔍 Verificando instalación de RNI"
echo "================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

WORKSPACE_DIR="$HOME/.openclaw/workspace"
ERRORS=0

# Función para verificar
verify() {
    local description="$1"
    local command="$2"
    local fix_hint="$3"

    echo -n "• $description: "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FALLO${NC}"
        if [ -n "$fix_hint" ]; then
            echo -e "  ${YELLOW}💡 $fix_hint${NC}"
        fi
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

echo -e "\n📦 Verificando dependencias..."
verify "Node.js instalado" "node --version" "Instala Node.js desde https://nodejs.org/"
verify "npm instalado" "npm --version" "Instala npm con Node.js"
verify "OpenClaw instalado" "openclaw --version" "Ejecuta: npm install -g openclaw@latest"
verify "AutoDream instalado" "autodream --version" "Ejecuta: npm install -g openclaw-autodream"

echo -e "\n📁 Verificando estructura..."
verify "Workspace existe" "[ -d \"$WORKSPACE_DIR\" ]" "Ejecuta el script setup.sh primero"
verify "Configuración RNI existe" "[ -f \"$WORKSPACE_DIR/.autodream.json\" ]" "Ejecuta setup.sh para crear la configuración"
verify "Archivo de estado existe" "[ -f \"$WORKSPACE_DIR/.autodream-state.json\" ]" "Ejecuta setup.sh para crear el archivo de estado"
verify "Directorio memory existe" "[ -d \"$WORKSPACE_DIR/memory\" ]" "Crea: mkdir -p $WORKSPACE_DIR/memory"

echo -e "\n⚙️  Verificando configuración..."
verify "Configuración JSON válida" "cd \"$WORKSPACE_DIR\" && node -e \"JSON.parse(require('fs').readFileSync('.autodream.json','utf8'))\"" "Revisa la sintaxis de .autodream.json"
verify "Estado JSON válido" "cd \"$WORKSPACE_DIR\" && node -e \"JSON.parse(require('fs').readFileSync('.autodream-state.json','utf8'))\"" "Revisa la sintaxis de .autodream-state.json"

echo -e "\n⏰ Verificando cron job..."
verify "Cron job configurado" "crontab -l 2>/dev/null | grep -q \"autodream\"" "Ejecuta setup.sh para configurar el cron job automático"

echo -e "\n🔧 Verificando funcionalidad..."
verify "AutoDream puede leer workspace" "autodream \"$WORKSPACE_DIR\"" "Revisa permisos y configuración"
verify "OpenClaw gateway accesible" "openclaw gateway status 2>&1 | grep -q \"Runtime:\"" "Inicia OpenClaw: openclaw gateway start"

echo -e "\n🧠 Verificando Engram/QMD..."
verify "Plugin Engram instalado" "openclaw plugins list 2>/dev/null | grep -q \"openclaw-engram\"" "Ejecuta: openclaw plugins install @joshuaswarren/openclaw-engram"
verify "Plugin Engram habilitado" "openclaw plugins list 2>/dev/null | grep -q \"openclaw-engram.*enabled\"" "Ejecuta: openclaw plugins enable openclaw-engram"
verify "Directorio Engram existe" "[ -d \"$WORKSPACE_DIR/memory/local\" ]" "Crea: mkdir -p $WORKSPACE_DIR/memory/local"

echo -e "\n📊 Verificando límites..."
if [ -f "$WORKSPACE_DIR/MEMORY.md" ]; then
    LINE_COUNT=$(wc -l < "$WORKSPACE_DIR/MEMORY.md")
    echo -n "• Líneas en MEMORY.md: "
    if [ "$LINE_COUNT" -le 400 ]; then
        echo -e "${GREEN}✅ $LINE_COUNT/400${NC}"
    else
        echo -e "${YELLOW}⚠️  $LINE_COUNT/400 (sobre límite)${NC}"
        echo -e "  ${YELLOW}💡 AutoDream consolidará automáticamente a las 2 AM${NC}"
    fi
else
    echo -e "• MEMORY.md: ${YELLOW}⚠️  No existe aún${NC}"
    echo -e "  ${YELLOW}💡 Se creará automáticamente con el primer uso${NC}"
fi

# Verificar archivos de memoria recientes
echo -e "\n📅 Verificando archivos de memoria..."
MEMORY_FILES=$(find "$WORKSPACE_DIR/memory" -name "*.md" -type f 2>/dev/null | wc -l)
echo -n "• Archivos en memory/: "
if [ "$MEMORY_FILES" -gt 0 ]; then
    echo -e "${GREEN}✅ $MEMORY_FILES archivos${NC}"

    # Mostrar los 3 más recientes
    echo -e "  ${YELLOW}📁 Archivos más recientes:${NC}"
    find "$WORKSPACE_DIR/memory" -name "*.md" -type f -exec ls -lt {} + 2>/dev/null | head -3 | awk '{print "    • " $6 " " $7 " " $8 " - " $9}'
else
    echo -e "${YELLOW}⚠️  Ningún archivo aún${NC}"
    echo -e "  ${YELLOW}💡 Los archivos se crearán automáticamente con el uso${NC}"
fi

echo -e "\n📋 Resumen de verificación:"
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}🎉 RNI está instalado y funcionando correctamente!${NC}"
    echo ""
    echo "📊 Estadísticas del sistema:"
    autodream "$WORKSPACE_DIR" 2>/dev/null || echo "  (ejecuta 'autodream $WORKSPACE_DIR' para ver detalles)"
else
    echo -e "${YELLOW}⚠️  Se encontraron $ERRORS problema(s)${NC}"
    echo ""
    echo "🔧 Solución:"
    echo "  1. Revisa los mensajes de error arriba"
    echo "  2. Ejecuta: ./scripts/setup.sh"
    echo "  3. Vuelve a ejecutar: ./scripts/verify.sh"
    exit 1
fi

echo -e "\n🚀 Comandos útiles:"
echo "  • Ejecutar consolidación manual: autodream $WORKSPACE_DIR"
echo "  • Ver logs de cron: tail -f $WORKSPACE_DIR/memory/autodream-cron.log"
echo "  • Verificar OpenClaw: openclaw gateway status"
echo "  • Ver plugins: openclaw plugins list"
