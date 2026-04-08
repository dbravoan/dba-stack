# 🚀 DBA-Stack

**Repositorio Template** de alto rendimiento para **Laravel 12** y **PHP 8.4**, diseñado bajo los principios de **Arquitectura Hexagonal** y **Domain-Driven Design (DDD)**.

Utiliza como núcleo el paquete [dbravoan/dba-ddd-skeleton](https://github.com/dbravoan/dba-ddd-skeleton) y viene preconfigurado con **agentes de IA, instrucciones, skills y hooks** para que Copilot (local o Cloud Agent) construya proyectos completos de forma autónoma.

---

## 📋 Índice

- [¿Qué es este Template?](#-qué-es-este-template)
- [Tech Stack](#️-tech-stack)
- [Inicio Rápido: Usar el Template](#-inicio-rápido-usar-el-template)
- [Arquitectura](#️-arquitectura-the-hexa-way)
- [El Generador de Módulos](#-el-generador-de-módulos)
- [Agentes IA Integrados](#-agentes-ia-integrados)
- [Orquestación Automática (Prompt → Proyecto)](#-orquestación-automática-prompt--proyecto)
- [Prompts y Skills Disponibles](#-prompts-y-skills-disponibles)
- [Quality Gate](#-control-de-calidad-quality-gate)
- [Estrategia de Ramas](#-estrategia-de-ramas--despliegue)
- [Documentación Completa](#-documentación-completa)

---

## 💡 ¿Qué es este Template?

DBA-Stack es un **repositorio template** que puedes usar para crear nuevos proyectos con toda la infraestructura lista:

- **Arquitectura DDD + Hexagonal** preconfigurada
- **6 agentes personalizados** de Copilot (Orquestador, Arquitecto, Constructor, Frontend, Revisor, Explorador)
- **5 prompts reutilizables** (`/orchestrate-project`, `/new-module`, `/create-value-object`, `/quality-gate`, `/frontend-pages`)
- **Auto-chain workflow** que encadena Issues automáticamente cuando los PRs se mergean
- **2 skills multi-paso** (scaffold de módulo, quality gate)
- **Hooks de automatización** (auto-format, protección de rama `main`)
- **CI/CD completo** (GitHub Actions + deploy automático)
- **Entorno del Cloud Agent** preconfigurado (`copilot-setup-steps.yml`)

> **Resultado**: Describes tu proyecto en un prompt, el orchestrator genera todas las Issues, y el auto-chain las ejecuta secuencialmente.

---

## 🛠️ Tech Stack

| Tecnología | Versión | Propósito |
| :--- | :--- | :--- |
| **PHP** | 8.4 | Property Hooks, Asymmetric Visibility, Strict Types |
| **Laravel** | 12.x | Framework Core & Infrastructure |
| **Docker/Sail** | Latest | Entorno de desarrollo aislado y reproducible |
| **MySQL / Redis** | 8.0 / Alpine | Persistencia y Gestión de Colas/Buses |
| **Vue 3** | 3.x | Composition API + `<script setup lang="ts">` |
| **Inertia.js** | 2.x | Frontend SPA sin API separada |
| **Tailwind CSS** | 4.x | Estilos utility-first |
| **Vite** | Latest | Build tool + HMR |

---

## 🚀 Inicio Rápido: Usar el Template

### Paso 1 — Crear tu repositorio

**Desde GitHub.com:**

1. Haz clic en **"Use this template"** → **"Create a new repository"**
2. Elige nombre, owner y visibilidad
3. Marca **"Include all branches"** para incluir `dev` y `main`
4. Haz clic en **"Create repository"**

**Desde la terminal:**

```bash
gh repo create mi-proyecto --template dbravoan/dba-stack --private --clone
cd mi-proyecto
```

### Paso 2 — Configurar el proyecto

```bash
composer install
cp .env.example .env
php artisan key:generate
```

### Paso 3 — Personalizar el namespace (opcional)

En `composer.json`, cambia `DbaStack\\` por tu propio namespace:

```json
{
    "autoload": {
        "psr-4": {
            "MiApp\\": "src/"
        }
    }
}
```

```bash
composer dump-autoload
```

### Paso 4 — Configurar GitHub

1. **Settings → Copilot**: Activa Cloud Agent para el repositorio
2. **Settings → Branches**: Protege `main` (solo supervisor humano)
3. **Actions → copilot-setup-steps**: Ejecuta manualmente para validar el entorno

### Paso 5 — Crear tu primer módulo

```bash
php artisan dba:make:module MiContexto MiModulo
```

> 📖 Guía detallada: [docs/GUIA_USO_TEMPLATE.md](docs/GUIA_USO_TEMPLATE.md)

---

## 🏗️ Arquitectura (The "Hexa" Way)

La lógica de negocio reside exclusivamente en la carpeta `src/`, dividida en **Bounded Contexts**:

```
src/{Contexto}/{Modulo}/
├── Domain/           # Entidades, Value Objects, Interfaces — CERO framework
├── Application/      # Commands, Queries, Handlers — Inmutabilidad total
└── Infrastructure/   # Controllers, Eloquent, Rutas — Laravel vive aquí
```

| Capa | Reglas |
|------|--------|
| **Domain** | Entidades extienden `AggregateRoot`. Value Objects con validación. Sin `Illuminate\*`. |
| **Application** | Handlers `final readonly`. Registrados con tags `dba_ddd.command_handler` / `dba_ddd.query_handler`. |
| **Infrastructure** | Controllers extienden `ApiController`. Repositorios extienden `EloquentRepository`. |
| **Frontend** | Páginas Vue 3 en `resources/js/Pages/{Context}/{Module}/`. TypeScript + Tailwind. |

---

## ⚡ El Generador de Módulos

```bash
php artisan dba:make:module {Contexto} {Modulo}
```

Genera automáticamente las tres capas, repositorio, controladores, y comandos/consultas iniciales. Después, **los agentes (o tú) refinan** el código: métodos semánticos, validación de Value Objects, excepciones de dominio.

---

## 🤖 Agentes IA Integrados

El template incluye seis agentes personalizados que Copilot puede usar:

| Agente | Propósito | Herramientas |
|--------|-----------|-------------|
| **`orchestrator`** | Descompone una idea de proyecto en Issues ordenadas con script de creación | Lectura + Edición + Terminal |
| **`ddd-architect`** | Diseña modelos de dominio, bounded contexts, entidades y value objects | Solo lectura |
| **`module-builder`** | Construye módulos end-to-end: scaffold, domain, application, infrastructure, tests | Lectura + Edición + Terminal |
| **`code-reviewer`** | Audita código buscando violaciones de DDD, capas filtradas, o estándares PHP 8.4 | Solo lectura |
| **`frontend-builder`** | Construye páginas Vue 3 + Inertia.js, layouts, componentes y composables | Lectura + Edición + Terminal |
| **`explore`** | Exploración rápida del codebase para responder preguntas | Solo lectura |

### Cómo usarlos

**En VS Code** → Selecciona el agente desde el picker de chat

**En Cloud Agent** → Al asignar una Issue, selecciona el agente en el dropdown:

![Asignar agente](https://docs.github.com/assets/cb-103529/mw-1440/images/help/copilot/coding-agent/assign-to-copilot-dialog.webp)

---

## ⚡ Orquestación Automática (Prompt → Proyecto)

DBA-Stack cierra la brecha entre **una idea** y **un proyecto implementado**:

### El Flujo Completo

```
Tu idea (1 prompt)
     │
     ▼
/orchestrate-project  →  orchestrator agent
     │
     ├── docs/project-plan.md (plan revisable)
     └── .github/scripts/create-issues.sh (script ejecutable)
     │
     ▼
bash create-issues.sh  →  N Issues creadas con labels + dependencias
     │
     ▼
Asignar Issue #1 a Copilot  →  auto-chain se encarga del resto
     │
     ▼
  Copilot: Issue → PR → Review → Merge
     │         ↑                    │
     │         └────────────────────┘  (auto-chain asigna siguiente)
     │
     ▼
  Todas las Issues completadas → Merge dev → main → Deploy 🚀
```

### Quick Start: De Prompt a Proyecto

```bash
# 1. Crear repo desde template
gh repo create mi-app --template dbravoan/dba-stack --private --clone
cd mi-app && git checkout -b dev && git push -u origin dev

# 2. Setup de labels
bash .github/scripts/setup-labels.sh

# 3. En VS Code, usa el prompt del orchestrator:
#    /orchestrate-project "Blog de nostalgia noventera con SEO,
#    backoffice multi-redactor y publicación automática con IA"

# 4. Revisa el plan generado
cat docs/project-plan.md

# 5. Crea todas las Issues
bash .github/scripts/create-issues.sh

# 6. Asigna la primera Issue — el auto-chain hace el resto
gh issue edit 1 --add-assignee 'copilot-swe-agent[bot]'
```

### ¿Qué hace el Auto-Chain?

El workflow `copilot-auto-chain.yml` se dispara cuando un PR se mergea a `dev`:

1. Busca Issues con label `copilot-queued`
2. Verifica que todas las dependencias (`depends-on:#N`) estén cerradas
3. Asigna la Issue de menor fase a Copilot
4. Copilot trabaja → PR → tú revisas → merge → se repite

> 📖 Guía completa: [docs/ORQUESTACION_AGENTES.md](docs/ORQUESTACION_AGENTES.md)

---

## 📝 Prompts y Skills Disponibles

Escribe `/` en el chat de Copilot para acceder a estos comandos:

### Prompts (tareas de un solo paso)

| Comando | Descripción |
|---------|-------------|
| `/orchestrate-project` | Descomponer un proyecto completo en Issues ordenadas |
| `/new-module` | Scaffold de un módulo DDD nuevo |
| `/create-value-object` | Crear un Value Object con validación, excepción y test |
| `/quality-gate` | Ejecutar el triángulo de calidad completo |
| `/frontend-pages` | Crear páginas Vue/Inertia para un módulo backend existente |

### Skills (flujos multi-paso)

| Skill | Descripción |
|-------|-------------|
| `/module-scaffold` | Flujo completo de 6 fases: scaffold → domain → application → infrastructure → tests → quality gate |
| `/quality-gate` | Triángulo de calidad con guía de errores comunes de PHPStan |

---

## ✅ Control de Calidad (Quality Gate)

Todos los filtros deben pasar antes de cada PR:

```bash
vendor/bin/pint                              # Estilo de código
vendor/bin/phpstan analyse src --level=max   # Análisis estático (Level Max)
vendor/bin/phpunit                           # Tests (Unit + Integration)
npm run build                                # Frontend (si package.json existe)
```

El CI ejecuta todos automáticamente en cada push y PR.

---

## 🌲 Estrategia de Ramas & Despliegue

```
feature/mi-tarea  →  PR a dev  →  CI pasa  →  Merge  →  PR a main  →  Deploy
```

| Rama | Propósito | Quién puede mergear |
|------|-----------|---------------------|
| `main` | Producción | Solo supervisor humano |
| `dev` | Integración | Supervisor tras CI en verde |
| `feature/*` | Desarrollo | Agentes y devs |

> **Regla de Oro:** Prohibido hacer push directo a `main`.

---

## 📚 Documentación Completa

| Documento | Descripción |
|-----------|-------------|
| **[docs/GUIA_USO_TEMPLATE.md](docs/GUIA_USO_TEMPLATE.md)** | Guía paso a paso para usar el template |
| **[docs/ORQUESTACION_AGENTES.md](docs/ORQUESTACION_AGENTES.md)** | Orquestación completa: de un prompt a un proyecto (sección 9) |
| [.github/AGENT_GUIDELINES.md](.github/AGENT_GUIDELINES.md) | Directrices técnicas para agentes IA |
| [.github/PROJECT_MANAGEMENT.md](.github/PROJECT_MANAGEMENT.md) | Flujo de gestión con GitHub Projects |
| [.github/copilot-instructions.md](.github/copilot-instructions.md) | Instrucciones globales de Copilot |

---

## 🏁 Cómo Marcar como Template

Si forkeaste este repo y quieres convertirlo en template:

1. Ve a **Settings** del repositorio
2. Marca la casilla **"Template repository"**
3. Listo — aparecerá el botón "Use this template" para todos los que tengan acceso

---

Desarrollado con ❤️ por **dbravoan**.