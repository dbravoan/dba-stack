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

### 💡 Nota para Agentes de IA
> "Tu éxito se mide por la limpieza de tu PR. Si el supervisor tiene que corregir tu arquitectura, has fallado en seguir las `AGENT_GUIDELINES.md`. Usa los comandos de `dba:make:module` y respeta la pureza del Dominio."