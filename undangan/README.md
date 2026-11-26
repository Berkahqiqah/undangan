# Undangan Main

Undangan pernikahan digital: tema game, halaman admin, RSVP dan ucapan tersimpan di database.

- Tampilan: GitHub Pages (gratis)
- Data, login admin, foto: Supabase (paket gratis cukup untuk mulai)

```
index.html              landing page
lampion/index.html      tema "Lorong Lampion" (membaca data dari database)
admin/index.html        dashboard admin
shared/config.js        isi URL dan anon key Supabase di sini
shared/supabase.js      koneksi dan fungsi umum
supabase/schema.sql     tabel, aturan keamanan (RLS), dan storage
.github/workflows/      deploy otomatis ke GitHub Pages
```

---

## Tutorial install

### 1. Buat project Supabase
1. Daftar di https://supabase.com lalu **New project**. Simpan password database-nya.
2. Tunggu project siap (1 sampai 2 menit).

### 2. Jalankan SQL
1. Buka **SQL Editor → New query**.
2. Tempel seluruh isi `supabase/schema.sql`, lalu **Run**.
3. Pastikan muncul "Success". Ini membuat tabel `invitations` dan `wishes`, aturan keamanan, fungsi untuk tamu, dan bucket foto `invitation-media`.

> Kalau muncul error "policy already exists", berarti SQL sudah pernah dijalankan. Aman diabaikan.

### 3. Buat akun admin dan tutup pendaftaran
1. **Authentication → Users → Add user → Create new user**. Isi email dan kata sandi, centang **Auto Confirm User**.
2. **Authentication → Sign In / Providers → Email** (atau menu *Settings*): matikan **Allow new users to sign up**. Dengan begitu hanya akun yang kamu buat yang bisa login.

### 4. Isi konfigurasi
1. **Project Settings → API** (atau *API Keys*). Salin **Project URL** dan key **anon** (public).
2. Buka `shared/config.js`, ganti:
   ```js
   export const SUPABASE_URL = "https://abcd1234.supabase.co";
   export const SUPABASE_ANON_KEY = "eyJhbGciOi...";
   ```
3. Key `service_role` **jangan** dimasukkan ke repo.

### 5. Coba di komputer (opsional tapi disarankan)
Modul JavaScript tidak jalan lewat `file://`, jadi jalankan server lokal:

```bash
cd undangan
python3 -m http.server 8000
```

Buka:
- http://localhost:8000/admin/ → login, buat undangan
- http://localhost:8000/lampion/ → mode contoh (tanpa `?u=`)

### 6. Upload ke GitHub
```bash
git init
git add .
git commit -m "Undangan Main"
git branch -M main
git remote add origin https://github.com/USERNAME/NAMA-REPO.git
git push -u origin main
```

Lalu di GitHub: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
Tab **Actions** akan menjalankan deploy. Setelah hijau, situs aktif di:

```
https://USERNAME.github.io/NAMA-REPO/
https://USERNAME.github.io/NAMA-REPO/admin/
```

Setiap `git push` ke `main` memperbarui situs otomatis.

### 7. Buat undangan pertama
1. Buka `/admin/`, login.
2. **Buat undangan**: isi slug (misal `aisyah-rizky`), tema, mempelai, acara, rekening, foto. **Simpan**.
3. Tekan **Link tamu**, tempel daftar nama (opsional dengan nomor: `Pak Andi|08123456789`), tekan **Buat link**, lalu **WhatsApp**.

Format link yang dihasilkan:
```
https://USERNAME.github.io/NAMA-REPO/lampion/?u=aisyah-rizky&to=Pak%20Andi
```
- `u` = slug undangan
- `to` = nama tamu di sampul

Ucapan dan RSVP yang masuk dilihat di **Ucapan & RSVP** (ada rekap dan unduh CSV).

---

## Menambah tema baru
1. Salin folder `lampion/` menjadi `folder-baru/`, ubah tampilannya.
2. Pertahankan baris `import ... from "../shared/supabase.js"` dan pola membaca `D` (data undangan), `INV` (undangan), dan `sendWish`.
3. Daftarkan di `shared/config.js` pada `THEMES`, dan di daftar tema pada `index.html`.

Tema **Karnaval** di landing page belum ada filenya di paket ini. Tema itu perlu dibuat dengan pola yang sama sebelum dipakai.

Struktur `data` yang disimpan admin (dipakai semua tema):
```json
{
  "bride": {"name":"", "nick":"", "parents":""},
  "groom": {"name":"", "nick":"", "parents":""},
  "events": [{"title":"", "date":"", "time":"", "place":"", "map":""}],
  "message": "",
  "bank": {"name":"", "number":"", "holder":""},
  "qris": "https://...",
  "gallery": ["https://..."]
}
```

## Keamanan
- Tamu tidak bisa melihat daftar semua undangan atau semua ucapan. Mereka hanya mengambil satu undangan lewat slug (fungsi `get_invitation`).
- Tamu hanya bisa **menambah** ucapan. Hanya admin pemilik undangan yang bisa membaca seluruh RSVP, menghapus ucapan, dan mengubah undangan.
- Semua teks dari tamu ditampilkan sebagai teks biasa (di-escape), jadi tidak bisa menyisipkan script.
- Slug sebaiknya tidak mudah ditebak (misal `aisyah-rizky-7k2`) karena siapa pun yang tahu slug bisa membuka undangannya.
- Untuk mencegah spam ucapan, pasang Cloudflare Turnstile di form, atau batasi lewat Supabase Edge Function.

## Masalah umum
| Gejala | Penyebab / solusi |
|---|---|
| Admin menampilkan "Supabase belum diatur" | `shared/config.js` belum diisi |
| Login gagal | User belum dibuat atau belum *Auto Confirm* |
| "Undangan tidak ditemukan" di tema | Slug di link salah, atau SQL belum dijalankan |
| Upload foto gagal | Bagian Storage di `schema.sql` belum dijalankan |
| Halaman 404 setelah push | Pages belum diatur ke *GitHub Actions*, atau deploy di tab Actions masih berjalan |
| Link `/karnaval/` 404 | Folder tema itu belum dibuat |
| Key baru bernama *publishable* tidak jalan | Pakai key *anon* (legacy), atau naikkan versi `supabase-js` di `shared/supabase.js` |

## Catatan
- Foto yang dihapus dari admin hanya dilepas dari undangan, filenya tetap ada di Storage. Bersihkan manual dari dashboard bila perlu.
- Ingin URL bersih (`/i/aisyah-rizky`) dan domain sendiri? Pindahkan hosting ke Cloudflare Pages atau Netlify dari repo yang sama.
