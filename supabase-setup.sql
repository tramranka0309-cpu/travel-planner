-- Travel Planner: chạy trong Supabase Dashboard > SQL Editor > New query.
-- Mô hình: một chuyến đi dùng chung cho một chủ sở hữu; viewer_ids chứa UUID tài khoản chỉ được xem.
create extension if not exists pgcrypto;
create table if not exists public.travel_trips (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references auth.users(id) on delete cascade,
  title text not null default 'Travel Planner',
  data jsonb not null default '{}'::jsonb,
  viewer_ids uuid[] not null default '{}',
  updated_at timestamptz not null default now()
);
alter table public.travel_trips enable row level security;
drop policy if exists "trip owner or approved viewer can read" on public.travel_trips;
create policy "trip owner or approved viewer can read" on public.travel_trips
  for select to authenticated using (auth.uid() = owner_id or auth.uid() = any(viewer_ids));
drop policy if exists "only owner can create own trip" on public.travel_trips;
create policy "only owner can create own trip" on public.travel_trips
  for insert to authenticated with check (auth.uid() = owner_id);
drop policy if exists "only owner can update own trip" on public.travel_trips;
create policy "only owner can update own trip" on public.travel_trips
  for update to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
-- Không tạo policy DELETE: xóa chuyến đi cần thao tác có chủ đích trong Dashboard.
-- Bật Realtime cho bảng travel_trips trong Database > Publications nếu muốn nhận cập nhật tức thời.

-- Cấp quyền xem cho một tài khoản gia đình sau khi tài khoản đó đã đăng nhập ít nhất một lần.
-- Thay hai email bên dưới bằng email chủ sở hữu và email chỉ xem, rồi chạy riêng câu lệnh này:
-- update public.travel_trips t
-- set viewer_ids = array(select distinct unnest(t.viewer_ids || v.id)), updated_at = now()
-- from auth.users owner_user, auth.users v
-- where t.owner_id = owner_user.id
--   and owner_user.email = 'EMAIL_CHU'
--   and v.email = 'EMAIL_CHI_XEM';
