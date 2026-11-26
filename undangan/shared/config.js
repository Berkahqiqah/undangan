// ====== ISI DUA BARIS INI SETELAH MEMBUAT PROJECT SUPABASE ======
// Supabase Dashboard -> Project Settings -> API
// Key "anon" aman ditaruh di sini karena akses dibatasi RLS (lihat supabase/schema.sql).
// JANGAN PERNAH menaruh key "service_role" di repo.
export const SUPABASE_URL = "https://XXXX.supabase.co";
export const SUPABASE_ANON_KEY = "ISI_ANON_KEY";

// Daftar tema yang bisa dipilih di halaman admin.
// "id" harus sama dengan nama foldernya (lampion/ -> "lampion").
export const THEMES = [
  { id: "lampion", name: "Lorong Lampion" },
  // { id: "karnaval", name: "Karnaval Kita" },  // aktifkan setelah temanya dibuat membaca database
];
