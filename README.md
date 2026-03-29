# Razonamiento-Natural-Integrado (RNI)

![RNI Logo](https://img.shields.io/badge/RNI-Razonamiento_Natural_Integrado-blue)
![OpenClaw](https://img.shields.io/badge/OpenClaw-Plugin-green)
![AutoDream](https://img.shields.io/badge/AutoDream-Consolidación-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Install](https://img.shields.io/badge/Install-One_Command-brightgreen)

**Instalación en un comando:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tu-usuario/razonamiento-natural-integrado/main/scripts/setup.sh)"
```

**Sistema de memoria avanzada para OpenClaw** que combina razonamiento semántico con consolidación natural y organización integrada.

## 🎯 ¿Qué es RNI?

RNI es un sistema de memoria que reemplaza el sistema básico de OpenClaw con:

- **🧠 Razonamiento Semántico** (Engram + QMD)
- **🌙 Consolidación Natural** (AutoDream automático)
- **🔗 Organización Integrada** (Sistema unificado)

## 🏗️ Arquitectura

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   OpenClaw  │    │   Engram    │    │  AutoDream  │
│  (Plataforma)│───▶│(Razonamiento)│───▶│(Natural)    │
└─────────────┘    └─────────────┘    └─────────────┘
```

## ✨ Características

### 🧠 Razonamiento (Engram/QMD)
- **Búsqueda semántica** por significado (no keywords)
- **Base vectorial** con QMD (Query Matching Database)
- **Extracción automática** de entidades y conceptos
- **Indexado en tiempo real** de conversaciones
- **Native knowledge** integrado en OpenClaw

### 🌙 Natural (AutoDream)
- **Consolidación automática** cada 24h (2 AM)
- **Eliminación de duplicados** (exactos + fuzzy matching)
- **Organización por categorías** (7 personalizables)
- **Límites inteligentes** (400 líneas máximo)
- **Backups automáticos** de cada consolidación

### 🔗 Integrado (Sistema RNI)
- **Instalación automática** en un comando
- **Cron programado** para consolidación diaria
- **Configuración Engram+AutoDream** optimizada
- **Verificación completa** del sistema
- **Workspace estructurado** listo para producción

## 🚀 Instalación Rápida

### Opción 1: Instalación automática (recomendada)
```bash
# Un solo comando instala y configura todo
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tu-usuario/razonamiento-natural-integrado/main/scripts/setup.sh)"
```

### Opción 2: Instalación manual
```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/razonamiento-natural-integrado.git
cd razonamiento-natural-integrado

# Ejecutar instalación
npm run setup

# Verificar instalación
npm run verify
```

## ⚙️ Configuración

### Archivos principales:
- **`.autodream.json.template`** → Configuración del sistema (copia a `~/.openclaw/workspace/.autodream.json`)
- **`.autodream-state.json.example`** → Estado del sistema (copia a `~/.openclaw/workspace/.autodream-state.json`)

### Personalización:
Edita `~/.openclaw/workspace/.autodream.json` para:

1. **Cambiar categorías** (7 categorías personalizables)
2. **Ajustar límites** (400 líneas por defecto)
3. **Modificar patrones preservados** (marcadores importantes)
4. **Configurar triggers** (cuándo ejecutar consolidación)

## 📊 Estadísticas del Sistema

```bash
# Ejecutar consolidación / ver estadísticas
autodream ~/.openclaw/workspace

# Ver logs de cron
tail -f ~/.openclaw/workspace/memory/autodream-cron.log
```

## 🔧 Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `npm run setup` | Instala y configura RNI |
| `npm run verify` | Verifica instalación correcta |
| `autodream ~/.openclaw/workspace` | Ejecuta consolidación manual |
| `openclaw plugins list` | Ver plugins instalados |
| `openclaw gateway status` | Verifica estado de OpenClaw |

## 📁 Estructura del Proyecto

```
razonamiento-natural-integrado/
├── README.md              # Este archivo
├── LICENSE               # Licencia MIT
├── package.json          # Metadatos del proyecto
├── .gitignore           # Archivos excluidos de Git
├── .autodream.json.template     # Configuración del sistema
├── .autodream-state.json.example # Estado del sistema
└── scripts/
    ├── setup.sh         # Instalación automática
    └── verify.sh        # Verificación del sistema
```

## 🎯 Casos de Uso

### Para desarrolladores de OpenClaw:
- **Memoria organizada** automáticamente
- **Búsqueda semántica** de conversaciones pasadas
- **Consolidación inteligente** sin intervención manual

### Para proyectos de IA:
- **Base de conocimiento** estructurada
- **Extracción automática** de insights
- **Organización por categorías** personalizadas

### Para usuarios avanzados:
- **Sistema auto-gestionado** (2 AM diario)
- **Backups automáticos** de memoria
- **Límites inteligentes** (evita sobrecarga)

## 🔄 Flujo de Trabajo

1. **Uso normal** → Conversaciones se guardan en archivos diarios
2. **Extracción** → Engram indexa contenido semánticamente
3. **Consolidación** → AutoDream organiza y elimina duplicados (2 AM)
4. **Búsqueda** → Consultas semánticas en memoria organizada
5. **Backup** → Copias automáticas de cada consolidación

## ⚠️ Consideraciones de Seguridad

### NO incluir en Git:
- `~/.openclaw/workspace/.autodream.json` (contiene estado mutable)
- `~/.openclaw/workspace/.autodream-state.json` (estado operacional)
- `~/.openclaw/workspace/memory/` (datos personales)
- `~/.openclaw/workspace/MEMORY.md` (memoria consolidada)

### Archivos seguros para compartir:
- `.autodream.json.template` (configuración base)
- `.autodream-state.json.example` (ejemplo de estado)
- Scripts de instalación/verificación

## 🐛 Solución de Problemas

### Problema: "AutoDream no se ejecuta"
```bash
# Verificar cron job
crontab -l | grep autodream

# Ejecutar manualmente
autodream ~/.openclaw/workspace
```

### Problema: "Configuración inválida"
```bash
# Validar JSON
node -e "JSON.parse(require('fs').readFileSync('$HOME/.openclaw/workspace/.autodream.json','utf8')); console.log('JSON válido')"

# Restaurar desde template: ejecuta setup.sh de nuevo
```

### Problema: "Memoria no se consolida"
```bash
# Verificar límite de líneas
wc -l ~/.openclaw/workspace/MEMORY.md

# Forzar consolidación
autodream ~/.openclaw/workspace
```

### Problema: "Engram no está disponible"
```bash
# Instalar y habilitar plugin
openclaw plugins install @joshuaswarren/openclaw-engram
openclaw plugins enable openclaw-engram

# Verificar
openclaw plugins list
```

## 📈 Roadmap

### Próximas características:
- [ ] Dashboard web de monitoreo
- [ ] Export/import de memorias entre workspaces
- [ ] Integración con más backends vectoriales
- [ ] Plugin para editores (VSCode, NeoVim)
- [ ] API REST para consultas programáticas

### Mejoras planeadas:
- [ ] Métricas de pruning (qué se eliminó y por qué)
- [ ] Alertas de límites cercanos
- [ ] Soporte para múltiples namespaces
- [ ] Backup en cloud automático

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Añade nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🙏 Agradecimientos

- **OpenClaw** por la plataforma base
- **AutoDream** por el sistema de consolidación natural
- **Engram/QMD** por el razonamiento semántico
- **Comunidad OpenClaw** por feedback y testing

---

**RNI** - Porque la memoria debería ser inteligente, no manual. 🧠🌙🔗

*Autor: [DirectedbyKarma](https://github.com/DirectedbyKarma)*