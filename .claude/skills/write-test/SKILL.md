---
name: write-test
description: Write Jest unit tests for use cases following the project's state-verification pattern. Trigger on "write test", "add test", "create test case", or when a *.test.ts file has a placeholder `expect(null).toBeTruthy()`.
---

# Write Test Skill

## Purpose

Tests in this project verify that a **use case correctly mutates the MobX store**. They do not test UI rendering or raw API behavior. The pattern is always:

1. Seed the store with initial data
2. Call `useCase.execute(...)`
3. Assert the store ended up in the correct state

---

## Phase 1: Read Before Writing

Before writing any test, read these files:

1. **The use case** (`*.case.ts`) — understand what `execute()` does, what parameters it takes, and what repo methods it calls.
2. **The repository** (`*.repository.ts`) — understand which store properties are read and written.
3. **The store entity** (`*.store.ts`) — understand the initial/default values of each property.
4. **Existing tests** in the same feature folder — match the exact import style and structure already in use.

---

## Phase 2: Determine Dependencies

| Use case needs | Import and instantiate |
|---|---|
| Only store mutations | Feature `Repository` only |
| API calls | Feature `Repository` + `ApiMockGateway()` |
| Cross-feature data | Multiple repositories (e.g. `HomeRepository`, `AuthRepository`) |

---

## Phase 3: Test File Structure

Always follow this exact structure:

```ts
import { beforeEach, describe, expect, test } from '@jest/globals';
import { getStore } from '../../../app/store';
// import faker only if generating dynamic test data
import { faker } from '@faker-js/faker';
// import shared fake generators only if they exist in faker-utils
import { generateFake<Entity> } from '../../../common/faker-utils';
import <FeatureRepository> from '../../interfaces/gateways/<feature>.repository';
// import ApiMockGateway only if the use case calls the API
import { ApiMockGateway } from '../../../common/api/api.gateway.mock';
import <UseCaseName> from './<use-case-name>.case';

describe('<Human readable name>', () => {
  let useCase: <UseCaseName>;

  const store = getStore();

  beforeEach(() => {
    const featureRepo = new <FeatureRepository>(store);
    // const apiGateway = ApiMockGateway(); // only if needed
    useCase = new <UseCaseName>(featureRepo /*, apiGateway */);
  });

  test('execute', async () => {
    // 1. Seed store
    // 2. Assert initial state (optional but preferred for list operations)
    // 3. Execute
    // 4. Assert final state
  });
});
```

---

## Phase 4: Assertion Patterns by Use Case Type

### List — add item
```ts
expect(store.feature.list.length).toBe(0);
await useCase.execute(newItem);
expect(store.feature.list.length).toBe(1);
```

### List — remove/delete item
```ts
store.feature.list = generateFake<Entity>(3);
expect(store.feature.list.length).toBe(3);
await useCase.execute(store.feature.list[0].id);
expect(store.feature.list.length).toBe(2);
```

### List — clear all
```ts
store.feature.list = generateFake<Entity>(3);
expect(store.feature.list.length).toBe(3);
await useCase.execute();
expect(store.feature.list.length).toBe(0);
```

### Load from API (paginated)
```ts
expect(store.feature.list.length).toBe(0);
await useCase.execute(1);
expect(store.feature.list.length).toBe(3); // ApiMockGateway returns 3 by default
expect(store.feature.next).toBe('testurl');
```

### Set a single value / token / flag
```ts
const value = faker.string.uuid(); // or any appropriate faker method
await useCase.execute(value);
expect(store.feature.property).toBe(value);
```

### Replace item in list (index-based)
```ts
const original = 'original-value';
const replacement = 'new-value';
store.feature.list = [original];
store.feature.currentItem = original;
await useCase.execute(replacement);
expect(store.feature.list[0]).toBe(replacement);
expect(store.feature.list.length).toBe(1);
```

### Boolean / modal state
```ts
await useCase.execute(true);
expect(store.feature.isVisible).toBeTruthy();
await useCase.execute(false);
expect(store.feature.isVisible).toBeFalsy();
```

### Success + error paths (API-dependent)
```ts
// success
await useCase.execute(validParams);
expect(store.feature.successMessage).toBe('Expected message.');
expect(store.feature.showModal).toBeTruthy();

// error
await useCase.execute(invalidParams);
expect(store.feature.errorMessage).toBe('Expected error.');
expect(store.feature.showModal).toBeFalsy();
```

### Active / selected item
```ts
const fakeItem = generateFake<Entity>(1)[0];
await useCase.execute(fakeItem);
expect(store.feature.activeItem.id).toBe(fakeItem.id);
expect(store.feature.activeItem.someProperty).toBe(fakeItem.someProperty);
```

---

## Phase 5: Rules

- **Never** leave `expect(null).toBeTruthy()` — always replace with a real assertion.
- **Never** import `ApiMockGateway` unless the use case reads from `this.apiGateway`.
- **Never** import `faker` or `generateFake*` unless the test actually needs dynamic data — static string literals are fine for simple cases.
- **Always** assert state **before and after** for list length changes — it makes failures easier to diagnose.
- **Always** use `await useCase.execute(...)` — all use cases are async.
- Use `generateFake<Entity>` helpers from `src/common/faker-utils.ts` when they exist. Use `faker` directly only when no helper exists.
- The `store` is shared across `beforeEach` calls — seed it inside the `test` body, not in `beforeEach`, unless all tests share the same seed.
- Match path depth for imports (`../../../` vs `../../`) based on the test file's location.
- Always type the `useCase` variable with its class name (e.g. `let useCase: SetTokenCase;`).
