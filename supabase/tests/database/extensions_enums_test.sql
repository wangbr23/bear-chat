begin;

select plan(21);

select is(
  (select count(*) from pg_extension where extname = 'pgcrypto'),
  1::bigint,
  'pgcrypto extension is installed'
);

select has_type('public', 'room_member_role', 'the room member role enum exists');

select has_type('public', 'room_event_kind', 'the room event kind enum exists');

select has_type('public', 'account_deletion_job_state', 'the account deletion job state enum exists');

select enum_has_labels(
  'public',
  'room_member_role',
  array['owner', 'member']
);

select enum_has_labels(
  'public',
  'room_event_kind',
  array['text', 'emote', 'group_action', 'interaction', 'reaction']
);

select enum_has_labels(
  'public',
  'account_deletion_job_state',
  array['pending', 'completed']
);

select has_domain('public', 'bounded_display_name', 'the bounded display name domain exists');

select has_domain('public', 'bounded_room_name', 'the bounded room name domain exists');

select has_domain('public', 'normalized_coordinate', 'the normalized coordinate domain exists');

select has_domain('public', 'positive_bigint', 'the positive bigint domain exists');

select throws_ok(
  $$select repeat('a', 31)::public.bounded_display_name$$,
  '23514',
  NULL,
  'a 31-character display name violates the display name domain'
);

select lives_ok(
  $$select repeat('a', 30)::public.bounded_display_name$$,
  'a 30-character display name satisfies the display name domain'
);

select throws_ok(
  $$select repeat('a', 51)::public.bounded_room_name$$,
  '23514',
  NULL,
  'a 51-character room name violates the room name domain'
);

select lives_ok(
  $$select repeat('a', 50)::public.bounded_room_name$$,
  'a 50-character room name satisfies the room name domain'
);

select throws_ok(
  $$select (-0.1)::public.normalized_coordinate$$,
  '23514',
  NULL,
  'a negative coordinate violates the normalized coordinate domain'
);

select throws_ok(
  $$select 1.1::public.normalized_coordinate$$,
  '23514',
  NULL,
  'a coordinate above one violates the normalized coordinate domain'
);

select lives_ok(
  $$select 0::public.normalized_coordinate$$,
  'zero satisfies the normalized coordinate domain'
);

select lives_ok(
  $$select 1::public.normalized_coordinate$$,
  'one satisfies the normalized coordinate domain'
);

select throws_ok(
  $$select 0::public.positive_bigint$$,
  '23514',
  NULL,
  'zero violates the positive bigint domain'
);

select lives_ok(
  $$select 1::public.positive_bigint$$,
  'one satisfies the positive bigint domain'
);

select * from finish();

rollback;
