# RNI-SISTEMA.md - Arquitectura Técnica

## 🏗️ Arquitectura del Sistema

### Diagrama de Componentes
```
┌─────────────────────────────────────────────────────────────┐
│                    OpenClaw Platform                        │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   Conversa- │    │   Extracción│    │   Búsqueda  │    │
│  │   ciones    │────▶│  Semántica  │────▶│ Semántica   │    │
│  │   Diarias   │    │  (Engram)    │    │  (QMD)      │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
│         │                         │               │        │
│         ▼                         ▼               ▼        │
│  ┌─────────────┐          ┌─────────────┐ ┌─────────────┐ │
│  │  Archivos   │          │   Vector    │ │  Memoria    │ │
│  │  Diarios    │          │    DB       │ │ Organizada  │ │
│  │ (YYYY-MM-DD)│          │  (local/)   │ │ (MEMORY.md) │ │
│  └─────────────┘          └─────────────┘ └─────────────┘ │
│         │                                  ▲               │
│         └──────────────────────────────────┘               │
│                                  │                         │
│                                  ▼                         │
│                         ┌─────────────────┐                │
│                         │  Consolidación  │                │
│                         │   Natural       │                │
│                         │  (AutoDream)    │                │
│                         └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Datos

### Fase 1: Captura Diaria
```
Usuario habla con OpenClaw → Se guarda en memory/YYYY-MM-DD.md
```

### Fase 2: Extracción Semántica (Engram)
```
memory/YYYY-MM-DD.md → Engram extrae entidades/conceptos → Vector DB (local/)
```

### Fase 3: Consolidación Natural (AutoDream)
```
Cada 24h (2 AM):
  1. Lee archivos de los últimos 60 días
  2. Elimina duplicados (exactos + fuzzy)
  3. Organiza por 7 categorías
  4. Limita a 400 líneas máximo
  5. Escribe MEMORY.md organizado
  6. Hace backup automático
```

### Fase 4: Búsqueda Semántica (QMD)
```
Usuario pregunta → QMD busca en Vector DB + MEMORY.md → Respuesta con contexto
```

## ⚙️ Configuración Técnica

### Archivo `.autodream.json`
```json
{
  "maxLines": 400,           // Límite de líneas en MEMORY.md
  "lookbackDays": 60,        // Días a considerar para consolidación
  "memoryDir": "memory",     // Directorio de archivos diarios
  "memoryIndex": "MEMORY.md", // Archivo de memoria consolidada
  
  "categories": [            // 7 categorías personalizables
    "People & Relationships",
    "Projects & Work",
    "Preferences & Style",
    "Technical Decisions",
    "Important Events",
    "Lessons Learned",
    "Custom Project"         // Reemplazar con proyecto del usuario
  ],
  
  "preservePatterns": [      // Patrones que NUNCA se eliminan
    "⚠️", "IMPORTANTE", "NUNCA", "SIEMPRE", "CRÍTICO", "URGENTE"
  ],
  
  "triggerThreshold": {      // Cuándo ejecutar consolidación
    "minHoursSinceLastRun": 24,  // Mínimo 24h entre ejecuciones
    "minNewFiles": 3             // Mínimo 3 archivos nuevos
  }
}
```

### Archivo `.autodream-state.json`
```json
{
  "lastRun": "2026-03-29T00:00:00.000Z",  // Última ejecución
  "filesProcessedAtLastRun": [            // Archivos procesados
    "2026-03-25.md",
    "2026-03-26.md",
    "2026-03-27.md",
    "2026-03-28.md"
  ]
}
```

## 📊 Métricas y Límites

### Límites Operacionales
| Métrica | Valor | Descripción |
|---------|-------|-------------|
| Líneas máximas | 400 | Límite en MEMORY.md |
| Días lookback | 60 | Archivos a considerar |
| Categorías | 7 | Organización temática |
| Duplicados fuzzy | 90% | Similitud para eliminar |
| Tiempo entre runs | 24h | Mínimo entre ejecuciones |

### Estadísticas de Ejemplo
```
Entradas brutas procesadas: 1006
Duplicados exactos eliminados: 9
Duplicados fuzzy eliminados: 398
Entradas finales: 258
Líneas finales: 263/400 (66%)
Tasa de compresión: 4:1
```

## 🛡️ Consideraciones de Seguridad

### Separación Estado/Configuración
```
✅ CORRECTO:
  .autodream.json.template → Configuración estática (subir a Git)
  .autodream-state.json → Estado mutable (NO subir a Git)
  
❌ INCORRECTO:
  .autodream.json con "lastRun" incluido → Mezcla estado/config
```

### Exclusión de Git
```gitignore
# NO SUBIR:
memory/                    # Datos personales
MEMORY.md                  # Memoria consolidada
.autodream-state.json      # Estado mutable
.openclaw/workspace/.autodream.json  # Config con estado

# SUBIR:
.autodream.json.template   # Configuración base
.autodream-state.json.example  # Ejemplo de estado
scripts/                   # Scripts de instalación
```

## 🔧 Mantenimiento y Operaciones

### Cron Job Automático
```bash
# Ejecuta diario a las 2 AM
0 2 * * * cd ~/.openclaw/workspace && autodream run --config .autodream.json --state .autodream-state.json >> memory/autodream-cron.log 2>&1
```

### Comandos de Mantenimiento
```bash
# Verificar estado del sistema
./scripts/verify.sh

