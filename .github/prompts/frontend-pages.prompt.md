---
agent: "frontend-builder"
description: "Create Vue 3 + Inertia.js pages for an existing backend module"
---

# Create Frontend Pages

Create the Vue 3 + Inertia.js frontend for the **${input}** backend module.

## Requirements

1. **TypeScript interfaces** in `resources/js/types/` matching the backend entity
2. **CRUD Pages** in `resources/js/Pages/{Context}/{Module}/`:
   - `Index.vue` — List with search, filters, pagination
   - `Show.vue` — Detail view with domain actions
   - `Create.vue` — Form with `useForm()` and validation errors
   - `Edit.vue` — Pre-filled form with update logic
3. **Web Controllers** in the module's Infrastructure layer:
   - Use `Inertia::render()` to serve pages
   - Dispatch the SAME Commands/Queries as the API controllers
   - Add web routes with named routes for Ziggy
4. **Module-specific components** if useful (cards, badges, filters)

## Conventions
- `<script setup lang="ts">` everywhere
- Tailwind CSS only — no custom CSS
- Inertia `useForm()` for forms — no axios/fetch
- Ziggy `route()` helper — no hardcoded URLs
- Props typed via `defineProps<Props>()`

## Steps
1. Read the backend module in `src/` to understand the entity, endpoints, and rules
2. Create TypeScript types
3. Create pages
4. Create Web Controllers and routes
5. Verify `npm run build` compiles without errors
