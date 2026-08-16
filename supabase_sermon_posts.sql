-- Run this in Supabase SQL Editor (once).
-- Creates sermon_posts table, RLS, and admin RPC functions.

create table if not exists public.sermon_posts (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    content text,
    youtube_url text not null,
    post_date date not null default current_date,
    created_at timestamptz not null default now()
);

alter table public.sermon_posts enable row level security;

drop policy if exists "Allow public read access on sermon_posts" on public.sermon_posts;
create policy "Allow public read access on sermon_posts"
on public.sermon_posts
for select
to anon, authenticated
using (true);

create or replace function public.admin_sermon_posts_insert(
    p_admin_password text,
    p_title text,
    p_content text,
    p_post_date text,
    p_youtube_url text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    perform public._assert_admin_password(p_admin_password);

    insert into public.sermon_posts(title, content, post_date, youtube_url)
    values (
        p_title,
        p_content,
        p_post_date::date,
        nullif(trim(p_youtube_url), '')
    );
end;
$$;

grant execute on function public.admin_sermon_posts_insert(text, text, text, text, text) to anon, authenticated;

create or replace function public.admin_sermon_posts_update(
    p_admin_password text,
    p_post_id text,
    p_title text,
    p_content text,
    p_post_date text,
    p_youtube_url text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    perform public._assert_admin_password(p_admin_password);

    update public.sermon_posts
       set title = p_title,
           content = p_content,
           post_date = p_post_date::date,
           youtube_url = nullif(trim(p_youtube_url), '')
     where id::text = p_post_id;
end;
$$;

grant execute on function public.admin_sermon_posts_update(text, text, text, text, text, text) to anon, authenticated;

create or replace function public.admin_sermon_posts_delete(
    p_admin_password text,
    p_post_id text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    perform public._assert_admin_password(p_admin_password);
    delete from public.sermon_posts where id::text = p_post_id;
end;
$$;

grant execute on function public.admin_sermon_posts_delete(text, text) to anon, authenticated;
