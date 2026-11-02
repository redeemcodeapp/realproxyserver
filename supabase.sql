-- Run in Supabase SQL Editor. Profiles role values: admin / creator.
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 username text unique not null,
 role text not null check (role in ('admin','creator')),
 active boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.metrics (
 creator_id uuid primary key references public.profiles(id) on delete cascade,
 total_clicks bigint not null default 0 check(total_clicks>=0),
 total_downloads bigint not null default 0 check(total_downloads>=0),
 total_amount numeric(12,2) not null default 0 check(total_amount>=0),
 withdrawal numeric(12,2) not null default 0 check(withdrawal>=0),
 updated_at timestamptz not null default now()
);
create or replace view public.creator_overview with (security_invoker=true) as
 select p.id,p.username,p.active,m.total_clicks,m.total_downloads,m.total_amount,m.withdrawal,m.updated_at
 from public.profiles p join public.metrics m on m.creator_id=p.id;
alter table public.profiles enable row level security;
alter table public.metrics enable row level security;
-- SECURITY DEFINER helper prevents recursive RLS lookups against profiles.
create or replace function public.is_active_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin' and active=true); $$;
revoke all on function public.is_active_admin() from public;
grant execute on function public.is_active_admin() to authenticated;
-- Users may read their own profile; active admins may read all profiles.
create policy "profile self read" on public.profiles for select to authenticated using (id=auth.uid());
create policy "admin read profiles" on public.profiles for select to authenticated using (public.is_active_admin());
create policy "creator own metrics read" on public.metrics for select to authenticated using (creator_id=auth.uid());
create policy "admin metrics read" on public.metrics for select to authenticated using (public.is_active_admin());
create policy "admin metrics update" on public.metrics for update to authenticated using (public.is_active_admin()) with check (public.is_active_admin());
-- No creator INSERT/UPDATE/DELETE policies: creators cannot alter metrics or roles.
