begin;

select plan(1);

select has_schema(
  'auth',
  'the local Supabase database exposes the auth schema'
);

select * from finish();

rollback;
