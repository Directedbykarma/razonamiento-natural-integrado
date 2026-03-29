# INSTALACION.md - Guía Completa de Instalación

## 📋 Requisitos Previos

### Sistema Operativo
- **Linux** (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- **macOS** (10.15+)
- **Windows** (WSL2 recomendado)

### Dependencias
- **Node.js** 18.0.0 o superior
- **npm** 8.0.0 o superior
- **Git** (para instalación manual)

### Espacio en Disco
- **Mínimo**: 100 MB
- **Recomendado**: 1 GB (para memoria a largo plazo)

## 🚀 Instalación Rápida (Recomendada)

### Opción 1: Un solo comando
```bash
# Instala y configura todo automáticamente
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tu-usuario/razonamiento-natural-integrado/main/scripts/setup.sh)"
```

### Opción 2: Descargar y ejecutar
```bash
# 1. Descargar script
curl -O https://raw.githubusercontent.com/tu-usuario/razonamiento-natural-integrado/main/scripts/setup.sh

# 2. Dar permisos de ejecución
chmod +x setup.sh

# 3. Ejecutar
./setup.sh
```

## 🔧 Instalación Manual Paso a Paso

### Paso 1: Clonar repositorio
```bash
git clone https://github.com/tu-usuario/razonamiento-natural-integrado.git
cd razonamiento-natural-integrado
```

### Paso 2: Instalar dependencias globales
```bash
# Instalar OpenClaw
npm install -g openclaw@latest

# Instalar AutoDream
npm install -g openclaw-autodream
```

### Paso 3: Configurar workspace
```bash
# Crear directorio workspace si no existe
mkdir -p ~/.openclaw/workspace

# Copiar configuración RNI
cp .autodream.json.template ~/.openclaw/workspace/.autodream.json

# Crear archivo de estado
cp .autodream-state.json.example ~/.openclaw/workspace/.autodream-state.json

# Crear directorio memory
mkdir -p ~/.openclaw/workspace/memory
```

### Paso 4: Configurar cron job
```bash
# Agregar a crontab
(crontab -l 2>/dev/null; echo "0 2 * * * cd ~/.openclaw/workspace && autodream run --config .autodream.json --state .autodream-state.json >> memory/autodream-cron.log 2>&1") | crontab -
```

### Paso 5: Verificar instalación
```bash
# Ejecutar script de verificación
./scripts/verify.sh
```

## ⚙️ Configuración Inicial

### Personalizar `.autodream.json`
```bash
# Editar configuración
nano ~/.openclaw/workspace/.autodream.json
```

#### Cambios recomendados:
```json
{
  "categories": [
    "People & Relationships",
    "Projects & Work", 
    "Preferences & Style",
    "Technical Decisions",
    "Important Events",
    "Lessons Learned",
    "Mi Proyecto Principal"  // ← Cambiar por tu proyecto
  ],
  
  "preservePatterns": [
    "⚠️", "IMPORTANTE", "NUNCA", "SIEMPRE",
    "CRÍTICO", "URGENTE",
    "MI_MARCADOR"  // ← Agregar tus propios marcadores
  ]
}
```

### Configurar Engram/QMD (búsqueda semántica)
```bash
# Engram se configura automáticamente en setup.sh
# Verificar configuración:
openclaw config get engram.enabled      # Debe ser "true"
openclaw config get engram.autoExtract  # Debe ser "true"
openclaw config get engram.memoryDir    # Debe ser "memory/local"

# Probar búsqueda semántica (después de usar OpenClaw)
openclaw memory search "término de búsqueda"
```

### Configurar OpenClaw (opcional)
```bash
# Verificar que OpenClaw está configurado
openclaw gateway status

# Si no está corriendo, iniciarlo
openclaw gateway start
```

## 🔍 Verificación de Instalación

### Comando de verificación
```bash
# Ejecutar verificación completa
./scripts/verify.sh
```

### Verificación manual
```bash
# 1. Verificar dependencias
node --version
npm --version
openclaw --version
autodream --version

# 2. Verificar estructura
ls -la ~/.openclaw/workspace/

# 3. Verificar configuración
python3 -m json.tool ~/.openclaw/workspace/.autodream.json

# 4. Verificar cron job
crontab -l | grep autodream

# 5. Probar AutoDream
cd ~/.openclaw/workspace && autodream stats --config .autodream.json
```

### Resultados esperados
```
✅ Node.js: v18.0.0 o superior
✅ npm: v8.0.0 o superior  
✅ OpenClaw: v1.0.0 o superior
✅ AutoDream: v1.0.0 o superior
✅ Workspace: Directorio existe
✅ Configuración: JSON válido
✅ Cron job: Configurado
✅ AutoDream: Responde correctamente
```

## 🐛 Solución de Problemas Comunes

### Problema: "Node.js no está instalado"
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node@18

# Windows (WSL2)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18
```

### Problema: "Permisos denegados para npm install -g"
```bash
# Opción 1: Usar nvm (recomendada)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18

# Opción 2: Cambiar directorio de npm
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Problema: "Cron job no se configura"
```bash
# Configurar manualmente
echo "0 2 * * * cd ~/.openclaw/workspace && autodream run --config .autodream.json --state .autodream-state.json >> memory/autodream-cron.log 2>&1" >> ~/mycron
crontab ~/mycron
rm ~/mycron
```

### Problema: "AutoDream no encuentra configuración"
```bash
# Verificar ruta
ls -la ~/.openclaw/workspace/.autodream.json

# Si no existe, crear desde template
cp .autodream.json.template ~/.openclaw/workspace/.autodream.json

# Verificar permisos
chmod 644 ~/.openclaw/workspace/.autodream.json
```

## 🔄 Actualización

### Desde versión anterior
```bash
# 1. Actualizar dependencias
npm install -g openclaw@latest
npm install -g openclaw-autodream@latest

# 2. Actualizar configuración (preservando personalizaciones)
cd ~/.openclaw/workspace
cp .autodream.json .autodream.json.backup
# Comparar manualmente con .autodream.json.template nuevo
# y aplicar cambios necesarios

# 3. Verificar
./scripts/verify.sh
```

### Desde GitHub
```bash
# Si clonaste el repositorio
cd razonamiento-natural-integrado
git pull origin main
npm run setup
```

## 🗑️ Desinstalación

### Desinstalación completa
```bash
# 1. Remover cron job
crontab -l | grep -v autodream | crontab -

# 2. Desinstalar paquetes globales
npm uninstall -g openclaw-autodream
npm uninstall -g openclaw

# 3. Remover workspace (OPCIONAL - elimina datos)
# rm -rf ~/.openclaw/workspace

# 4. Remover repositorio local
# rm -rf razonamiento-natural-integrado
```

### Desinstalación parcial (mantener datos)
```bash
# Solo remover cron job y paquetes
crontab -l | grep -v autodream | crontab -
npm uninstall -g openclaw-autodream

# Los datos en ~/.openclaw/workspace/ se mantienen
# Puedes reinstalar después
```

## 📊 Post-Instalación

### Primeros pasos después de instalar
1. **Esperar 24 horas** para primera consolidación automática
2. **Usar OpenClaw normalmente** - RNI trabajará en segundo plano
3. **Revisar MEMORY.md** después de 2-3 días para ver organización
4. **Ajustar categorías** según tus necesidades

### Monitoreo inicial
```bash
# Ver logs de cron (después de 2 AM)
tail -f ~/.openclaw/workspace/memory/autodream-cron.log

# Ver estadísticas diarias
autodream stats --config ~/.openclaw/workspace/.autodream.json

# Ver crecimiento de memoria
wc -l ~/.openclaw/workspace/MEMORY.md
```

### Optimización según uso
- **Uso intensivo**: Reducir `lookbackDays` a 30
- **Uso ligero**: Aumentar `lookbackDays` a 90  
- **Muchas conversaciones**: Reducir `maxLines` a 300
- **Conversaciones largas**: Aumentar `maxLines` a 500

## 🤝 Soporte

### Canales de ayuda
1. **Issues en GitHub**: Reportar bugs o problemas
2. **Documentación**: Revisar README.md y RNI-SISTEMA.md
3. **Script verify.sh**: Diagnóstico automático
4. **Logs**: Revisar `memory/autodream-cron.log`

### Información para reportar problemas
```bash
# Ejecutar y compartir salida
./scripts/verify.sh

# Ver versión de componentes
node --version
npm --version  
openclaw --version
autodream --version

# Ver logs de error
tail -100 ~/.openclaw/workspace/memory/autodream-cron.log
```

## ✅ Checklist de Instalación Exitosa

- [ ] Node.js 18+ instalado
- [ ] npm 8+ instalado
- [ ] OpenClaw instalado globalmente
- [ ] AutoDream instalado globalmente
- [ ] Workspace creado en `~/.openclaw/workspace/`
- [ ] Configuración RNI copiada
- [ ] Cron job configurado
- [ ] Script verify.sh pasa sin errores
- [ ] AutoDream responde a `stats` command
- [ ] OpenClaw gateway está corriendo (opcional)

---

**¡Instalación completada!** 🎉

RNI ahora trabajará automáticamente en segundo plano. La primera consolidación ocurrirá a las 2 AM de la próxima madrugada, o puedes ejecutarla manualmente con:

```bash
cd ~/.openclaw/workspace && autodream run --config .autodream.json
```

Para más información, consulta:
- [README.md](README.md) - Visión general
- [RNI-SISTEMA.md](RNI-SISTEMA.md) - Arquitectura técnica
- [scripts/verify.sh](scripts/verify.sh) - Diagnóstico