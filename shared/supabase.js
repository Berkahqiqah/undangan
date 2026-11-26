import { SUPABASE_URL, SUPABASE_ANON_KEY } from "./config.js";

export const configured = !SUPABASE_URL.includes("XXXX") && !SUPABASE_ANON_KEY.startsWith("ISI_");

let client = null;
if (configured) {
  try {
    const { createClient } = await import("https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/+esm");
    client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  } catch (e) {
    console.error("Gagal memuat Supabase", e);
  }
}
export const db = client;

const q = new URLSearchParams(location.search);
export const slug = q.get("u");                 // kode undangan
export const guestParam = q.get("to") || "";    // nama tamu

// Tamu hanya bisa mengambil SATU undangan lewat slug (fungsi RPC), tidak bisa melihat daftar semuanya.
export async function loadInvite() {
  if (!db) throw new Error("Supabase belum diatur");
  const { data, error } = await db.rpc("get_invitation", { p_slug: slug });
  if (error) throw error;
  if (!data || !data.length) throw new Error("Undangan tidak ditemukan");
  return data[0];
}

export async function getWishes() {
  if (!db) return [];
  const { data, error } = await db.rpc("get_wishes", { p_slug: slug });
  if (error) throw error;
  return data || [];
}

export const sendWish = (invitation_id, w) =>
  db.from("wishes").insert({ invitation_id, ...w });
