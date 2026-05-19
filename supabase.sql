drop table if exists public.reactions cascade;
drop table if exists public.messages cascade;
drop table if exists public.posts cascade;
drop table if exists public.profiles cascade;
create extension if not exists pgcrypto;

create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  username text not null,
  score integer not null check (score >= 0 and score <= 100),
  tier text not null,
  duration text,
  audio_url text,
  audio_path text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  username text not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

create table public.reactions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  type text not null check (type in ('skull','fire','toxic','vote')),
  created_at timestamp with time zone default timezone('utc'::text, now()),
  unique(post_id, user_id, type)
);

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.messages enable row level security;
alter table public.reactions enable row level security;

create policy profiles_public_read on public.profiles for select using (true);
create policy profiles_insert_own on public.profiles for insert to authenticated with check (auth.uid() = user_id);
create policy profiles_update_own on public.profiles for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy posts_public_read on public.posts for select using (true);
create policy posts_insert_auth on public.posts for insert to authenticated with check (auth.uid() = user_id);
create policy messages_public_read on public.messages for select using (true);
create policy messages_insert_auth on public.messages for insert to authenticated with check (auth.uid() = user_id);
create policy reactions_public_read on public.reactions for select using (true);
create policy reactions_insert_auth on public.reactions for insert to authenticated with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public) values ('farts', 'farts', true)
on conflict (id) do update set public = true;
drop policy if exists farts_public_read on storage.objects;
drop policy if exists farts_authenticated_upload on storage.objects;
drop policy if exists farts_public_upload on storage.objects;
create policy farts_public_read on storage.objects for select using (bucket_id = 'farts');
create policy farts_authenticated_upload on storage.objects for insert to authenticated with check (bucket_id = 'farts');

do $$ begin alter publication supabase_realtime add table public.posts; exception when duplicate_object then null; when undefined_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.messages; exception when duplicate_object then null; when undefined_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.reactions; exception when duplicate_object then null; when undefined_object then null; end $$;
