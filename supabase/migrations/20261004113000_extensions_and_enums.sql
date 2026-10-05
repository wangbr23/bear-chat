-- pgcrypto backs the invitation-secret SHA-256 digest (token_digest bytea);
-- report-status and report-category enums stay deferred until the T9/T13
-- approvals introduce the approved value sets (docs/decisions.md).

create extension if not exists pgcrypto with schema extensions;

create type room_member_role as enum ('owner', 'member');

create type room_event_kind as enum ('text', 'emote', 'group_action', 'interaction', 'reaction');

create type account_deletion_job_state as enum ('pending', 'completed');

create domain bounded_display_name as text
  check (char_length(value) <= 30);

create domain bounded_room_name as text
  check (char_length(value) <= 50);

create domain normalized_coordinate as double precision
  check (value >= 0 and value <= 1);

create domain positive_bigint as bigint
  check (value >= 1);
