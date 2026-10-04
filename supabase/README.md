# Local Supabase

This directory contains the local backend configuration and test harnesses. Application schema
migrations begin with T40; production Edge Function implementations are separate later tasks.

## Prerequisites

- A Docker-compatible container runtime
- Node.js 20 or later
- Deno 2

The commands below use a pinned CLI through `npx`, so a global Supabase installation is optional.

## Local Stack

From the repository root:

```sh
npx --yes supabase@2.119.0 start
npx --yes supabase@2.119.0 db reset
npx --yes supabase@2.119.0 stop
```

`db reset` rebuilds the local database from immutable files in `migrations/`, then runs `seed.sql`.
Do not put hosted project credentials or production data in this directory.

## Tests

Run database tests against the started local stack:

```sh
npx --yes supabase@2.119.0 test db
```

Run formatting, linting, and unit tests for Edge Functions:

```sh
deno task --config supabase/deno.json check
```

Database tests belong in `tests/database/`; Edge Function tests belong in `tests/functions/`.
