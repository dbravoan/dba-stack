# 🤖 Guía de Orquestación de Agentes

Esta guía explica cómo utilizar **Copilot Cloud Agent** para desarrollar un proyecto completo de forma autónoma a partir del template DBA-Stack.

---

## Índice

1. [Cómo Funciona el Cloud Agent](#1-cómo-funciona-el-cloud-agent)
2. [Preparación del Repositorio](#2-preparación-del-repositorio)
3. [Orquestación Paso a Paso: Proyecto Completo](#3-orquestación-paso-a-paso-proyecto-completo)
4. [Agentes Personalizados y Prompts de Ejemplo](#4-agentes-personalizados-y-prompts-de-ejemplo)
5. [Escribir Issues Efectivas para Copilot](#5-escribir-issues-efectivas-para-copilot)
6. [Orquestación desde Diferentes Plataformas](#6-orquestación-desde-diferentes-plataformas)
7. [Revisión y Supervisión](#7-revisión-y-supervisión)
8. [Ejemplo Práctico: Proyecto E-Commerce Completo](#8-ejemplo-práctico-proyecto-e-commerce-completo)
9. [Orquestación Automática: De un Prompt a un Proyecto](#9-orquestación-automática-de-un-prompt-a-un-proyecto)

---

## 1. Cómo Funciona el Cloud Agent

Cuando asignas una Issue a Copilot:

1. **Copilot lee** el título, descripción y cualquier instrucción adicional de la Issue
2. **Lee las instrucciones del repositorio**: `.github/copilot-instructions.md`, instrucciones de capa, y agentes personalizados
3. **Ejecuta `copilot-setup-steps.yml`**: Instala PHP 8.4, Composer, dependencias — todo listo antes de trabajar
4. **Investiga el código** existente para entender patrones y convenciones
5. **Implementa los cambios** siguiendo las directrices del repositorio
6. **Ejecuta validaciones** (Pint, PHPStan, PHPUnit) si las instrucciones lo indican
7. **Crea un Pull Request** contra la rama que configuraste (siempre `dev`)
8. **Te solicita revisión** cuando termina

### Qué Lee Copilot Automáticamente

| Archivo | Propósito |
|---------|-----------|
| `.github/copilot-instructions.md` | Reglas globales del proyecto |
| `.github/instructions/*.instructions.md` | Reglas específicas por capa/archivo |
| `.github/agents/*.agent.md` | Agentes personalizados disponibles |
| `.github/hooks/*.json` | Hooks de automatización |
| `.github/workflows/copilot-setup-steps.yml` | Configuración del entorno |

---

## 2. Preparación del Repositorio

Antes de orquestar, asegúrate de que tu repositorio esté listo:

### Checklist

- [ ] Repositorio creado desde el template DBA-Stack
- [ ] Copilot Cloud Agent habilitado en el repositorio
- [ ] Rama `dev` creada como rama de integración
- [ ] Branch protection configurado (ver [Guía de uso](GUIA_USO_TEMPLATE.md#5-configurar-github-para-agentes))
- [ ] `copilot-setup-steps.yml` validado (ejecutar manualmente desde Actions)
- [ ] Namespace personalizado en `composer.json` si cambió

---

## 3. Orquestación Paso a Paso: Proyecto Completo

### Estrategia: Crear Issues en orden de dependencia

El Cloud Agent trabaja en una Issue a la vez. Para un proyecto completo, crea Issues secuenciales que se construyen una sobre otra.

### Fase 1 — Configuración Base

**Issue #1: "Configurar módulo Identity/User"**
```markdown
## Descripción
Crear el módulo Identity/User que servirá como referencia para el resto del proyecto.

## Requisitos
- Usar `php artisan dba:make:module Identity User`
- Entidad User con: UserId, UserName, UserEmail, UserPassword
- Value Objects con validación: email válido, nombre no vacío, password mínimo 8 chars
- CRUD completo: Create, Find, Search, Update, Delete
- Tests unitarios para todos los Value Objects
- Tests de integración para los endpoints

## Instrucciones adicionales
- Seguir las directrices de `.github/AGENT_GUIDELINES.md`
- La rama base debe ser `dev`
- Ejecutar el quality gate antes de crear el PR
```

**Asignar:** Copilot → Branch base: `dev`

### Fase 2 — Módulos de Dominio

Crea una Issue por cada módulo, especificando dependencias:

**Issue #2: "Crear módulo Catalog/Product"**
```markdown
## Descripción
Crear el módulo de productos con las siguientes entidades y reglas de negocio.

## Entidad Product
- ProductId (UUID)
- ProductName (string, 3-255 chars)
- ProductPrice (float, > 0)
- ProductDescription (string, opcional)
- ProductStatus (enum: draft, published, archived)

## Reglas de Negocio
- Un producto solo puede publicarse si tiene nombre, precio y descripción
- Un producto archivado no puede volver a publicarse
- El precio no puede ser negativo

## Requisitos Técnicos
- Scaffold: `php artisan dba:make:module Catalog Product`
- Tests unitarios para validación de Value Objects
- Tests para las transiciones de estado
- Ejecutar quality gate completo
```

### Fase 3 — Relaciones entre Módulos

**Issue #3: "Conectar módulos Catalog y Identity"**
```markdown
## Descripción
Añadir la relación entre User (creador) y Product.

## Requisitos
- Añadir ProductCreatorId (Value Object) al módulo Catalog/Product
- El creador se identifica por UserId del módulo Identity
- Al crear un producto, validar que el creador existe
- Endpoint protegido: solo usuarios autenticados pueden crear productos
```

### Fase 4 — Integración y Refinamiento

Crea Issues para:
- Middleware de autenticación
- Documentación API
- Seeders y factories
- Optimización de queries con Criteria

---

## 4. Agentes Personalizados y Prompts de Ejemplo

El template incluye cuatro agentes. A continuación se detalla **cuándo usar cada uno** y **ejemplos concretos de prompts** que producen resultados óptimos.

---

### 4.1 `ddd-architect` — Diseño de Dominio

**Cuándo:** Antes de implementar un módulo complejo. Ideal para planificar entidades, value objects, eventos de dominio y relaciones entre bounded contexts.

**Herramientas:** Solo lectura (no edita archivos).

#### Prompts de ejemplo

**Diseñar un módulo desde cero:**
```
Diseña el modelo de dominio para un módulo Billing/Invoice.

Contexto del negocio:
- Una factura pertenece a un cliente (Identity/User)
- Tiene líneas de detalle con producto, cantidad y precio unitario
- Puede estar en estado: draft, issued, paid, cancelled, overdue
- Al emitirse, se calcula el total automáticamente
- Una factura pagada no se puede cancelar
- Una factura vencida puede reemitirse

Necesito:
1. Diagrama de la entidad Invoice como AggregateRoot
2. Lista de Value Objects con sus reglas de validación
3. Transiciones de estado permitidas
4. Eventos de dominio que deberían dispararse
5. Interfaz del repositorio
```

**Analizar relaciones entre bounded contexts:**
```
Analiza cómo deberían comunicarse los bounded contexts Catalog, Cart y Billing.

Preguntas específicas:
- ¿Cart debería tener su propia copia de Product o una referencia por ID?
- ¿Billing/Order necesita todo el detalle del Product o solo precio y nombre?
- ¿Qué eventos de dominio deberían cruzar los contextos?
- ¿Dónde ponemos la lógica de cálculo de descuentos?

Revisa los módulos existentes en src/ y propón la arquitectura.
```

**Evaluar un diseño propuesto:**
```
Revisa este diseño de entidad y dime si viola principios DDD:

Tengo un Order con: OrderId, UserId (string), items (array de arrays),
total (float calculado), status (string).

¿Qué Value Objects debería extraer? ¿Qué invariantes de dominio me faltan?
¿Cómo debería manejar la colección de OrderItems?
```

---

### 4.2 `module-builder` — Construcción Completa

**Cuándo:** Para construir un módulo end-to-end. Es el agente principal y el más usado.

**Herramientas:** Lectura + Edición + Terminal (scaffold, refinar, testear).

#### Prompts de ejemplo

**Módulo CRUD estándar:**
```
Crear el módulo Catalog/Category siguiendo el patrón DDD del proyecto.

## Entidad Category
- CategoryId: UUID
- CategoryName: string, 2-100 caracteres, único
- CategorySlug: string, generado desde el nombre, kebab-case
- CategoryDescription: string opcional, máximo 500 chars
- CategoryStatus: enum (active, inactive)

## Operaciones
- Create: nombre obligatorio, slug se genera automáticamente
- Update: permite cambiar nombre (regenera slug) y descripción
- Find: buscar por ID
- Search: filtrar por nombre y estado con RequestCriteriaBuilder
- Delete: solo si está inactive

## Reglas de negocio
- El nombre debe ser único (validar en el handler, no en el VO)
- No se puede eliminar una categoría activa
- Al desactivar, verificar que no tiene productos asociados (por ahora solo lanzar evento)

## Tests
- Unit: validación de cada Value Object, test de generación de slug
- Integration: CRUD completo vía endpoints
- Ejecutar quality gate al terminar
```

**Módulo con lógica de negocio rica:**
```
Crear el módulo Cart/CartItem para un sistema de carrito de compras.

## Entidad Cart (AggregateRoot)
- CartId: UUID
- CartOwnerId: referencia a UserId de Identity
- CartItems: colección de CartItem (Value Object compuesto)
- CartStatus: enum (active, checkout, abandoned, completed)

## CartItem (Value Object compuesto, NO entidad)
- ProductId: UUID (referencia a Catalog/Product)
- ProductName: string (snapshot del nombre al añadir)
- UnitPrice: float > 0 (snapshot del precio al añadir)
- Quantity: int, 1-99

## Métodos de dominio en Cart
- addItem(CartItem): añade o incrementa cantidad si el producto ya existe
- removeItem(ProductId): elimina el item
- updateQuantity(ProductId, int): cambia cantidad, elimina si es 0
- calculateTotal(): retorna la suma de (unitPrice * quantity) — usar Property Hook
- checkout(): cambia estado a checkout, solo si tiene items
- abandon(): solo desde active o checkout
- complete(): solo desde checkout

## Reglas
- Máximo 20 items distintos por carrito
- Un usuario solo puede tener UN carrito active a la vez
- No se pueden modificar items si el carrito no está active

## Tests
- Unit: toda la lógica de dominio de Cart (add, remove, update, transitions)
- Unit: validación de CartItem y cantidad
- Unit: cálculo de total con Property Hook
- Integration: endpoints completos
```

**Añadir funcionalidad a un módulo existente:**
```
Añadir la operación "ChangePassword" al módulo Identity/User existente.

## Requisitos
- Nuevo Value Object: UserPassword (mínimo 8 chars, al menos 1 mayúscula, 1 número)
- Nuevo método de dominio: $user->changePassword(UserPassword $new)
- Nuevo Command: ChangeUserPasswordCommand(string $userId, string $currentPassword, string $newPassword)
- El handler debe verificar que el password actual coincide antes de cambiar
- Nuevo endpoint: PUT /api/identity/users/{id}/password
- Proteger con middleware de autenticación

## Tests
- Unit: validación del Value Object UserPassword con todos los edge cases
- Unit: método changePassword en la entidad
- Integration: endpoint con auth
```

---

### 4.3 `code-reviewer` — Auditoría de Código

**Cuándo:** Después de implementar varios módulos, para verificar la salud arquitectónica.

**Herramientas:** Solo lectura (no edita archivos, solo reporta).

#### Prompts de ejemplo

**Auditoría completa de un módulo:**
```
Audita el módulo Catalog/Product completo.

Verifica:
1. Domain: ¿Todas las propiedades son Value Objects? ¿Hay setters en vez de métodos semánticos? ¿Se importa algo de Illuminate?
2. Application: ¿Los handlers son final readonly? ¿Están registrados con los tags correctos?
3. Infrastructure: ¿Los controllers extienden ApiController? ¿Los repositories extienden EloquentRepository?
4. Tests: ¿Cada Value Object tiene test unitario? ¿Los tests cubren los edge cases?
5. PHP 8.4: ¿Se usa declare(strict_types=1) en todos los archivos? ¿Se aprovecha Asymmetric Visibility?

Reporta cada hallazgo con: severidad (CRITICAL/WARNING/INFO), archivo, línea, y fix sugerido.
```

**Verificar pureza del dominio en todo el proyecto:**
```
Escanea TODOS los archivos en src/**/Domain/** y verifica que no existe
ningún import de Illuminate\* o Laravel\*. 

Para cada violación encontrada, indica:
- Archivo y línea exacta
- Qué se importa
- Cómo reemplazarlo con PHP puro
```

**Revisar consistencia entre módulos:**
```
Compara la estructura y patrones de todos los módulos en src/.

Verifica:
- ¿Todos siguen la misma estructura de carpetas?
- ¿Los nombres siguen convenciones consistentes? (VO, Entity, Handler, Controller)
- ¿Los handlers están registrados en sus Service Providers?
- ¿Hay código duplicado entre módulos que debería extraerse al skeleton?
- ¿Los tests siguen el mismo patrón organizativo?

Genera una tabla comparativa módulo por módulo.
```

**Pre-merge audit:**
```
Revisar el código actual en dev antes de hacer merge a main.

Ejecuta una checklist completa:
- [ ] Quality gate pasaría (pint --test, phpstan level max, phpunit)
- [ ] No hay TODOs o FIXMEs sin resolver
- [ ] No hay código comentado que debería eliminarse
- [ ] Las rutas están registradas correctamente
- [ ] Los Service Providers registran todos los handlers
- [ ] Los .env.example tiene todas las variables necesarias
```

---

### 4.4 `frontend-builder` — Vue 3 + Inertia.js

**Cuándo:** Después de que el módulo backend exista, para crear las páginas de interfaz de usuario.

**Herramientas:** Lectura + Edición + Terminal (npm, vite).

#### Prompts de ejemplo

**Setup inicial (una sola vez por proyecto):**
```
Instalar y configurar el stack frontend completo:
- Laravel Breeze con Vue + TypeScript
- Tailwind CSS v4
- Layouts: AppLayout, GuestLayout, BackofficeLayout
- Componentes UI base: Button, Modal, DataTable, Pagination, Badge, Alert
- Componentes de formulario: TextInput, SelectInput, TextareaInput, InputError
- Composables: useFilters, usePagination, useToast
- Verificar que npm run build compila sin errores
```

**Páginas CRUD para un módulo:**
```
Crear las páginas Vue/Inertia para el módulo Catalog/Product.

El backend ya existe en src/Catalog/Product/ con estos endpoints:
- POST /api/catalog/products
- GET /api/catalog/products/{id}
- GET /api/catalog/products (con filtros)
- PUT /api/catalog/products/{id}
- PATCH /api/catalog/products/{id}/publish
- PATCH /api/catalog/products/{id}/archive

Necesito:
1. TypeScript types en resources/js/types/catalog.d.ts
2. Páginas en resources/js/Pages/Catalog/Product/:
   - Index.vue: tabla con búsqueda por nombre, filtro por estado y categoría, paginación
   - Show.vue: detalle con botones de acción (publicar, archivar) según el estado actual
   - Create.vue: formulario con validación de errores de Inertia
   - Edit.vue: formulario pre-rellenado, solo editable si está en draft
3. Componentes:
   - ProductStatusBadge.vue: badge de color según draft/published/archived
   - ProductFilters.vue: sidebar de filtros reutilizable
4. Web Controllers con Inertia::render() que reusen los Commands/Queries existentes
5. Rutas web con nombres para Ziggy

npm run build debe compilar sin errores.
```

**Backoffice multi-usuario:**
```
Crear el layout de backoffice para el módulo Editorial/Review.

Requisitos:
- BackofficeLayout.vue con sidebar de navegación por rol (admin/editor/writer)
- Dashboard.vue: vista general con stats (artículos por estado, últimos publicados)
- Review/Index.vue: cola de artículos pendientes de revisión, filtrable por writer
- Review/Show.vue: vista de artículo con panel lateral de comentarios
  y botones de acción: aprobar, rechazar, solicitar cambios
- Usar Headless UI Tab para separar contenido/SEO/historial

Los Web Controllers deben filtrar por el rol del usuario autenticado.
```

**Componente interactivo complejo:**
```
Crear un componente de editor para Content/Article con:
- TextareaInput enriquecido (markdown preview con toggle)
- Panel lateral de SEO: meta title, meta description con contador de chars,
  slug auto-generado, preview de cómo se verá en Google
- Selector de categorías con búsqueda
- Tag input con autocompletado
- Botón de guardado automático (draft cada 30 segundos)
- Barra de estado: "Guardado", "Guardando...", "Sin guardar"

Usar composable useAutoSave.ts para la lógica de guardado periódico.
```

---

### 4.5 `explore` — Exploración Rápida

**Cuándo:** Para investigar el codebase antes de tomar decisiones, o para responder preguntas puntuales.

**Herramientas:** Solo lectura.

#### Prompts de ejemplo

```
¿Qué módulos existen actualmente en src/? Lista cada uno con sus entidades y Value Objects.
```

```
Busca todos los lugares donde se usa RequestCriteriaBuilder y muéstrame el patrón de uso.
```

```
¿Cómo está registrado el handler CreateUserCommandHandler? Muéstrame el Service Provider.
```

```
¿Qué rutas API están registradas? Muéstrame todas las rutas con su controller y método HTTP.
```

```
¿Qué páginas Vue existen en resources/js/Pages/? Muéstrame la estructura y qué props recibe cada una.
```

---

## 5. Escribir Issues Efectivas para Copilot

### Estructura Recomendada

```markdown
## Descripción
[Qué quieres que haga, en 2-3 frases claras]

## Requisitos Funcionales
- [Requisito 1]
- [Requisito 2]

## Requisitos Técnicos
- Usar `php artisan dba:make:module {Context} {Module}`
- Seguir las directrices de AGENT_GUIDELINES.md
- Ejecutar quality gate (pint, phpstan, phpunit)

## Criterios de Aceptación
- [ ] Tests unitarios para Value Objects
- [ ] Tests de integración para endpoints
- [ ] PHPStan level max sin errores
- [ ] Pint sin warnings
```

### Consejos

| ✅ Hacer | ❌ Evitar |
|----------|-----------|
| Ser específico con nombres de entidades | Instrucciones vagas: "crear algo de usuarios" |
| Listar reglas de negocio explícitamente | Asumir que el agente adivine tu dominio |
| Especificar rama base como `dev` | Dejar la rama por defecto (puede ser `main`) |
| Incluir criterios de aceptación | Issues sin forma de verificar el resultado |
| Una responsabilidad por Issue | Issues gigantes que mezclan módulos |

---

## 6. Orquestación desde Diferentes Plataformas

### Desde GitHub.com (Issues)

1. Crea la Issue → 2. Assignees → Copilot → 3. Branch base: `dev` → 4. Assign

### Desde VS Code

1. Chat de Copilot → 2. Escribe el prompt → 3. Clic en "Delegate to Cloud Agent"

### Desde GitHub CLI

```bash
# Crear Issue y asignar a Copilot
gh issue create \
  --title "Crear módulo Catalog/Product" \
  --body "$(cat issue-body.md)" \
  --assignee "@me"

# Luego asignar a Copilot
gh issue edit ISSUE_NUMBER --add-assignee "copilot-swe-agent[bot]"
```

### Desde la API REST

```bash
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/OWNER/REPO/issues \
  --input - <<< '{
  "title": "Crear módulo Catalog/Product",
  "body": "Scaffold y refinar el módulo Catalog/Product...",
  "assignees": ["copilot-swe-agent[bot]"],
  "agent_assignment": {
    "target_repo": "OWNER/REPO",
    "base_branch": "dev",
    "custom_instructions": "Seguir AGENT_GUIDELINES.md",
    "custom_agent": "module-builder"
  }
}'
```

### Desde el Panel de Agentes (github.com/copilot/agents)

1. Selecciona tu repositorio
2. Escribe el prompt directamente
3. Selecciona branch base: `dev`
4. Selecciona agente: `module-builder`
5. Enviar

---

## 7. Revisión y Supervisión

### Monitorear Sesiones

- **Panel de Agentes**: `github.com/copilot/agents` — ve sesiones activas y logs en tiempo real
- **VS Code**: Pestaña de Copilot muestra sesiones del cloud agent
- **GitHub CLI**: `gh agent-task list` — lista sesiones recientes

### Revisar el PR

Cuando Copilot termina, crea un PR y te pide revisión. Verifica:

1. **CI pasa**: Pint + PHPStan + PHPUnit en verde
2. **Arquitectura**: Domain puro, sin imports de framework
3. **Validación**: Value Objects validan en constructor
4. **Tests**: Cobertura de Value Objects y reglas de negocio
5. **Convenciones**: Semantic methods, final/readonly, strict_types

### Pedir Cambios

Si necesitas ajustes, menciona `@copilot` en un comentario del PR:

```
@copilot El Value Object ProductPrice debería rechazar el valor 0, 
no solo negativos. Ajusta la validación y el test correspondiente.
```

Copilot leerá tu comentario y hará un nuevo commit en la misma rama.

---

## 8. Ejemplo Práctico: Proyecto E-Commerce Completo

A continuación se muestra un proyecto real orquestado **paso a paso** con Issues exactas para copiar y usar.

### Plan General de Issues

| # | Issue | Agente | Fase | Dependencia |
|---|-------|--------|------|-------------|
| 1 | Diseño del dominio completo | ddd-architect | 1 | Ninguna |
| 2 | Frontend: setup inicial | frontend-builder | 1 | Ninguna |
| 3 | Módulo Identity/User | module-builder | 2 | Ninguna |
| 4 | Módulo Catalog/Category | module-builder | 2 | Ninguna |
| 5 | Módulo Catalog/Product | module-builder | 2 | #4 |
| 6 | Frontend: páginas Identity/User | frontend-builder | 3 | #2, #3 |
| 7 | Frontend: páginas Catalog (Category + Product) | frontend-builder | 3 | #2, #4, #5 |
| 8 | Módulo Cart/Cart | module-builder | 3 | #3, #5 |
| 9 | Módulo Billing/Order | module-builder | 3 | #3, #5, #8 |
| 10 | Frontend: páginas Cart/Cart | frontend-builder | 4 | #2, #8 |
| 11 | Frontend: páginas Billing/Order | frontend-builder | 4 | #2, #9 |
| 12 | Middleware de autenticación + roles | module-builder | 4 | #3 |
| 13 | Auditoría final (backend + frontend) | code-reviewer | 5 | Todos |

---

### Issue #1 — Diseño del dominio (ddd-architect)

> **Agente:** `ddd-architect` | **Branch base:** `dev`

```markdown
## Título
Diseñar el modelo de dominio completo para un e-commerce

## Descripción
Necesito el diseño completo del dominio para una tienda online antes de implementar.

## Bounded Contexts
1. **Identity**: Gestión de usuarios y autenticación
2. **Catalog**: Categorías y productos
3. **Cart**: Carrito de compras
4. **Billing**: Órdenes y facturación

## Para cada Bounded Context necesito
- Lista de entidades (AggregateRoot) con sus atributos
- Value Objects con reglas de validación
- Transiciones de estado permitidas
- Eventos de dominio
- Interfaz del repositorio
- Relaciones entre contextos (cómo se referencian entre sí)

## Restricciones de la arquitectura
- Cada contexto es independiente, se comunican por ID (no por referencia directa)
- Los Value Objects de un contexto NO se reutilizan en otro
- Si un contexto necesita datos de otro, usa un snapshot (copia) al momento de la operación
- Seguir los patrones documentados en .github/AGENT_GUIDELINES.md

## Output esperado
Un documento con el diseño completo, incluyendo pseudo-código PHP de las entidades principales.
```

**Qué esperar:** Copilot investiga el codebase, lee las guidelines, y produce un documento de diseño como PR. Revísalo y ajústalo antes de continuar.

---

### Issue #2 — Frontend: setup inicial (frontend-builder)

> **Agente:** `frontend-builder` | **Branch base:** `dev`

```markdown
## Título
Frontend: setup inicial Vue/Inertia/Tailwind

## Descripción
Configurar el stack frontend completo. Este Issue se ejecuta una sola vez.

## Requisitos

### 1. Instalar dependencias
bash
composer require laravel/breeze --dev
php artisan breeze:install vue --typescript --pest
npm install


### 2. Estructura base
resources/js/
├── app.ts
├── types/index.d.ts, global.d.ts
├── Layouts/
│   ├── AppLayout.vue (autenticado: sidebar + header)
│   ├── GuestLayout.vue (público: limpio)
│   └── BackofficeLayout.vue (admin: extiende App)
├── Components/
│   ├── UI/Button.vue, Modal.vue, DataTable.vue, Pagination.vue, Badge.vue, Alert.vue, ConfirmDialog.vue
│   └── Forms/TextInput.vue, SelectInput.vue, TextareaInput.vue, InputError.vue
├── Composables/useFilters.ts, usePagination.ts, useToast.ts
└── Pages/Dashboard.vue

### 3. Convenciones
- <script setup lang="ts"> en todos los componentes
- Tailwind CSS only
- Composition API only
- Props tipados con defineProps<T>()

### 4. HandleInertiaRequests Middleware
- Compartir auth.user y flash messages globalmente

## Checklist
- [ ] npm run build sin errores de TypeScript
- [ ] Layouts renderizan correctamente
- [ ] Componentes UI base creados y tipados
- [ ] vendor/bin/pint para cambios backend
```

---

### Issue #3 — Módulo Identity/User (module-builder)

> **Agente:** `module-builder` | **Branch base:** `dev`

```markdown
## Título
Crear módulo Identity/User como Gold Standard

## Descripción
Implementar el módulo base de usuarios que servirá como referencia para todos los demás módulos.

## Scaffold
php artisan dba:make:module Identity User

## Entidad User (AggregateRoot)
- UserId: UUID v4
- UserName: string, 2-50 caracteres, sin caracteres especiales
- UserEmail: string, email válido (filter_var), único en el sistema
- UserPassword: string, mínimo 8 chars, al menos 1 mayúscula, 1 minúscula, 1 número
- UserStatus: enum (active, suspended, deleted)
- UserCreatedAt: DateTimeImmutable

## Métodos de dominio
- User::create(UserId, UserName, UserEmail, UserPassword): self — factory estático
- $user->changeName(UserName $newName): void
- $user->changeEmail(UserEmail $newEmail): void
- $user->changePassword(UserPassword $newPassword): void
- $user->suspend(): void — solo si está active
- $user->activate(): void — solo si está suspended
- $user->delete(): void — solo si NO está deleted (soft delete semántico)

## Application Layer

### Commands
- CreateUserCommand(id, name, email, password) → CreateUserCommandHandler
- UpdateUserCommand(id, name, email) → UpdateUserCommandHandler
- ChangeUserPasswordCommand(id, newPassword) → ChangeUserPasswordCommandHandler
- SuspendUserCommand(id) → SuspendUserCommandHandler
- DeleteUserCommand(id) → DeleteUserCommandHandler

### Queries
- FindUserQuery(id) → FindUserQueryHandler → retorna User o null
- SearchUsersQuery(criteria) → SearchUsersQueryHandler → usa RequestCriteriaBuilder

## Infrastructure Layer

### Endpoints API
- POST   /api/identity/users          → CreateUserController
- GET    /api/identity/users/{id}     → FindUserController
- GET    /api/identity/users          → SearchUsersController (con filtros)
- PUT    /api/identity/users/{id}     → UpdateUserController
- PATCH  /api/identity/users/{id}/suspend → SuspendUserController
- DELETE /api/identity/users/{id}     → DeleteUserController

### Form Requests
- CreateUserRequest: valida name, email, password requeridos
- UpdateUserRequest: valida name y email opcionales

### Persistencia
- EloquentUserRepository implementando UserRepository (interfaz del dominio)
- UserModel (Eloquent) con tabla `users`
- Migración: id (uuid, pk), name, email (unique), password, status, created_at, updated_at

## Tests requeridos

### Unit (tests/Unit/Identity/User/Domain/)
- UserIdTest: acepta UUID válido, rechaza string vacío y formato inválido
- UserNameTest: acepta "Juan", rechaza "", rechaza string de 1 char, rechaza >50 chars
- UserEmailTest: acepta "user@example.com", rechaza "not-email", rechaza ""
- UserPasswordTest: acepta "Password1", rechaza "short", rechaza "nouppercase1", rechaza "NOLOWERCASE1"
- UserStatusTest: transiciones válidas e inválidas
- UserTest: create(), changeName(), changeEmail(), suspend(), activate(), delete()

### Integration (tests/Integration/Identity/User/)
- CreateUserControllerTest: POST crea usuario y responde 201
- FindUserControllerTest: GET retorna usuario existente, 404 para inexistente
- SearchUsersControllerTest: GET con filtros retorna colección
- UpdateUserControllerTest: PUT actualiza campos
- DeleteUserControllerTest: DELETE cambia estado

## Checklist final
- [ ] Ejecutar vendor/bin/pint
- [ ] Ejecutar vendor/bin/phpstan analyse src --level=max
- [ ] Ejecutar vendor/bin/phpunit
- [ ] Todos los tests en verde
```

---

### Issue #4 — Módulo Catalog/Category (module-builder)

> **Agente:** `module-builder` | **Branch base:** `dev`

```markdown
## Título
Crear módulo Catalog/Category

## Descripción
Módulo de categorías de productos. Estructura simple para familiarizar al agente con el contexto Catalog.

## Scaffold
php artisan dba:make:module Catalog Category

## Entidad Category
- CategoryId: UUID v4
- CategoryName: string, 2-100 chars
- CategorySlug: string, generado automáticamente en kebab-case desde el nombre
- CategoryDescription: string opcional, máximo 500 chars
- CategoryStatus: enum (active, inactive)

## Métodos de dominio
- Category::create(CategoryId, CategoryName, ?CategoryDescription): self
- $category->rename(CategoryName $newName): void — regenera el slug
- $category->describe(CategoryDescription $desc): void
- $category->deactivate(): void
- $category->activate(): void

## Value Object especial: CategorySlug
- Se genera desde CategoryName: "Electrónica y Hogar" → "electronica-y-hogar"
- Eliminar acentos, convertir a lowercase, reemplazar espacios por guiones
- Solo caracteres [a-z0-9-]

## Operations
- CRUD completo (Create, Find, Search, Update, Delete)
- Search con RequestCriteriaBuilder: filtrar por nombre y estado
- Delete: solo si está inactive

## Tests
- Unit: todos los Value Objects, especialmente CategorySlug
- Integration: endpoints CRUD
- Quality gate completo al finalizar
```

---

### Issue #5 — Módulo Catalog/Product (module-builder)

> **Agente:** `module-builder` | **Branch base:** `dev`

```markdown
## Título
Crear módulo Catalog/Product con reglas de negocio ricas

## Descripción
Módulo principal de productos. Depende de Category (referencia por ID, no importar del otro módulo).

## Scaffold
php artisan dba:make:module Catalog Product

## Entidad Product (AggregateRoot)
- ProductId: UUID
- ProductName: string, 3-255 chars
- ProductDescription: string opcional, máximo 2000 chars
- ProductPrice: float, estrictamente > 0
- ProductCategoryId: UUID, referencia a una Category (solo almacena el ID)
- ProductStock: int >= 0
- ProductStatus: enum (draft, published, archived)
- ProductCreatedAt: DateTimeImmutable

## Reglas de negocio (implementar como métodos de dominio)
- Product::create(): siempre inicia como draft
- $product->publish(): solo si tiene nombre, descripción, precio Y stock > 0
- $product->archive(): desde cualquier estado excepto archived
- $product->backToDraft(): solo si está published (para ediciones mayores)
- $product->updateStock(int $quantity): puede ser 0, no negativo
- $product->changePrice(ProductPrice $newPrice): solo si está en draft
- Un producto archived NO puede volver a ningún otro estado (es terminal)

## Transiciones de estado
draft → published (si cumple condiciones)
draft → archived
published → draft
published → archived
archived → (ninguna, estado terminal)

## Application & Infrastructure
- CRUD + Publish + Archive + UpdateStock
- POST   /api/catalog/products
- GET    /api/catalog/products/{id}
- GET    /api/catalog/products (con filtros por nombre, categoría, estado, rango de precio)
- PUT    /api/catalog/products/{id}
- PATCH  /api/catalog/products/{id}/publish
- PATCH  /api/catalog/products/{id}/archive
- PATCH  /api/catalog/products/{id}/stock
- DELETE /api/catalog/products/{id} (solo draft)

## Tests
- Unit: TODOS los Value Objects
- Unit: transiciones de estado (válidas e inválidas)
- Unit: regla de publish (falla si falta descripción, falla si stock es 0)
- Unit: regla de archive terminal (no puede salir de archived)
- Integration: todos los endpoints
- Quality gate al finalizar
```

---

### Issue #6 — Frontend: páginas Identity/User (frontend-builder)

> **Agente:** `frontend-builder` | **Branch base:** `dev` | **Depende de:** #2, #3

```markdown
## Título
Frontend: páginas para Identity/User

## Descripción
Crear las páginas de gestión de usuarios para el backoffice.

## Módulo backend
Identity/User (ya implementado en Issue #3)

## TypeScript Types
// resources/js/types/identity.d.ts
export interface User {
  id: string
  name: string
  email: string
  status: 'active' | 'suspended' | 'deleted'
  created_at: string
}

## Páginas (resources/js/Pages/Identity/User/)
- Index.vue: tabla de usuarios con búsqueda por nombre/email, filtro por estado, paginación
- Show.vue: detalle del usuario con acciones: suspender, activar, eliminar (con confirmación)
- Create.vue: formulario de registro con validación (name, email, password)
- Edit.vue: editar nombre y email

## Web Controllers
- GET  /identity/users           → Index
- GET  /identity/users/create    → Create
- POST /identity/users           → Store
- GET  /identity/users/{id}      → Show
- GET  /identity/users/{id}/edit → Edit
- PUT  /identity/users/{id}      → Update
- DELETE /identity/users/{id}    → Destroy (soft delete)

## Componentes
- UserStatusBadge.vue: badge de color por estado (active=green, suspended=yellow, deleted=red)

## Checklist
- [ ] TypeScript types match backend entity
- [ ] All pages use <script setup lang="ts">
- [ ] Forms use Inertia useForm()
- [ ] Routes use Ziggy route() helper
- [ ] npm run build sin errores
```

---

### Issue #7 — Frontend: páginas Catalog (frontend-builder)

> **Agente:** `frontend-builder` | **Branch base:** `dev` | **Depende de:** #2, #4, #5

```markdown
## Título
Frontend: páginas para Catalog (Category + Product)

## Descripción
Crear las páginas del catálogo: gestión de categorías y productos con filtros avanzados.

## Módulos backend
- Catalog/Category (Issue #4)
- Catalog/Product (Issue #5)

## TypeScript Types
// resources/js/types/catalog.d.ts
export interface Category {
  id: string
  name: string
  slug: string
  description: string | null
  status: 'active' | 'inactive'
}

export interface Product {
  id: string
  name: string
  description: string | null
  price: number
  category_id: string
  category?: Category
  stock: number
  status: 'draft' | 'published' | 'archived'
  created_at: string
}

## Páginas Category (resources/js/Pages/Catalog/Category/)
- Index.vue: tabla con búsqueda, filtro por estado
- Create.vue: formulario (nombre, descripción)
- Edit.vue: editar nombre (regenera slug), descripción, estado

## Páginas Product (resources/js/Pages/Catalog/Product/)
- Index.vue: tabla con búsqueda, filtros por estado/categoría/rango de precio, paginación
- Show.vue: detalle con acciones según estado (publicar, archivar, volver a draft)
- Create.vue: formulario (nombre, descripción, precio, categoría, stock)
- Edit.vue: solo editable si está en draft

## Componentes
- ProductStatusBadge.vue: colores draft=gray, published=green, archived=red
- ProductCard.vue: card para vista grid con imagen placeholder, nombre, precio, estado
- CategorySelect.vue: select con búsqueda de categorías
- PriceRangeFilter.vue: filtro min/max precio

## Web Controllers
CRUD completo para ambos módulos con Inertia::render()

## Checklist
- [ ] TypeScript types para Category y Product
- [ ] Filtros de producto funcionan con RequestCriteriaBuilder
- [ ] Acciones de dominio (publish, archive) mapeadas a botones con confirmación
- [ ] npm run build sin errores
```

---

### Issue #8 — Módulo Cart/Cart (module-builder)

> **Agente:** `module-builder` | **Branch base:** `dev`

```markdown
## Título
Crear módulo Cart/Cart con lógica de carrito de compras

## Descripción
Módulo de carrito con Cart como AggregateRoot que contiene CartItems como Value Objects.

## Scaffold
php artisan dba:make:module Cart Cart

## Entidad Cart (AggregateRoot)
- CartId: UUID
- CartOwnerId: UUID (referencia a UserId, no importar de Identity)
- CartItems: array de CartItem
- CartStatus: enum (active, checkout, abandoned, completed)

## CartItem (Value Object compuesto)
- ProductId: UUID (referencia, no importar de Catalog)
- ProductName: string (snapshot)
- UnitPrice: float > 0 (snapshot)
- Quantity: int, 1-99

## Métodos de dominio en Cart
- Cart::create(CartId, CartOwnerId): self — inicia vacío y active
- $cart->addItem(CartItem): void — si el ProductId ya existe, suma la cantidad
- $cart->removeItem(string $productId): void — elimina el item
- $cart->updateItemQuantity(string $productId, int $quantity): void — si quantity = 0, elimina
- $cart->total(): float — PHP 8.4 Property Hook, suma de (unitPrice * quantity) de cada item
- $cart->itemCount(): int — Property Hook, cuenta de items distintos
- $cart->checkout(): void — solo si active Y tiene items
- $cart->abandon(): void — solo desde active o checkout
- $cart->complete(): void — solo desde checkout

## Invariantes
- Máximo 20 items distintos por carrito
- No se pueden modificar items si el carrito no está active
- Solo un carrito active por usuario (esto se valida en el handler, no en la entidad)

## Endpoints
- POST   /api/cart/carts                        → Crear carrito
- GET    /api/cart/carts/{id}                    → Ver carrito con items y total
- POST   /api/cart/carts/{id}/items              → Añadir item
- DELETE /api/cart/carts/{id}/items/{productId}  → Eliminar item
- PATCH  /api/cart/carts/{id}/items/{productId}  → Actualizar cantidad
- PATCH  /api/cart/carts/{id}/checkout           → Checkout
- PATCH  /api/cart/carts/{id}/abandon            → Abandonar

## Tests
- Unit: CartItem validation
- Unit: toda la lógica de Cart (addItem con merge, removeItem, updateQuantity, total con Hook)
- Unit: transiciones de estado y invariante de máximo 20 items
- Integration: flujo completo (crear → add items → checkout)
- Quality gate completo
```

---

### Issue #9 — Módulo Billing/Order (module-builder)

> **Agente:** `module-builder` | **Branch base:** `dev`

```markdown
## Título
Crear módulo Billing/Order para gestión de pedidos

## Descripción
Módulo de pedidos generados desde un carrito completado. Snapshot de los datos al momento de crear el pedido.

## Scaffold
php artisan dba:make:module Billing Order

## Entidad Order (AggregateRoot)
- OrderId: UUID
- OrderCustomerId: UUID (snapshot desde CartOwnerId)
- OrderItems: array de OrderLine (Value Object compuesto)
- OrderSubtotal: float (calculado, Property Hook)
- OrderTax: float (calculado como 21% del subtotal, Property Hook)
- OrderTotal: float (subtotal + tax, Property Hook)
- OrderStatus: enum (pending, confirmed, shipped, delivered, cancelled, refunded)
- OrderCreatedAt: DateTimeImmutable

## OrderLine (Value Object compuesto)
- ProductId: UUID (snapshot)
- ProductName: string (snapshot)
- UnitPrice: float (snapshot)
- Quantity: int
- LineTotal: float (unitPrice * quantity)

## Métodos de dominio
- Order::createFromCart(OrderId, OrderCustomerId, array $cartItems): self — inicia como pending
- $order->confirm(): void — pending → confirmed
- $order->ship(): void — confirmed → shipped
- $order->deliver(): void — shipped → delivered
- $order->cancel(): void — solo desde pending o confirmed
- $order->refund(): void — solo desde delivered, dentro de 30 días (validado con createdAt)

## Endpoints
- POST   /api/billing/orders              → Crear orden (recibe cartId, copia los items)
- GET    /api/billing/orders/{id}         → Ver orden con detalle
- GET    /api/billing/orders              → Listar órdenes del usuario
- PATCH  /api/billing/orders/{id}/confirm → Confirmar
- PATCH  /api/billing/orders/{id}/ship    → Marcar como enviado
- PATCH  /api/billing/orders/{id}/deliver → Marcar como entregado
- PATCH  /api/billing/orders/{id}/cancel  → Cancelar
- PATCH  /api/billing/orders/{id}/refund  → Reembolsar

## Tests
- Unit: OrderLine validation y cálculo de lineTotal
- Unit: Property Hooks (subtotal, tax, total)
- Unit: todas las transiciones de estado
- Unit: regla de refund (falla si han pasado más de 30 días)
- Integration: flujo completo crear → confirm → ship → deliver
- Integration: flujo de cancelación y reembolso
- Quality gate completo
```

---

### Issue #10 — Frontend: páginas Cart (frontend-builder)

> **Agente:** `frontend-builder` | **Branch base:** `dev` | **Depende de:** #2, #8

```markdown
## Título
Frontend: páginas para Cart/Cart

## Descripción
Crear la interfaz de carrito de compras con interactividad en tiempo real.

## Módulo backend
Cart/Cart (Issue #8)

## TypeScript Types
// resources/js/types/cart.d.ts
export interface CartItem {
  product_id: string
  product_name: string
  unit_price: number
  quantity: number
  line_total: number
}

export interface Cart {
  id: string
  owner_id: string
  items: CartItem[]
  total: number
  item_count: number
  status: 'active' | 'checkout' | 'abandoned' | 'completed'
}

## Páginas (resources/js/Pages/Cart/)
- Show.vue: vista del carrito con:
  - Lista de items con cantidad editable (+/- buttons)
  - Botón eliminar item (con confirmación)
  - Total actualizado dinámicamente
  - Botón "Proceder al checkout" (solo si active y tiene items)
  - Botón "Abandonar carrito"
- Checkout.vue: resumen del pedido antes de confirmar

## Componentes
- CartItemRow.vue: fila de item con controles de cantidad
- CartSummary.vue: resumen flotante (total, cantidad de items)
- QuantitySelector.vue: input numérico con +/- y validación 1-99
- EmptyCart.vue: estado vacío con CTA a productos

## Web Controllers
- GET  /cart               → Show (carrito activo del usuario)
- POST /cart/items         → AddItem (redirect back)
- PATCH /cart/items/{pid}  → UpdateQuantity (redirect back)
- DELETE /cart/items/{pid} → RemoveItem (redirect back)
- POST /cart/checkout      → Checkout → redirect a Billing/Order

## Checklist
- [ ] Cantidad se actualiza sin recargar página completa
- [ ] Total refleja cambios inmediatamente
- [ ] Acciones destructivas piden confirmación
- [ ] npm run build sin errores
```

---

### Issue #11 — Frontend: páginas Billing/Order (frontend-builder)

> **Agente:** `frontend-builder` | **Branch base:** `dev` | **Depende de:** #2, #9

```markdown
## Título
Frontend: páginas para Billing/Order

## Descripción
Crear las páginas de gestión de pedidos.

## Módulo backend
Billing/Order (Issue #9)

## TypeScript Types
// resources/js/types/billing.d.ts
export interface OrderLine {
  product_id: string
  product_name: string
  unit_price: number
  quantity: number
  line_total: number
}

export interface Order {
  id: string
  customer_id: string
  items: OrderLine[]
  subtotal: number
  tax: number
  total: number
  status: 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled' | 'refunded'
  created_at: string
}

## Páginas (resources/js/Pages/Billing/Order/)
- Index.vue: lista de pedidos del usuario con filtro por estado, paginación
- Show.vue: detalle del pedido con:
  - Tabla de líneas con subtotales
  - Resumen: subtotal, impuesto (21%), total
  - Timeline de estados (stepper visual)
  - Acciones según estado: confirmar, enviar, entregar, cancelar, reembolsar
  - Regla de reembolso visible: "Disponible hasta [fecha +30 días de created_at]"

## Componentes
- OrderStatusStepper.vue: timeline visual de estados con estado actual resaltado
- OrderStatusBadge.vue: badge de color por estado
- OrderSummaryCard.vue: card con subtotal, tax, total

## Web Controllers
- GET  /billing/orders          → Index
- GET  /billing/orders/{id}     → Show
- PATCH /billing/orders/{id}/confirm → Confirm (redirect back)
- PATCH /billing/orders/{id}/cancel  → Cancel (redirect back)

## Checklist
- [ ] Timeline de estados es visual y accesible
- [ ] Acciones solo visibles en estados válidos
- [ ] Reembolso muestra countdown de 30 días
- [ ] npm run build sin errores
```

---

### Issue #12 — Middleware de autenticación (module-builder)

> **Agente:** `module-builder` | **Branch base:** `dev`

```markdown
## Título
Añadir autenticación y protección de endpoints

## Descripción
Configurar Laravel Passport y proteger los endpoints que requieren autenticación.

## Requisitos
1. Configurar Laravel Passport para autenticación API (token-based)
2. Crear endpoint: POST /api/identity/auth/login (email + password → token)
3. Crear endpoint: POST /api/identity/auth/register (crear user + devolver token)
4. Crear endpoint: POST /api/identity/auth/logout (revocar token)
5. Proteger con middleware `auth:api` los siguientes endpoints:
   - Todos los de Cart (el usuario solo ve sus propios carritos)
   - Todos los de Billing/Order (el usuario solo ve sus propias órdenes)
   - POST/PUT/DELETE de Catalog/Product (solo usuarios autenticados)
6. Los endpoints GET de Catalog (productos y categorías) son públicos

## Importante
- NO modificar la capa Domain de ningún módulo
- Solo añadir middleware en la capa Infrastructure
- El login/register puede ir en Infrastructure/Http de Identity
- Mantener la estructura DDD existente

## Tests
- Integration: registro → login → obtener token
- Integration: acceso denegado sin token a endpoints protegidos
- Integration: acceso permitido con token válido
- Quality gate completo
```

---

### Issue #13 — Auditoría final backend + frontend (code-reviewer)

> **Agente:** `code-reviewer` | **Branch base:** `dev`

```markdown
## Título
Auditoría completa de arquitectura antes de merge a main

## Descripción
Revisar todo el código (backend y frontend) antes del merge de dev a main.

## Alcance
Auditar TODOS los módulos: Identity, Catalog, Cart, Billing + Frontend completo

## Backend — Verificar por módulo

### Domain Layer
- [ ] Cero imports de Illuminate o Laravel
- [ ] Todas las entidades extienden AggregateRoot
- [ ] Todos los atributos son Value Objects (no strings/ints sueltos)
- [ ] No hay setters — solo métodos semánticos
- [ ] Value Objects validan en constructor y lanzan excepciones de dominio
- [ ] Clases son final donde corresponde

### Application Layer
- [ ] Commands y Queries son final readonly
- [ ] Handlers son final readonly con __invoke()
- [ ] Cada handler está registrado con su tag (command_handler / query_handler)
- [ ] No hay dependencias directas de Infrastructure

### Infrastructure Layer
- [ ] Controllers API extienden ApiController
- [ ] Web Controllers usan Inertia::render() correctamente
- [ ] Repositories extienden EloquentRepository
- [ ] Las rutas (API y web) están registradas correctamente
- [ ] Form Requests validan los inputs

### PHP 8.4
- [ ] declare(strict_types=1) en TODOS los archivos PHP
- [ ] Se usa Asymmetric Visibility donde es posible
- [ ] Se usan Property Hooks donde corresponde
- [ ] Strict comparisons (===) en todo el código

## Frontend — Verificar

### Componentes Vue
- [ ] TODOS los componentes usan <script setup lang="ts">
- [ ] CERO uso de Options API
- [ ] Props tipados con defineProps<T>() — sin `any`
- [ ] Emits tipados con defineEmits<T>()

### Inertia Patterns
- [ ] Formularios usan useForm() — no axios/fetch
- [ ] Rutas usan route() de Ziggy — no hardcoded
- [ ] Páginas usan Layout component — no layout inline
- [ ] Flash messages se muestran correctamente

### TypeScript
- [ ] Interfaces en resources/js/types/ sincronizan con backend VOs
- [ ] Sin tipos `any` en todo el código
- [ ] npm run build compila sin errores ni warnings

### Tailwind
- [ ] Solo Tailwind utilities — sin CSS custom innecesario
- [ ] Responsive: todas las páginas funcionan en mobile
- [ ] Accesible: labels en forms, roles ARIA en modales

### Cross-cutting
- [ ] No hay código duplicado entre módulos (backend ni frontend)
- [ ] Los bounded contexts no se importan entre sí
- [ ] No hay TODOs, FIXMEs, o código comentado
- [ ] Web Controllers reusan Commands/Queries — no duplican lógica

## Output esperado
Tabla de hallazgos con: Severidad (CRITICAL/WARNING/INFO), Capa (Backend/Frontend), Archivo:Línea, Descripción, Fix sugerido
```

---

### Diagrama del Flujo Completo

```
                    ┌─────────────────────┐
                    │  Issue #1            │
                    │  ddd-architect       │
                    │  Diseño dominio      │
                    └──────────┬──────────┘
                               │ PR → Review → Merge a dev
                               ▼
          ┌────────────────────┼──────────────────────┐
          ▼                    ▼                       ▼
 ┌─────────────────┐  ┌──────────────┐  ┌──────────────────┐
 │  Issue #2       │  │  Issue #3    │  │  Issue #4        │
 │  FE Setup       │  │  User (BE)   │  │  Category (BE)   │
 │  frontend-bldr  │  │  mod-builder  │  │  mod-builder     │
 └────────┬────────┘  └──────┬───────┘  └──────┬───────────┘
          │                  │                  │
          │                  │                  ▼
          │                  │         ┌──────────────────┐
          │                  │         │  Issue #5        │
          │                  │         │  Product (BE)    │
          │                  │         │  (depende #4)    │
          │                  │         └──────┬───────────┘
          │                  │                │
          ▼                  ▼                ▼
 ┌─────────────────┐  ┌──────────────────────────────────┐
 │  FE ready       │  │  Backend módulos base listos     │
 └────────┬────────┘  └──────────────┬───────────────────┘
          │                          │
          ├──────────────────────────┤
          ▼                          ▼
 ┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐
 │  Issue #6       │  │  Issue #7        │  │  Issue #8        │
 │  FE User pages  │  │  FE Catalog pages│  │  Cart (BE)       │
 │  (dep #2,#3)    │  │  (dep #2,#4,#5)  │  │  (dep #3,#5)     │
 └────────┬────────┘  └──────┬───────────┘  └──────┬───────────┘
          │                  │                      │
          │                  │                      ▼
          │                  │              ┌──────────────────┐
          │                  │              │  Issue #9        │
          │                  │              │  Order (BE)      │
          │                  │              │  (dep #3,#5,#8)  │
          │                  │              └──────┬───────────┘
          │                  │                     │
          ▼                  ▼                     ▼
 ┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐
 │  Issue #10      │  │  Issue #11       │  │  Issue #12       │
 │  FE Cart pages  │  │  FE Order pages  │  │  Auth middleware  │
 │  (dep #2,#8)    │  │  (dep #2,#9)     │  │  (dep #3)        │
 └────────┬────────┘  └──────┬───────────┘  └──────┬───────────┘
          │                  │                      │
          └──────────────────┼──────────────────────┘
                             ▼
                 ┌──────────────────────┐
                 │  Issue #13           │
                 │  code-reviewer       │
                 │  Auditoría BE + FE   │
                 └──────────┬───────────┘
                            │
                            ▼
                 dev → PR a main → Deploy 🚀
```

**Leyenda:** BE = Backend (module-builder) | FE = Frontend (frontend-builder)

### Cronograma Estimado

Con el Cloud Agent y un supervisor revisando PRs, un proyecto full-stack como este puede completarse en **3-5 días**:

| Día | Backend | Frontend | Issues |
|-----|---------|----------|--------|
| Día 1 | Diseño dominio + User + Category | Setup inicial | #1, #2, #3, #4 |
| Día 2 | Product + Cart | Páginas User + Catalog | #5, #6, #7, #8 |
| Día 3 | Order | Páginas Cart | #9, #10 |
| Día 4 | Auth middleware | Páginas Order | #11, #12 |
| Día 5 | — | Auditoría BE+FE + fixes | #13 + merge |

> **Nota:** El Issue #2 (FE setup) puede ejecutarse en paralelo con #3 y #4 (backend). Las Issues de frontend de cada módulo se desbloquean automáticamente cuando su backend y el setup están listos.

---

## 9. Orquestación Automática: De un Prompt a un Proyecto

Esta es la pieza que cierra la brecha. En lugar de crear Issues manualmente, el flujo completo es:

```
Tu idea (1 prompt) → orchestrator → plan + script → auto-chain → proyecto implementado
```

### 9.1 Los Componentes

| Componente | Archivo | Función |
|-----------|---------|---------|
| **Orchestrator Agent** | `.github/agents/orchestrator.agent.md` | Descompone una idea en Issues ordenadas |
| **Prompt Trigger** | `.github/prompts/orchestrate-project.prompt.md` | Punto de entrada: `/orchestrate-project` |
| **Labels Setup** | `.github/scripts/setup-labels.sh` | Crea etiquetas para fases, agentes y dependencias |
| **Issue Script** | `.github/scripts/create-issues.sh` | Genera el script el orchestrator, crea Issues vía `gh` CLI |
| **Auto-Chain** | `.github/workflows/copilot-auto-chain.yml` | Asigna el siguiente Issue cuando un PR se mergea |
| **Issue Templates** | `.github/ISSUE_TEMPLATE/*.yml` | Formularios estructurados para Issues manuales |

### 9.2 El Flujo Completo

```
 ┌─────────────────────────────────────────────────────────────────┐
 │  TU IDEA                                                        │
 │  "Quiero un blog de nostalgia noventera con SEO, backoffice,   │
 │   multi-redactor y publicación automática con IA"               │
 └──────────────────────┬──────────────────────────────────────────┘
                        │
                        ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │  PASO 1: /orchestrate-project (VS Code)                         │
 │                                                                  │
 │  El orchestrator agent:                                         │
 │  • Lee AGENT_GUIDELINES.md y copilot-instructions.md            │
 │  • Analiza src/ para ver módulos existentes                     │
 │  • Descompone en Bounded Contexts                               │
 │  • Diseña entidades, VOs, reglas de negocio                     │
 │  • Ordena por dependencias                                      │
 │                                                                  │
 │  Genera:                                                        │
 │  • docs/project-plan.md (plan revisable)                        │
 │  • .github/scripts/create-issues.sh (script ejecutable)         │
 └──────────────────────┬──────────────────────────────────────────┘
                        │
                        ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │  PASO 2: Revisión humana                                        │
 │                                                                  │
 │  • Revisa docs/project-plan.md                                  │
 │  • Ajusta entidades, reglas, prioridades                        │
 │  • Modifica el script si es necesario                           │
 │  • Aprueba el plan                                              │
 └──────────────────────┬──────────────────────────────────────────┘
                        │
                        ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │  PASO 3: Ejecutar scripts                                       │
 │                                                                  │
 │  bash .github/scripts/setup-labels.sh    # una vez              │
 │  bash .github/scripts/create-issues.sh   # crea todas las Issues│
 └──────────────────────┬──────────────────────────────────────────┘
                        │
                        ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │  PASO 4: Asignar primera Issue a Copilot                        │
 │                                                                  │
 │  gh issue edit 1 --add-assignee 'copilot-swe-agent[bot]'       │
 │                                                                  │
 │  O desde github.com → Issue #1 → Assignees → Copilot            │
 └──────────────────────┬──────────────────────────────────────────┘
                        │
                        ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │  PASO 5: Auto-Chain (automático)                                │
 │                                                                  │
 │  Copilot trabaja Issue #1 → crea PR → tú revisas → merge a dev │
 │       │                                                          │
 │       ▼                                                          │
 │  copilot-auto-chain.yml detecta el merge:                       │
 │  • Busca Issues con label copilot-queued                        │
 │  • Verifica dependencias (depends-on:#N resueltas)              │
 │  • Asigna la siguiente Issue elegible a Copilot                 │
 │  • Cambia labels: copilot-queued → copilot-working              │
 │       │                                                          │
 │       ▼                                                          │
 │  Copilot trabaja Issue #2 → PR → review → merge                │
 │       │                                                          │
 │       ▼                                                          │
 │  ... se repite hasta completar todas las Issues ...              │
 │       │                                                          │
 │       ▼                                                          │
 │  Última Issue: code-reviewer audita todo                         │
 └──────────────────────┬──────────────────────────────────────────┘
                        │
                        ▼
 ┌──────────────────────────────────────────────────────────────────┐
 │  PASO 6: Merge final                                            │
 │                                                                  │
 │  PR dev → main (el humano supervisa y aprueba)                  │
 │  CD workflow deploya automáticamente                             │
 └─────────────────────────────────────────────────────────────────┘
```

### 9.3 Ejemplo Real: El Blog Noventero

Imagina que lanzas este prompt:

> "Crea un blog de nostalgia noventera que se autogestione, con SEO avanzado,
> backoffice multi-redactor, y publicación diaria automática con IA inspirándose
> en las últimas noticias y los temas más en voga"

El orchestrator generaría un plan como este:

| # | Issue | Agente | Fase | Depende de |
|---|-------|--------|------|------------|
| 1 | Diseño del dominio completo | ddd-architect | 1 | — |
| 2 | Frontend: setup inicial | frontend-builder | 1 | — |
| 3 | Módulo Identity/User (con roles: admin, editor, writer) | module-builder | 2 | — |
| 4 | Módulo Content/Category (TV, Música, Videojuegos, Cine...) | module-builder | 2 | — |
| 5 | Módulo Content/Tag (tags SEO + navegación) | module-builder | 2 | — |
| 6 | Módulo Content/Article (AggregateRoot + workflow editorial) | module-builder | 3 | #3, #4, #5 |
| 7 | Módulo SEO/Metadata (meta tags, OG, structured data, sitemap) | module-builder | 3 | #6 |
| 8 | Módulo Editorial/Review (workflow writer→editor→admin) | module-builder | 3 | #3, #6 |
| 9 | Frontend: backoffice (users, login, dashboard) | frontend-builder | 3 | #2, #3 |
| 10 | Frontend: gestión de artículos (CRUD + SEO panel + categorías/tags) | frontend-builder | 4 | #2, #6, #7 |
| 11 | Frontend: cola de revisión editorial | frontend-builder | 4 | #2, #8 |
| 12 | Módulo AI/ContentGenerator (OpenAI + prompt templates 90s) | module-builder | 4 | #4, #6 |
| 13 | Módulo AI/NewsInspiration (News API + correlación temas 90s) | module-builder | 4 | #12 |
| 14 | Scheduling/AutoPublish (Artisan command + Laravel Scheduler) | module-builder | 4 | #6, #12, #13 |
| 15 | Frontend: dashboard de publicación automática (logs, preview) | frontend-builder | 5 | #2, #14 |
| 16 | Middleware de autenticación + roles | module-builder | 4 | #3 |
| 17 | Frontend: blog público (listado, artículo, SEO, categorías) | frontend-builder | 5 | #2, #6, #7 |
| 18 | Auditoría final de arquitectura (backend + frontend) | code-reviewer | 5 | Todos |

Y el script generado crearía las 18 Issues con cuerpos completos (entidades, VOs, endpoints, pages, components, tests).

### 9.4 El Auto-Chain en Detalle

El workflow `copilot-auto-chain.yml` funciona así:

1. **Trigger:** Se dispara cuando un PR se mergea a `dev`
2. **Busca:** Issues abiertas con label `copilot-queued`
3. **Filtra:** Solo Issues cuyas dependencias (`depends-on:#N`) están todas cerradas
4. **Prioriza:** Elige la Issue de menor fase (`phase:N`)
5. **Asigna:** Añade `copilot-swe-agent[bot]` como assignee
6. **Etiqueta:** Cambia `copilot-queued` → `copilot-working`
7. **Copilot:** Lee la Issue, implementa, crea PR
8. **Humano:** Revisa y mergea el PR → vuelve al paso 1

#### Labels del Sistema

| Label | Color | Significado |
|-------|-------|-------------|
| `copilot-queued` | 🔵 Azul claro | En cola, esperando asignación |
| `copilot-working` | 🔷 Azul | Copilot está trabajando |
| `copilot-done` | 🟢 Verde | PR creado y listo para review |
| `agent:ddd-architect` | 🟣 Morado | Agente de diseño |
| `agent:module-builder` | 🟢 Verde | Agente de construcción backend |
| `agent:frontend-builder` | 🔵 Azul | Agente de construcción frontend |
| `agent:code-reviewer` | 🟡 Amarillo | Agente de auditoría |
| `agent:orchestrator` | 🔴 Rojo | Agente de planificación |
| `phase:1` a `phase:5` | 🟢 Verde degradado | Fase de ejecución |
| `depends-on:#N` | ⚪ Gris | Dependencia de otra Issue |

### 9.5 Issue Templates Disponibles

Para crear Issues manualmente (sin el orchestrator), usa los formularios:

| Template | Archivo | Uso |
|----------|---------|-----|
| 🏗️ Nuevo Módulo DDD | `module-scaffold.yml` | Módulos con scaffold completo |
| 🧠 Diseño de Dominio | `domain-design.yml` | Solicitar diseño al ddd-architect |
| 🔍 Auditoría de Código | `code-audit.yml` | Auditorías con code-reviewer |
| 🔧 Funcionalidad Transversal | `cross-cutting.yml` | Auth, middleware, scheduler, APIs |
| ⚡ Frontend: Setup Inicial | `frontend-setup.yml` | Instalación de Breeze, Tailwind, layouts y componentes UI |
| 🎨 Frontend: Páginas Vue/Inertia | `frontend-pages.yml` | Páginas CRUD Vue 3 + Inertia para un módulo existente |

Cada template incluye los labels necesarios para que el auto-chain funcione.

### 9.6 Setup Completo (Quick Start)

```bash
# 1. Clonar/crear desde template
gh repo create mi-proyecto --template dbravoan/dba-stack --private --clone
cd mi-proyecto

# 2. Crear rama dev
git checkout -b dev
git push -u origin dev

# 3. Configurar labels
bash .github/scripts/setup-labels.sh

# 4. En VS Code, usar el prompt del orchestrator:
#    /orchestrate-project "Descripción de tu proyecto..."

# 5. Revisar el plan generado
cat docs/project-plan.md

# 6. Crear las Issues
bash .github/scripts/create-issues.sh

# 7. Asignar la primera Issue a Copilot
gh issue edit 1 --add-assignee 'copilot-swe-agent[bot]'

# 8. A partir de aquí, el auto-chain se encarga.
#    Solo necesitas:
#    - Revisar PRs cuando Copilot los crea
#    - Mergear si están bien
#    - El siguiente Issue se asigna automáticamente
```

### 9.7 Limitaciones y Notas

| Aspecto | Estado | Nota |
|---------|--------|------|
| Descomposición de proyecto | ✅ Automatizado | El orchestrator lo hace |
| Creación de Issues | ✅ Automatizado | Script `gh` CLI |
| Asignación secuencial | ✅ Automatizado | Auto-chain workflow |
| Resolución de dependencias | ✅ Automatizado | Labels `depends-on:#N` |
| Implementación DDD | ✅ Automatizado | module-builder |
| Quality gate | ✅ Automatizado | Incluido en cada Issue |
| Review de PRs | ⚠️ Semi-manual | Humano revisa, puede pedir cambios con `@copilot` |
| Frontend (Vue/Inertia) | ✅ Automatizado | frontend-builder agent + auto-chain |
| Integración APIs externas | ⚠️ Parcial | El agente crea la estructura, tú configuras keys |
| Deploy | ✅ Automatizado | CD workflow en merge a main |

---

## Referencias

- [GitHub Copilot Cloud Agent — Documentación Oficial](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent)
- [Crear PRs con Copilot](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-a-pr)
- [Personalizar el entorno del agente](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/customize-the-agent-environment)
- [Investigar, planificar e iterar](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/research-plan-iterate)
