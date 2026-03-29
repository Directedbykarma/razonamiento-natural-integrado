#!/bin/bash

# RNI - Script de instalación automática
# Razonamiento-Natural-Integrado para OpenClaw
# Autor: DirectedbyKarma

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
        echo "   $2"
        if [ "$1" = "openclaw" ]; then
            echo -e "${YELLOW}💡 Si OpenClaw está instalado pero no se encuentra:${NC}"
            echo "   export PATH=\"\$HOME/.npm-global/bin:\$PATH\""
            echo "   (o reinicia tu terminal después de instalar)"
        fi
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

# Verificar requisitos (para usuarios con OpenClaw ya instalado)
echo -e "\n📋 Verificando requisitos para RNI..."
check_command "openclaw" "npm install -g openclaw@latest (si no lo tienes)"
check_command "node" "https://nodejs.org/"
check_command "npm" "https://npmjs.com/"

# Instalar AutoDream (requerido para RNI)
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

# Embed template de configuración con heredoc (funciona con curl | bash)
echo -e "\n⚙️  Configurando RNI..."
if [ -f "$WORKSPACE_DIR/.autodream.json" ]; then
    echo -e "${YELLOW}⚠️  .autodream.json ya existe, haciendo backup...${NC}"
    cp "$WORKSPACE_DIR/.autodream.json" "$WORKSPACE_DIR/.autodream.json.backup-$(date +%Y%m%d-%H%M%S)"
fi

cat > "$WORKSPACE_DIR/.autodream.json" << 'EOF'
{
  "maxLines": 400,
  "lookbackDays": 60,
  "memoryDir": "memory",
  "memoryIndex": "MEMORY.md",
  "categories": [
    "People & Relationships",
    "Projects & Work",
    "Preferences & Style",
    "Technical Decisions",
    "Important Events",
    "Lessons Learned",
    "Custom Project"
  ],
  "preservePatterns": [
    "⚠️",
    "IMPORTANTE",
    "NUNCA",
    "SIEMPRE",
    "CRÍTICO",
    "URGENTE"
  ],
  "triggerThreshold": {
    "minHoursSinceLastRun": 24,
    "minNewFiles": 3
  }
}
EOF
echo -e "${GREEN}✅ Configuración RNI creada${NC}"

# Crear archivo de estado si no existe (embed con heredoc)
if [ ! -f "$WORKSPACE_DIR/.autodream-state.json" ]; then
    cat > "$WORKSPACE_DIR/.autodream-state.json" << 'EOF'
{
  "lastRun": null,
  "filesProcessedAtLastRun": []
}
EOF
    echo -e "${GREEN}✅ Archivo de estado creado${NC}"
fi

# Obtener ruta absoluta de autodream para el cron
AUTODREAM_BIN="$(which autodream)"

# Configurar cron job para AutoDream (ruta absoluta + PATH correcto)
echo -e "\n⏰ Configurando cron job para consolidación automática..."
CRON_JOB="0 2 * * * PATH=\"/usr/local/bin:/usr/bin:/bin:$HOME/.npm-global/bin\" $AUTODREAM_BIN $WORKSPACE_DIR >> $WORKSPACE_DIR/memory/autodream-cron.log 2>&1"

# Verificar si ya existe el cron job
if crontab -l 2>/dev/null | grep -q "autodream"; then
    echo -e "${YELLOW}⚠️  Cron job ya existe, omitiendo...${NC}"
else
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo -e "${GREEN}✅ Cron job configurado (ejecuta a las 2 AM diario)${NC}"
fi

# Crear directorio memory si no existe
mkdir -p "$WORKSPACE_DIR/memory"

# Configurar Engram como plugin
echo -e "\n🧠 Configurando Engram/QMD como plugin..."
if openclaw plugins list 2>/dev/null | grep -q "openclaw-engram"; then
    echo -e "${GREEN}✅ Engram ya está instalado como plugin${NC}"
else
    echo -e "${YELLOW}⚠️  Instalando plugin Engram...${NC}"
    run_check "openclaw plugins install @joshuaswarren/openclaw-engram"
    run_check "openclaw plugins enable openclaw-engram"
    echo -e "${GREEN}✅ Engram/QMD configurado como plugin${NC}"
fi

# Crear estructura de directorios para Engram
mkdir -p "$WORKSPACE_DIR/memory/local"

# Verificar instalación completa
echo -e "\n🔧 Verificación final..."
run_check "autodream $WORKSPACE_DIR"

echo -e "\n${GREEN}🎉 RNI instalado exitosamente!${NC}"
echo ""
echo "📋 Resumen de instalación:"
echo "  • OpenClaw: ✅ Verificado (ya instalado)"
echo "  • AutoDream: ✅ Instalado"
echo "  • Plugin Engram: ✅ Instalado y habilitado"
echo "  • Configuración RNI: ✅ Creada"
echo "  • Cron job: ✅ Configurado (2 AM diario)"
echo "  • Workspace: $WORKSPACE_DIR"
echo ""
echo "🚀 Para comenzar:"
echo "  1. Usa OpenClaw normalmente - RNI trabajará en segundo plano"
echo "  2. Las conversaciones se guardarán en memory/YYYY-MM-DD.md"
echo "  3. AutoDream consolidará automáticamente a las 2 AM"
echo "  4. Engram indexará semánticamente para búsquedas"
echo ""
echo "📊 Para ver estadísticas:"
echo "  autodream $WORKSPACE_DIR"
echo ""
echo "🔄 La primera consolidación automática será a las 2 AM"
echo "   (o ejecuta manualmente: autodream $WORKSPACE_DIR)"
