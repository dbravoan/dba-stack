# 📖 Guía de Uso del Template DBA-Stack

Esta guía explica paso a paso cómo utilizar **DBA-Stack** como repositorio template para iniciar un nuevo proyecto con arquitectura DDD y Hexagonal sobre Laravel 12.

---

## Índice

1. [Requisitos Previos](#1-requisitos-previos)
2. [Crear un Repositorio desde el Template](#2-crear-un-repositorio-desde-el-template)
3. [Configuración Inicial del Proyecto](#3-configuración-inicial-del-proyecto)
4. [Personalizar el Proyecto](#4-personalizar-el-proyecto)
5. [Configurar GitHub para Agentes](#5-configurar-github-para-agentes)
6. [Primer Módulo: Scaffold con el Generador](#6-primer-módulo-scaffold-con-el-generador)
7. [Flujo de Trabajo Diario](#7-flujo-de-trabajo-diario)
8. [Estructura de Archivos del Template](#8-estructura-de-archivos-del-template)

---

## 1. Requisitos Previos

- **GitHub**: Cuenta con plan que soporte Copilot (Pro, Pro+, Business o Enterprise)
- **PHP 8.4** con extensiones: mbstring, dom, curl, libxml, mysql, bcmath, pdo_mysql
- **Composer** 2.x
- **Docker** y **Docker Compose** (opcional, para desarrollo local con Sail)
- **Git** configurado con tu cuenta de GitHub

---

## 2. Crear un Repositorio desde el Template

### Opción A: Desde GitHub.com

1. Ve al repositorio template en GitHub
2. Haz clic en el botón verde **"Use this template"** → **"Create a new repository"**
3. Configura:
   - **Owner**: Tu usuario u organización
   - **Repository name**: Nombre de tu nuevo proyecto (ej: `mi-app-ddd`)
   - **Visibility**: Public o Private
   - **Include all branches**: Marca esta opción para incluir `dev` y `main`
4. Haz clic en **"Create repository"**

### Opción B: Desde la terminal con GitHub CLI

```bash
gh repo create mi-app-ddd --template dbravoan/dba-stack --private --clone
cd mi-app-ddd
```

### Opción C: Pidiendo a Copilot Cloud Agent

Desde la página de **"New repository"** en GitHub, puedes usar el prompt de Copilot para generar el repositorio directamente desde el template.

---

## 3. Configuración Inicial del Proyecto

Una vez creado el repositorio, configura tu entorno local:

```bash
# 1. Clona el repositorio (si no usaste --clone)
git clone git@github.com:tu-usuario/mi-app-ddd.git
cd mi-app-ddd

# 2. Instala dependencias
composer install

# 3. Configura el entorno
cp .env.example .env
php artisan key:generate

# 4. (Con Docker/Sail) Levanta los servicios
./vendor/bin/sail up -d

# 5. Ejecuta migraciones
./vendor/bin/sail artisan migrate

# 6. Verifica que todo funciona
./vendor/bin/sail test
```

### Sin Docker (PHP local)

```bash
composer install
cp .env.example .env
php artisan key:generate
# Configura tu .env con tu base de datos local
php artisan migrate
vendor/bin/phpunit
```

---

## 4. Personalizar el Proyecto

### 4.1 Renombrar el namespace del proyecto

En `composer.json`, cambia el namespace raíz de `DbaStack\\` a tu propio namespace:

```json
{
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "MiApp\\": "src/"
        }
    }
}
```

Luego ejecuta:

```bash
composer dump-autoload
```

### 4.2 Actualizar metadatos

Edita estos archivos con los datos de tu proyecto:

| Archivo | Qué cambiar |
|---------|-------------|
| `composer.json` | `name`, `description`, `keywords` |
| `.env.example` | `APP_NAME`, `DB_DATABASE` |
| `README.md` | Nombre, descripción y badge URLs |
| `docker-compose.yml` | `COMPOSE_PROJECT_NAME` si hay colisiones |

### 4.3 Actualizar instrucciones de Copilot

El archivo `.github/copilot-instructions.md` contiene las instrucciones que Copilot lee automáticamente. Actualiza las referencias al namespace si lo cambiaste.

---

## 5. Configurar GitHub para Agentes

Para que los agentes (Copilot Cloud Agent y agentes locales) trabajen correctamente:

### 5.1 Activar Copilot Cloud Agent

1. Ve a **Settings** → **Copilot** → **Policies** en tu repositorio
2. Activa **Copilot cloud agent** (debe estar habilitado a nivel organización o cuenta)

### 5.2 Proteger las ramas

En **Settings** → **Branches**, crea estas reglas:

**Regla para `main`:**
- ✅ Require a pull request before merging
- ✅ Require status checks to pass (CI Quality Assurance)
- ✅ Restrict pushes: Solo tú (supervisor humano)

**Regla para `dev`:**
- ✅ Require status checks to pass
- ❌ Allow force pushes: Desactivado

### 5.3 Crear el entorno `copilot` (Opcional)

Si necesitas variables de entorno para el cloud agent:

1. **Settings** → **Environments** → **New environment** → `copilot`
2. Añade secrets/variables que el agente necesite (claves API, etc.)

### 5.4 Configurar GitHub Projects (Opcional)

Crea un Project Board con las columnas:
1. **Backlog** → **Todo** → **In Progress** → **Review** → **Staging** → **Done**

Esto te da visibilidad completa del flujo de trabajo con agentes.

---

## 6. Primer Módulo: Scaffold con el Generador

Crea tu primer módulo DDD:

```bash
php artisan dba:make:module MiContexto MiModulo
```

Esto genera la estructura completa:

```
src/MiContexto/MiModulo/
├── Domain/           # Entidades, Value Objects, Interfaces
├── Application/      # Commands, Queries, Handlers
└── Infrastructure/   # Controllers, Repositorios Eloquent, Rutas
```

### Verificar con el Quality Gate

```bash
vendor/bin/pint                              # Estilo de código
vendor/bin/phpstan analyse src --level=max   # Análisis estático
vendor/bin/phpunit                           # Tests
```

---

## 7. Flujo de Trabajo Diario

### Con Copilot Cloud Agent (GitHub)

1. **Crea una Issue** describiendo el módulo o la funcionalidad
2. **Asigna la Issue a Copilot** (Assignees → Copilot)
3. Configura: **Branch base** → `dev`, **Custom agent** → `module-builder`
4. Copilot crea un PR automáticamente contra `dev`
5. **Revisa el PR**, pide cambios mencionando `@copilot` si es necesario
6. **Merge a `dev`** cuando estés satisfecho
7. Cuando `dev` esté estable, crea PR: `dev` → `main` para desplegar

### Con Copilot en VS Code (Local)

1. Abre el chat de Copilot
2. Usa los prompts integrados:
   - `/new-module` → Scaffold de un módulo nuevo
   - `/create-value-object` → Crear un Value Object con validación y tests
   - `/quality-gate` → Ejecutar el triángulo de calidad
3. O usa los agentes especializados:
   - `@ddd-architect` → Diseño de dominio
   - `@module-builder` → Construcción completa de módulo
   - `@code-reviewer` → Auditoría de arquitectura

### Flujo Git

```
feature/mi-tarea  →  PR a dev  →  CI pasa  →  Merge a dev  →  PR a main  →  Deploy
```

---

## 8. Estructura de Archivos del Template

```
dba-stack/
├── .github/
│   ├── agents/                       # Agentes personalizados de Copilot
│   │   ├── code-reviewer.agent.md    #   Auditoría de código
│   │   ├── ddd-architect.agent.md    #   Diseño de dominio
│   │   ├── explore.agent.md          #   Exploración del codebase
│   │   ├── frontend-builder.agent.md #   Construcción de frontend Vue/Inertia
│   │   ├── module-builder.agent.md   #   Construcción de módulos backend
│   │   └── orchestrator.agent.md     #   Descomposición de proyectos en Issues
│   ├── hooks/                        # Hooks de agente (automatización)
│   │   ├── quality-enforcement.json  #   Configuración de hooks
│   │   └── scripts/                  #   Scripts de enforcement
│   ├── instructions/                 # Instrucciones por capa (auto-attached)
│   │   ├── application-layer.instructions.md
│   │   ├── domain-layer.instructions.md
│   │   ├── frontend-layer.instructions.md
│   │   ├── infrastructure-layer.instructions.md
│   │   └── testing.instructions.md
│   ├── ISSUE_TEMPLATE/               # Formularios de Issues para agentes
│   │   ├── code-audit.yml            #   Auditoría con code-reviewer
│   │   ├── config.yml                #   Configuración de Issue picker
│   │   ├── cross-cutting.yml         #   Auth, middleware, scheduler
│   │   ├── domain-design.yml         #   Diseño con ddd-architect
│   │   ├── frontend-pages.yml        #   Páginas Vue/Inertia por módulo
│   │   ├── frontend-setup.yml        #   Setup inicial de frontend
│   │   └── module-scaffold.yml       #   Scaffold de módulo DDD
│   ├── prompts/                      # Prompts reutilizables (/slash commands)
│   │   ├── create-value-object.prompt.md
│   │   ├── frontend-pages.prompt.md
│   │   ├── new-module.prompt.md
│   │   ├── orchestrate-project.prompt.md
│   │   └── quality-gate.prompt.md
│   ├── scripts/                      # Scripts de orquestación
│   │   ├── create-issues.template.sh #   Plantilla para creación de Issues
│   │   └── setup-labels.sh           #   Setup de labels de GitHub
│   ├── skills/                       # Skills multi-paso
│   │   ├── module-scaffold/          #   Scaffolding completo
│   │   └── quality-gate/             #   Triángulo de calidad
│   ├── workflows/                    # GitHub Actions
│   │   ├── ci.yml                    #   CI: Pint + PHPStan + PHPUnit + npm build
│   │   ├── copilot-auto-chain.yml    #   Auto-asignación de Issues en cadena
│   │   ├── copilot-setup-steps.yml   #   Entorno del Cloud Agent
│   │   └── deploy.yml                #   CD: Despliegue a producción (SSR)
│   ├── AGENT_GUIDELINES.md           # Directrices técnicas para agentes
│   ├── copilot-instructions.md       # Instrucciones globales de Copilot
│   ├── PROJECT_MANAGEMENT.md         # Flujo de gestión con GitHub Projects
│   └── PULL_REQUEST_TEMPLATE.md      # Template de PR con checklists
│   ├── AGENT_GUIDELINES.md           # Directrices para agentes IA
│   ├── copilot-instructions.md       # Instrucciones globales de Copilot
│   ├── PROJECT_MANAGEMENT.md         # Flujo de gestión de proyecto
│   └── PULL_REQUEST_TEMPLATE.md      # Template para PRs
├── docs/                             # Documentación del proyecto
├── src/                              # Código de dominio (Bounded Contexts)
├── app/                              # Laravel Application (Bootstrap)
├── tests/                            # Tests (Unit, Integration, Architecture)
├── composer.json
├── docker-compose.yml
├── phpstan.neon
└── pint.json
```

---

## Siguiente Paso

Consulta la [Guía de Orquestación de Agentes](ORQUESTACION_AGENTES.md) para aprender a automatizar el desarrollo completo de un proyecto usando Copilot Cloud Agent.
