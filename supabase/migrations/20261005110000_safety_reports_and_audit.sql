-- Safety reports and the append-only audit log (T47), building on the T41
-- profiles, T42 rooms, and T43 room-events tables.
--
-- Report category and status values, the disclosed snapshot content, reviewer
-- fields, and the retention length are deferred product approvals (T9/T13,
-- docs/decisions.md), so those columns stay bounded plain text and carry no
-- invented value sets or defaults. The protected create_report function in
-- T80 validates the category-specific context and supplies the initial
-- status; client policies and grants arrive with T58. No client access is
-- granted here.
--
-- Retained report evidence must not prevent room deletion
-- (docs/decisions.md, 2026-10-04). The disclosed snapshot is self-contained,
-- so deleting a room clears the room and event references and preserves the
-- row; the nullable reported user and event references clear like the T43
-- event references. The reporter reference keeps the codebase's non-owner
-- profile default (cascade). Same-room event scoping is validated by T80
-- instead of a composite foreign key, because room_id itself must become
-- null when the room is deleted.
--
-- audit_log records administrative, safety-review, and deletion actions
-- (NFR-5.5) as content-free rows. Actors are bounded text rather than profile
-- foreign keys because service roles, and later safety reviewers, are not app
-- users.

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (user_id) on delete cascade,
  room_id uuid references public.rooms (id) on delete set null,
  reported_user_id uuid references public.profiles (user_id) on delete set null,
  reported_event_id uuid references public.room_events (id) on delete set null,
  disclosed_snapshot jsonb not null,
  category text not null,
  status text not null,
  retention_deadline timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reports_disclosed_snapshot_object check (
    coalesce(jsonb_typeof(disclosed_snapshot) = 'object', false)
  ),
  constraint reports_category_bounded check (
    char_length(category) between 1 and 50
  ),
  constraint reports_status_bounded check (
    char_length(status) between 1 and 50
  ),
  constraint reports_retention_after_creation check (retention_deadline > created_at)
);

create index reports_room_id_idx on public.reports (room_id);
create index reports_reporter_id_idx on public.reports (reporter_id);
create index reports_reported_user_id_idx on public.reports (reported_user_id);
create index reports_reported_event_id_idx on public.reports (reported_event_id);

create table public.audit_log (
  id uuid primary key default gen_random_uuid(),
  actor text not null,
  operation text not null,
  resource_type text not null,
  resource_id uuid not null,
  reason_code text not null,
  metadata jsonb not null,
  created_at timestamptz not null default now(),
  constraint audit_log_actor_bounded check (char_length(actor) between 1 and 100),
  constraint audit_log_operation_bounded check (char_length(operation) between 1 and 100),
  constraint audit_log_resource_type_bounded check (
    char_length(resource_type) between 1 and 100
  ),
  constraint audit_log_reason_code_bounded check (
    char_length(reason_code) between 1 and 100
  ),
  constraint audit_log_metadata_object check (
    coalesce(jsonb_typeof(metadata) = 'object', false)
  )
);

create index audit_log_resource_idx on public.audit_log (resource_type, resource_id);

-- audit_log is append-only for every role, including service roles:
-- protected operations insert rows and never revise or remove them. A
-- retention policy for audit rows would replace this trigger deliberately.
create function public.enforce_audit_log_append_only()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'audit_log rows are append-only';
end;
$$;

create trigger audit_log_append_only
  before update or delete or truncate
  on public.audit_log
  for each statement
  execute function public.enforce_audit_log_append_only();
