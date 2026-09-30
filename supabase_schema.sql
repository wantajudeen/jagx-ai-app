-- JagX AI · run in Supabase → SQL Editor → Run
-- Chats, jobs, per-user credentials (never share one X login across users)

-- Profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users read own profile"
  on public.profiles for select using (auth.uid() = id);

create policy "Users update own profile"
  on public.profiles for update using (auth.uid() = id);

create policy "Users insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

-- Chat history blobs
create table if not exists public.messages (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  chat_id text not null default 'default',
  payload jsonb not null default '[]'::jsonb,
  updated_at timestamptz default now(),
  unique (user_id, chat_id)
);

alter table public.messages enable row level security;

create policy "Users manage own messages"
  on public.messages for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Training events (only with consent)
create table if not exists public.training_events (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete set null,
  role text check (role in ('user','assistant')),
  content text not null,
  consent boolean not null default false,
  created_at timestamptz default now()
);

alter table public.training_events enable row level security;

create policy "Users insert own consented events"
  on public.training_events for insert
  with check (auth.uid() = user_id and consent = true);

create policy "Users read own events"
  on public.training_events for select using (auth.uid() = user_id);

-- Generated images metadata
create table if not exists public.generated_images (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  prompt text,
  image_url text not null,
  created_at timestamptz default now()
);

alter table public.generated_images enable row level security;

create policy "Users manage own images"
  on public.generated_images for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Cloud bot jobs (draft posts, fetch, etc.)
create table if not exists public.bot_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null default 'draft',
  -- kind: draft | post | browse | custom
  status text not null default 'queued',
  -- queued | running | needs_approval | done | error
  input jsonb not null default '{}'::jsonb,
  result jsonb not null default '{}'::jsonb,
  error text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists bot_jobs_user_created on public.bot_jobs (user_id, created_at desc);
create index if not exists bot_jobs_status on public.bot_jobs (status) where status in ('queued','running');

alter table public.bot_jobs enable row level security;

create policy "Users manage own bot jobs"
  on public.bot_jobs for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Per-user connector metadata (tokens stay in client Vault or encrypted here later)
-- Do NOT store plain passwords. Prefer OAuth tokens / API keys.
create table if not exists public.bot_credentials (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null,
  -- x | facebook | github | gmail | custom
  label text not null default '',
  meta jsonb not null default '{}'::jsonb,
  -- e.g. {"handle":"@you"} — never put password here
  created_at timestamptz default now(),
  unique (user_id, provider, label)
);

alter table public.bot_credentials enable row level security;

create policy "Users manage own bot credentials"
  on public.bot_credentials for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Auto profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, new.raw_user_meta_data->>'full_name', new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
