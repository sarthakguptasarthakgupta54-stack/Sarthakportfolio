-- Run this once in Supabase: SQL Editor > New query > Run
-- 1) Replace YOUR_EMAIL@example.com below with the email of your admin user.

create table if not exists site_content (
  id int primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);
alter table site_content enable row level security;

create policy "public read" on site_content for select using (true);
create policy "admin write" on site_content for all to authenticated
  using ((auth.jwt() ->> 'email') = 'YOUR_EMAIL@example.com')
  with check ((auth.jwt() ->> 'email') = 'YOUR_EMAIL@example.com');

insert into storage.buckets (id, name, public) values ('portfolio', 'portfolio', true)
  on conflict (id) do nothing;

create policy "public read files" on storage.objects for select using (bucket_id = 'portfolio');
create policy "admin upload files" on storage.objects for insert to authenticated
  with check (bucket_id = 'portfolio' and (auth.jwt() ->> 'email') = 'YOUR_EMAIL@example.com');
create policy "admin update files" on storage.objects for update to authenticated
  using (bucket_id = 'portfolio' and (auth.jwt() ->> 'email') = 'YOUR_EMAIL@example.com');
create policy "admin delete files" on storage.objects for delete to authenticated
  using (bucket_id = 'portfolio' and (auth.jwt() ->> 'email') = 'YOUR_EMAIL@example.com');
