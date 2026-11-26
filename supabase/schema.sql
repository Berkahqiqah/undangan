-- Jalankan seluruh file ini di Supabase: SQL Editor -> New query -> Run

-- ========== TABEL ==========
create table if not exists invitations (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null default auth.uid() references auth.users on delete cascade,
  slug text unique not null check (slug ~ '^[a-z0-9-]{3,40}$'),
  theme text not null,
  data jsonb not null default '{}',
  created_at timestamptz default now()
);

create table if not exists wishes (
  id bigint generated always as identity primary key,
  invitation_id uuid not null references invitations on delete cascade,
  guest_name text not null check (char_length(guest_name) between 1 and 60),
  message text not null default '' check (char_length(message) <= 500),
  attending text check (attending in ('hadir','tidak','ragu')),
  guests int not null default 1 check (guests between 1 and 10),
  created_at timestamptz default now()
);
create index if not exists wishes_inv_idx on wishes (invitation_id, created_at desc);

-- ========== RLS (JANGAN DILEWATKAN) ==========
alter table invitations enable row level security;
alter table wishes enable row level security;

-- Admin (pemilik) mengelola undangannya sendiri
create policy "owner kelola undangan" on invitations for all to authenticated
  using (owner = auth.uid()) with check (owner = auth.uid());

-- Publik boleh MENGIRIM ucapan/RSVP, tetapi tidak boleh membaca tabelnya langsung
create policy "publik kirim ucapan" on wishes for insert to anon, authenticated with check (true);

-- Pemilik undangan boleh melihat dan menghapus ucapan
create policy "owner baca ucapan" on wishes for select to authenticated using (
  exists (select 1 from invitations i where i.id = invitation_id and i.owner = auth.uid()));
create policy "owner hapus ucapan" on wishes for delete to authenticated using (
  exists (select 1 from invitations i where i.id = invitation_id and i.owner = auth.uid()));

-- ========== FUNGSI UNTUK TAMU ==========
-- Tamu membuka undangan lewat slug; daftar semua undangan tidak bisa diambil.
create or replace function get_invitation(p_slug text)
returns table (id uuid, slug text, theme text, data jsonb)
language sql security definer set search_path = public as $$
  select i.id, i.slug, i.theme, i.data from public.invitations i where i.slug = p_slug
$$;

create or replace function get_wishes(p_slug text)
returns table (guest_name text, message text, attending text, created_at timestamptz)
language sql security definer set search_path = public as $$
  select w.guest_name, w.message, w.attending, w.created_at
  from public.wishes w join public.invitations i on i.id = w.invitation_id
  where i.slug = p_slug and w.message <> ''
  order by w.created_at desc limit 100
$$;

grant execute on function get_invitation(text) to anon, authenticated;
grant execute on function get_wishes(text) to anon, authenticated;

-- ========== STORAGE FOTO ==========
insert into storage.buckets (id, name, public)
values ('invitation-media', 'invitation-media', true)
on conflict (id) do nothing;

-- Bucket publik: URL gambar bisa dibuka siapa saja. Upload/ubah/hapus hanya di folder milik admin sendiri.
create policy "admin upload media" on storage.objects for insert to authenticated
  with check (bucket_id = 'invitation-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "admin ubah media" on storage.objects for update to authenticated
  using (bucket_id = 'invitation-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "admin hapus media" on storage.objects for delete to authenticated
  using (bucket_id = 'invitation-media' and (storage.foldername(name))[1] = auth.uid()::text);
