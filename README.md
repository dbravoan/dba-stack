# 🚀 DBA-Stack

**DBA-Stack** es un boilerplate de alto rendimiento para **Laravel 12** y **PHP 8.4**, diseñado bajo los principios de **Arquitectura Hexagonal** y **Domain-Driven Design (DDD)**. 

Este proyecto utiliza como núcleo el paquete [dbravoan/dba-ddd-skeleton](https://github.com/dbravoan/dba-ddd-skeleton) para gestionar buses de mensajes, Value Objects base y criterios de consulta avanzados.

---

## 🛠️ Tech Stack

| Tecnología | Versión | Propósito |
| :--- | :--- | :--- |
| **PHP** | 8.4 | Property Hooks, Asymmetric Visibility, Strict Types. |
| **Laravel** | 12.x | Framework Core & Infrastructure. |
| **Docker/Sail** | Latest | Entorno de desarrollo aislado y reproducible. |
| **MySQL / Redis** | 8.0 / Alpine | Persistencia y Gestión de Colas/Buses. |
| **Inertia.js** | Vue 3 | Frontend moderno con experiencia de SPA. |

---

## 🏗️ Arquitectura (The "Hexa" Way)

La lógica de negocio reside exclusivamente en la carpeta `src/`, dividida en **Bounded Contexts**. Cada módulo sigue esta estructura:

* **Domain**: Entidades (`AggregateRoot`), Value Objects e Interfaces de Repositorio. **Cero dependencias del framework.**
* **Application**: Casos de uso (Commands/Queries) y sus Handlers. Inmutabilidad total.
* **Infrastructure**: Controladores API, persistencia Eloquent y adaptadores externos.

---

## ⚡ El Generador de Módulos

No pierdas tiempo creando carpetas. Usa el comando integrado para scaffoldear un módulo completo siguiendo nuestros estándares:

```bash
php artisan dba:make:module {Contexto} {Modulo}
```
*Este comando genera automáticamente las tres capas, el repositorio, los controladores básicos y los comandos/consultas iniciales.*

---

## 🌲 Estrategia de Ramas & Despliegue

Para mantener la estabilidad absoluta de la producción, seguimos un flujo jerárquico:

1.  **Agentes / Devs**: Todo el trabajo se realiza en ramas `feature/*` que apuntan a la rama **`dev`**.
2.  **Pull Requests**: Se abren y revisan sobre la rama **`dev`**. El CI validará estilo y tests automáticamente.
3.  **Supervisor Humano**: Una vez `dev` es estable, el supervisor realiza el PR hacia **`main`**.
4.  **Deployment**: Solo las fusiones exitosas en **`main`** disparan el despliegue automático al VPS.

> **Regla de Oro:** Prohibido hacer push directo a `main`.

---

## ✅ Control de Calidad (Quality Gate)

Antes de cada commit, asegúrate de que el código pase los tres filtros de excelencia:

* **Estilo**: `vendor/bin/pint` (Limpia y estandariza el código).
* **Análisis Estático**: `vendor/bin/phpstan analyse src --level=max` (Cero errores de tipado).
* **Tests de Arquitectura**: `vendor/bin/phpunit` (Verifica que el Dominio siga siendo puro).

---

## 🚀 Instalación Rápida

1.  Clona el repositorio.
2.  Crea tu `.env` (configura `COMPOSE_PROJECT_NAME` para evitar colisiones).
3.  Levanta el entorno:
    ```bash
    ./vendor/bin/sail up -d
    ```
4.  Instala dependencias y genera claves:
    ```bash
    ./vendor/bin/sail composer install
    ./vendor/bin/sail artisan key:generate
    ```

---

Desarrollado con ❤️ por **dbravoan** bajo estándares de **Excelencia Técnica**.