# Ejecutar consolidación manual
autodream run --config ~/.openclaw/workspace/.autodream.json

# Ver estadísticas
autodream stats --config ~/.openclaw/workspace/.autodream.json

# Ver logs
tail -f ~/.openclaw/workspace/memory/autodream-cron.log

# Restaurar desde backup
cp ~/.openclaw/workspace/.autodream-backups/*.json ~/.openclaw/workspace/.autodream.json
```

### Backup Automático
```
Cada ejecución de AutoDream crea:
  ~/.openclaw/workspace/.autodream-backups/YYYY-MM-DD-HHMM.json
  ~/.openclaw/workspace/.autodream-reports/YYYY-MM-DD-HHMM.md
```

## 🐛 Diagnóstico de Problemas

### Síntoma: "No hay consolidación"
```bash
# 1. Verificar cron job
crontab -l | grep autodream

# 2. Verificar permisos
ls -la ~/.openclaw/workspace/.autodream.json

# 3. Verificar límites
wc -l ~/.openclaw/workspace/MEMORY.md

# 4. Ejecutar manualmente con debug
autodream run --config ~/.openclaw/workspace/.autodream.json --verbose
```

### Síntoma: "Configuración inválida"
```bash
# Validar JSON
python3 -m json.tool ~/.openclaw/workspace/.autodream.json

# Restaurar desde template
cp .autodream.json.template ~/.openclaw/workspace/.autodream.json
```

### Síntoma: "Memoria no se busca"
```bash
# Verificar Engram
openclaw config get engram.enabled

# Verificar Vector DB
ls -la ~/.openclaw/workspace/memory/local/

# Probar búsqueda
openclaw memory search "término de prueba"
```

## 📈 Optimización de Performance

### Para muchos archivos (>100)
```json
{
  "lookbackDays": 30,        // Reducir de 60 a 30 días
  "maxLines": 300,           // Reducir límite
  "triggerThreshold": {
    "minHoursSinceLastRun": 12,  // Ejecutar 2x al día
    "minNewFiles": 5             // Requerir más archivos nuevos
  }
}
```

### Para poca actividad
```json
{
  "lookbackDays": 90,        // Aumentar ventana
  "triggerThreshold": {
    "minHoursSinceLastRun": 48,  // Ejecutar cada 2 días
    "minNewFiles": 1             // Con solo 1 archivo nuevo
  }
}
```

## 🔄 Migración y Actualización

### De versión anterior
```bash
# 1. Backup actual
cp ~/.openclaw/workspace/.autodream.json ~/.autodream.json.backup

# 2. Extraer configuración (sin estado)
jq 'del(.lastRun, .filesProcessedAtLastRun)' ~/.openclaw/workspace/.autodream.json > config.json

# 3. Crear archivo de estado
echo '{"lastRun": null, "filesProcessedAtLastRun": []}' > ~/.openclaw/workspace/.autodream-state.json

# 4. Usar nueva configuración
cp .autodream.json.template ~/.openclaw/workspace/.autodream.json
# Editar con valores de config.json
```

### A nueva versión
```bash
# 1. Actualizar scripts
git pull origin main

# 2. Ejecutar setup (preserva configuración)
./scripts/setup.sh

# 3. Verificar migración
./scripts/verify.sh
```

## 🎯 Mejores Prácticas

### Para usuarios nuevos
1. **Comenzar con defaults** → No modificar configuración inicial
2. **Usar por 1 semana** → Dejar que el sistema aprenda patrones
3. **Personalizar gradualmente** → Ajustar categorías según uso real
4. **Revisar MEMORY.md semanal** → Verificar organización automática

### Para desarrolladores
1. **Separar estado/config** → Nunca mezclar en mismo archivo
2. **Versionar templates** → No versionar archivos con estado
3. **Documentar cambios** → Actualizar RNI-SISTEMA.md con modificaciones
4. **Probar con datos reales** → Validar con workload real, no sintético

### Para producción
1. **Monitorear logs** → Revisar `memory/autodream-cron.log` semanal
2. **Verificar backups** → Confirmar que `.autodream-backups/` tiene copias
3. **Auditar seguridad** → Revisar que no hay datos sensibles en Git
4. **Planear capacidad** → Ajustar límites según crecimiento esperado

## 📚 Referencias Técnicas

### Engram (Razonamiento Semántico)
- **Base vectorial**: QMD (Query Matching Database)
- **Extracción automática**: `engram.autoExtract: true`
- **Extracción on-save**: `engram.extractOnSave: true`
- **Directorio índice**: `memory/local/`
- **Entidades**: Personas, proyectos, conceptos técnicos
- **Relaciones**: Conexiones entre entidades extraídas
- **Indexado**: Automático de conversaciones en tiempo real
- **Búsqueda**: Semántica por significado, no keyword-based
- **Configuración automática**: Script setup.sh activa y configura

### AutoDream (Consolidación Natural)
- **Deduplicación**: Exacta (100%) + Fuzzy (90%+ similitud)
- **Organización**: 7 categorías configurables
- **Límites**: 400 líneas, escalable
- **Programación**: Cron-based, configurable

### OpenClaw Integration
- **Platform**: Base para conversaciones
- **Memory API**: Acceso a memoria organizada
- **Search API**: Búsqueda semántica integrada
- **Config API**: Gestión de configuración

---

**Última actualización**: 2026-03-29  
**Versión RNI**: 1.0.0  
**Estado**: Producción estable