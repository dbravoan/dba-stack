## 🎯 Summary
**Module:** `src/{Context}/{Module}`
**Command used:** `php artisan dba:make:module {Context} {Module}`

## 🛠️ Architectural Checklist (The Excellence Filter)

### 1. Domain Layer
- [ ] **Entities**: Extend `AggregateRoot` and are NOT anemic.
- [ ] **Value Objects**: Used for all attributes with internal validation.
- [ ] **Independence**: No `Illuminate` or framework-specific imports in this layer.
- [ ] **Naming**: Semantic methods used (e.g., `$user->rename()`) instead of generic setters.

### 2. Application Layer
- [ ] **Pattern**: Command/Query Bus pattern strictly followed.
- [ ] **Immutability**: Commands, Queries, and Handlers are `final readonly`.
- [ ] **Registration**: Handler tagged with `dba_ddd.command_handler` or `dba_ddd.query_handler` in the Service Provider.
- [ ] **Responses**: DTOs (Responses) used for all Query outputs.

### 3. Infrastructure Layer
- [ ] **Controllers**: Extend `ApiController` and use the Bus to delegate logic.
- [ ] **Persistence**: Repositories extend `EloquentRepository` and return Domain Entities (not Eloquent Models).
- [ ] **Validation**: Request validation handled before dispatching the Command.

### 4. Frontend Layer (if applicable)
- [ ] **Vue Components**: `<script setup lang="ts">` in every `.vue` file.
- [ ] **TypeScript**: No `any` types. Props typed via `defineProps<T>()`.
- [ ] **Styling**: Tailwind CSS utilities only — no custom CSS.
- [ ] **Forms**: Inertia `useForm()` — no axios/fetch.
- [ ] **Routes**: Ziggy `route()` helper — no hardcoded URLs.
- [ ] **Build**: `npm run build` compiles without errors.

## ⚡ PHP 8.4 & Quality Standards
- [ ] **Strict Typing**: `declare(strict_types=1);` present in all new files.
- [ ] **Static Analysis**: `phpstan` (Larastan) passed at **Level Max**.
- [ ] **Style**: `laravel/pint` rules applied.
- [ ] **Type Hints**: Property hooks or asymmetric visibility used where applicable.

## 🧪 Testing
- [ ] **Unit Tests**: Domain logic and Value Objects covered.
- [ ] **Integration Tests**: Repository and API endpoints validated.

## 📸 Visuals (Optional)
## 📝 Additional Notes