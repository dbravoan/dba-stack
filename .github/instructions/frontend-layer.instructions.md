---
description: "Use when creating or editing frontend code: Vue 3 components, Inertia pages, TypeScript types, composables, layouts. Enforces Composition API with <script setup>, TypeScript strict mode, and Tailwind CSS patterns."
applyTo: "resources/js/**,resources/css/**,resources/views/**"
---

# Frontend Layer Instructions — Vue 3 + Inertia.js + TypeScript

## Mandatory Standards

- `<script setup lang="ts">` in EVERY `.vue` file — no exceptions
- **Composition API only** — never Options API
- **TypeScript strict mode** — no `any` types, all props typed via `defineProps<T>()`
- **Tailwind CSS** utilities — no custom CSS files per component

## File Organization

```
resources/js/
├── Pages/{Context}/{Module}/     # Inertia pages (routed)
├── Components/UI/                # Reusable primitives
├── Components/Forms/             # Form input components
├── Components/{Module}/          # Module-specific components
├── Composables/                  # use* composable functions
├── Layouts/                      # App/Guest/Backoffice layouts
└── types/                        # TypeScript interfaces
```

## Page Pattern

```vue
<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'
import type { Product, Paginated } from '@/types/catalog'

interface Props {
  products: Paginated<Product>
  filters: Record<string, string>
}

const props = defineProps<Props>()
</script>

<template>
  <Head title="Products" />
  <AppLayout>
    <!-- Page content -->
  </AppLayout>
</template>
```

## Form Pattern

```vue
<script setup lang="ts">
import { useForm } from '@inertiajs/vue3'

const form = useForm({
  name: '',
  email: '',
})

function submit() {
  form.post(route('identity.users.store'), {
    onSuccess: () => form.reset(),
  })
}
</script>

<template>
  <form @submit.prevent="submit">
    <input v-model="form.name" />
    <div v-if="form.errors.name" class="text-red-500 text-sm">
      {{ form.errors.name }}
    </div>
    <button :disabled="form.processing">Save</button>
  </form>
</template>
```

## Composable Pattern

```typescript
// resources/js/Composables/useFilters.ts
import { router } from '@inertiajs/vue3'
import { reactive, watch } from 'vue'

export function useFilters<T extends Record<string, unknown>>(
  initialFilters: T,
  routeName: string,
) {
  const filters = reactive({ ...initialFilters })

  watch(filters, (value) => {
    router.get(route(routeName), value as Record<string, string>, {
      preserveState: true,
      replace: true,
    })
  }, { deep: true })

  return { filters }
}
```

## TypeScript Types

Types MUST mirror backend Value Objects:

```typescript
// resources/js/types/catalog.d.ts
export interface Product {
  id: string           // ProductId (UUID)
  name: string         // ProductName
  price: number        // ProductPrice
  status: 'draft' | 'published' | 'archived'  // ProductStatus
  created_at: string   // ProductCreatedAt (ISO string)
}
```

## Rules

1. **Pages receive data from Inertia** — never call API endpoints directly from pages
2. **Forms use `useForm()`** from `@inertiajs/vue3` — never raw `fetch()` or `axios`
3. **Route names** use Ziggy: `route('context.module.action')` — never hardcoded URLs
4. **Layouts** wrap pages — every page MUST use a layout component
5. **Components** are self-contained — props in, events out
6. **No business logic in components** — that lives in the backend Domain layer
7. **Error display** uses Inertia's `form.errors` object — already populated by Laravel Form Requests
8. **Pagination** uses Inertia's `Link` component with the paginator's `links` array

## Forbidden

- ❌ Options API (`data()`, `methods`, `computed`)
- ❌ `any` type in TypeScript
- ❌ Axios or fetch calls (use Inertia router/forms)
- ❌ CSS modules or scoped styles (use Tailwind)
- ❌ Vuex or Pinia for server state (Inertia handles this)
- ❌ Hardcoded URLs (use Ziggy route helpers)
- ❌ Business logic in the frontend (validation only for UX, real validation is backend)
