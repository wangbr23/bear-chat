-- profiles and asset_catalog_entries (T41), building on the T40 enums/domains.
--
-- Appearance validation is split in two layers on purpose:
--   1. this table enforces only the structural shape of the appearance
--      document (required keys, JSON types, non-empty IDs) so malformed
--      payloads can never be stored;
--   2. allowlist and compatibility validation happens inside the protected
--      profile functions (T60), which accept only active asset_catalog_entries
--      IDs from an accepted catalog version. The schema check therefore pins
--      the versioned shape without duplicating catalog knowledge that T51
--      seeds and the catalog release (T22) still owns.
--
-- asset_catalog_entries.kind stays unconstrained text: the catalog release is
-- not final, and new kinds must arrive as seed rows (T51), not as enum
-- migrations. The compatibility document is bounded by seed control — the
-- table is never client-writable, so no JSON size check is needed here.
--
-- RLS and grants arrive with the authorization migrations (T53+); nothing
-- here grants client access yet.

create table public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name public.bounded_display_name not null,
  appearance jsonb not null,
  revision public.positive_bigint not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  -- coalesce(..., false) matters: a missing or null key makes the whole
  -- chain evaluate to null, and PostgreSQL treats a null check result as
  -- satisfied, which would silently accept shapeless payloads.
  constraint profiles_appearance_shape check (
    coalesce(
      (appearance ->> 'schemaVersion') ~ '^[1-9][0-9]*$'
      and jsonb_typeof(appearance -> 'bodyID') = 'string'
      and (appearance ->> 'bodyID') <> ''
      and jsonb_typeof(appearance -> 'faceID') = 'string'
      and (appearance ->> 'faceID') <> ''
      and jsonb_typeof(appearance -> 'furColorID') = 'string'
      and (appearance ->> 'furColorID') <> ''
      and jsonb_typeof(appearance -> 'accentColorID') = 'string'
      and (appearance ->> 'accentColorID') <> ''
      and jsonb_typeof(appearance -> 'clothingIDs') = 'array'
      and jsonb_typeof(appearance -> 'accessoryIDs') = 'array',
      false
    )
  )
);

create table public.asset_catalog_entries (
  catalog_version text not null,
  kind text not null,
  semantic_id text not null,
  compatibility jsonb not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (catalog_version, kind, semantic_id)
);
