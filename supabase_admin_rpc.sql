-- Run this in Supabase SQL Editor (once).
-- NOTE: Supabase usually blocks `alter database ... set` for custom parameters.
-- This script uses a locked table + password hash instead.
-- After running, set/update password with:
--   select public.admin_set_password('CHANGE_ME_STRONG_PASSWORD');

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.admin_secrets (
    id integer primary key check (id = 1),
    password_hash text not null,
    updated_at timestamptz not null default now()
);

alter table public.admin_secrets enable row level security;
revoke all on public.admin_secrets from public, anon, authenticated;

create or replace function public.admin_set_password(p_new_password text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    if p_new_password is null or length(trim(p_new_password)) < 4 then
        raise exception '비밀번호는 최소 4자 이상이어야 합니다.';
    end if;

    insert into public.admin_secrets(id, password_hash, updated_at)
    values (1, extensions.crypt(p_new_password, extensions.gen_salt('bf')), now())
    on conflict (id)
    do update set
        password_hash = excluded.password_hash,
        updated_at = now();
end;
$$;

create or replace function public._assert_admin_password(p_admin_password text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    expected_hash text;
begin
    select password_hash into expected_hash
      from public.admin_secrets
     where id = 1;

    if expected_hash is null or expected_hash = '' then
        raise exception 'Admin password is not configured. Run: select public.admin_set_password(''your_password'');';
    end if;
    if p_admin_password is null or extensions.crypt(p_admin_password, expected_hash) <> expected_hash then
        raise exception '관리자 비밀번호가 올바르지 않습니다.';
    end if;
end;
$$;

revoke all on function public._assert_admin_password(text) from public;

create or replace function public.admin_verify_password(p_admin_password text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
    expected_hash text;
begin
    select password_hash into expected_hash
      from public.admin_secrets
     where id = 1;
    if expected_hash is null or expected_hash = '' then
        return false;
    end if;
    return p_admin_password is not null and extensions.crypt(p_admin_password, expected_hash) = expected_hash;
end;
$$;

grant execute on function public.admin_set_password(text) to anon, authenticated;
grant execute on function public.admin_verify_password(text) to anon, authenticated;

create or replace function public.admin_news_posts_insert(
    p_admin_password text,
    p_title text,
    p_category text,
    p_description text,
    p_content text,
    p_post_date text,
    p_image_url text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    perform public._assert_admin_password(p_admin_password);

    insert into public.news_posts(title, category, description, content, post_date, image_url)
    values (
        p_title,
        p_category,
        p_description,
        p_content,
        p_post_date::date,
        nullif(p_image_url, '')
    );
end;
$$;

grant execute on function public.admin_news_posts_insert(text, text, text, text, text, text, text) to anon, authenticated;

create or replace function public.admin_news_posts_update(
    p_admin_password text,
    p_post_id text,
    p_title text,
    p_category text,
    p_description text,
    p_content text,
    p_post_date text,
    p_image_url text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    perform public._assert_admin_password(p_admin_password);

    update public.news_posts
       set title = p_title,
           category = p_category,
           description = p_description,
           content = p_content,
           post_date = p_post_date::date,
           image_url = nullif(p_image_url, '')
     where id::text = p_post_id;
end;
$$;

grant execute on function public.admin_news_posts_update(text, text, text, text, text, text, text, text) to anon, authenticated;

create or replace function public.admin_news_posts_delete(
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
    delete from public.news_posts where id::text = p_post_id;
end;
$$;

grant execute on function public.admin_news_posts_delete(text, text) to anon, authenticated;

create or replace function public.admin_gallery_posts_insert(
    p_admin_password text,
    p_title text,
    p_description text,
    p_post_date text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_post public.gallery_posts%rowtype;
begin
    perform public._assert_admin_password(p_admin_password);

    insert into public.gallery_posts(title, description, post_date)
    values (p_title, p_description, p_post_date::date)
    returning * into v_post;

    return to_jsonb(v_post);
end;
$$;

grant execute on function public.admin_gallery_posts_insert(text, text, text, text) to anon, authenticated;

create or replace function public.admin_gallery_posts_update(
    p_admin_password text,
    p_post_id text,
    p_title text,
    p_description text,
    p_post_date text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    perform public._assert_admin_password(p_admin_password);

    update public.gallery_posts
       set title = p_title,
           description = p_description,
           post_date = p_post_date::date
     where id::text = p_post_id;
end;
$$;

grant execute on function public.admin_gallery_posts_update(text, text, text, text, text) to anon, authenticated;

create or replace function public.admin_gallery_posts_delete(
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
    delete from public.gallery_posts where id::text = p_post_id;
end;
$$;

grant execute on function public.admin_gallery_posts_delete(text, text) to anon, authenticated;

create or replace function public.admin_gallery_images_insert(
    p_admin_password text,
    p_post_id text,
    p_image_url text,
    p_display_order integer
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_post_id public.gallery_posts.id%type;
begin
    perform public._assert_admin_password(p_admin_password);

    select id into v_post_id
      from public.gallery_posts
     where id::text = p_post_id
     limit 1;

    if v_post_id is null then
        raise exception 'Gallery post not found for id=%', p_post_id;
    end if;

    insert into public.gallery_images(post_id, image_url, display_order)
    values (v_post_id, p_image_url, p_display_order);
end;
$$;

grant execute on function public.admin_gallery_images_insert(text, text, text, integer) to anon, authenticated;
