# 📑 Project Orchestration & GitHub Management

Este documento define el flujo de trabajo operativo para garantizar que el **DBA-Stack** se mantenga bajo los estándares de **Excelencia Técnica** mientras se escala el desarrollo con agentes de IA y supervisión humana.

---

## 1. Estrategia de Ramas (Branching Model)

El repositorio se divide en dos estados de confianza:

* **`main` (Producción)**: Código verificado, estable y desplegado. **Solo el Supervisor Humano** tiene permisos de escritura o mezcla aquí.
* **`dev` (Integración)**: El "patio de juegos" controlado. Aquí es donde los agentes integran sus cambios y se realizan las pruebas de arquitectura.
* **`feature/*` (Desarrollo)**: Ramas efímeras creadas por agentes para tareas específicas. Siempre nacen de `dev` y mueren en `dev`.

---

## 2. El Ciclo de Vida de una Tarea (The Loop)

### Paso 1: Orquestación en GitHub Projects
1.  Se crea una **Issue** detallando el requerimiento técnico.
2.  La Issue se asigna a un **Agent** (IA) y se mueve a la columna `In Progress` del **GitHub Project Board**.
3.  El agente crea una rama: `git checkout -b feature/issue-[numero]`.

### Paso 2: Desarrollo y Calidad Local
El agente debe ejecutar el "Triángulo de Excelencia" antes de subir código:
1.  `./vendor/bin/pint` (Estilo).
2.  `./vendor/bin/phpstan analyse --level=max` (Tipado).
3.  `./vendor/bin/phpunit` (Lógica y Arquitectura).
4.  `npm run build` (Frontend — si existe `package.json`).

### Paso 3: Pull Request a `dev`
* El agente abre un PR: **`feature/*` → `dev`**.
* Se dispara automáticamente el **CI Quality Assurance**.
* Si el CI falla, el agente **debe corregir** en su rama hasta que esté en verde.

### Paso 4: Revisión del Supervisor (Human-in-the-loop)
1.  Tú revisas el PR en `dev`.
2.  Si es excelente: **Merge a `dev`**.
3.  Si requiere ajustes: Comentas y el agente vuelve al Paso 2.

### Paso 5: Paso a Producción
Cuando consideres que el conjunto de cambios en `dev` está listo:
1.  Creas un PR: **`dev` → `main`**.
2.  Al fusionar, el workflow **CD Production Deployment** se activa y actualiza el VPS automáticamente.

---

## 3. Configuración de GitHub (Guardrails)

Para que este sistema sea infalible, configura lo siguiente en `Settings > Branches`:

### Regla para `main`:
* **Require a pull request before merging**: Activado.
* **Require status checks to pass before merging**: Activado (debe pasar el CI).
* **Restrict pushes**: Solo tú (el supervisor) puedes pushear o mergear.

### Regla para `dev`:
* **Require status checks to pass before merging**: Activado.
* **Allow force pushes**: Desactivado (para evitar que un agente borre el historial).

---

## 4. Automatización con GitHub Projects

Para una orquestación visual, utiliza un **Automated Project Board** con estas columnas:
1.  **Backlog**: Ideas y tareas futuras.
2.  **Todo**: Tareas listas para ser tomadas por un agente.
3.  **In Progress**: Ramas `feature/*` activas.
4.  **Review (Dev)**: PRs pendientes de tu revisión en la rama `dev`.
5.  **Staging (Main)**: Cambios en `dev` listos para ser movidos a `main`.
6.  **Done**: Tareas desplegadas en producción.

---

## 5. Orquestación Automática con Auto-Chain

DBA-Stack incluye un sistema de orquestación que permite ejecutar un proyecto completo de forma secuencial:

### El Flujo
1. Usa `/orchestrate-project` con una descripción de tu proyecto.
2. El `orchestrator` genera un plan (`docs/project-plan.md`) y un script (`create-issues.sh`).
3. El script crea todas las Issues con labels de dependencia (`phase:N`, `depends-on:#N`).
4. Asigna la primera Issue a Copilot.
5. El workflow `copilot-auto-chain.yml` asigna automáticamente la siguiente Issue cuando cada PR se mergea a `dev`.

### Labels de Orquestación
Las Issues usan estos labels para el flujo automático:
- **`copilot-queued`**: Issue lista para ser asignada a Copilot.
- **`phase:1..5`**: Fase de ejecución (bases → dominio → dependencias → integración → auditoría).
- **`depends-on:#N`**: Dependencia de otra Issue (debe estar cerrada antes).
- **`agent:{name}`**: Agente especializado (`ddd-architect`, `module-builder`, `frontend-builder`, `code-reviewer`).

Ejecuta `bash .github/scripts/setup-labels.sh` una vez por repositorio para crear estos labels.

---

## 6. Frontend (Vue 3 + Inertia.js)

El proyecto incluye soporte para frontend con Vue 3 + Inertia.js:

- **Agente**: `frontend-builder` construye páginas, componentes y layouts.
- **Frontend setup**: Se ejecuta una vez por proyecto (instala Breeze + Vue + TypeScript + Tailwind).
- **Páginas por módulo**: Cada módulo backend puede tener su frontend como una Issue separada.
- **Web Controllers**: Viven junto a los API controllers en Infrastructure, despachan los mismos Commands/Queries.
- **SSR**: Server-Side Rendering gestionado por supervisord en producción.
- **Quality Gate**: `npm run build` se incluye como paso obligatorio del CI/CD.

---

### 💡 Nota para Agentes de IA
> "Tu éxito se mide por la limpieza de tu PR. Si el supervisor tiene que corregir tu arquitectura, has fallado en seguir las `AGENT_GUIDELINES.md`. Usa los comandos de `dba:make:module` y respeta la pureza del Dominio."