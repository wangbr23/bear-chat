-- Protected APNs device registrations (T45), building on T41 profiles.
--
-- Tokens remain opaque bytes and rely on the approved Supabase-managed
-- encryption at rest. T57 owns write-only client policies and protected read
-- grants; no client access is granted here.

create type public.apns_environment as enum ('sandbox', 'production');

create type public.notification_preview_mode as enum ('generic', 'detailed');

create table public.push_devices (
  user_id uuid not null references public.profiles (user_id) on delete cascade,
  installation_id uuid not null,
  environment public.apns_environment not null,
  token bytea not null,
  preview_mode public.notification_preview_mode not null default 'generic',
  last_seen_at timestamptz not null default now(),
  primary key (user_id, installation_id, environment),
  constraint push_devices_token_nonempty check (octet_length(token) > 0)
);
