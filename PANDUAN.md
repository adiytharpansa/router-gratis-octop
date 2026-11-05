# Router Gratis untuk Octop — Panduan

Satu alamat untuk semua model gratis. Router ini (FreeLLMAPI, sumber terbuka)
berjalan di HP-mu sendiri dan menyatukan jalur-jalur AI gratis di belakang
satu endpoint. Octop cukup menunjuk ke router ini; router yang memilih model,
mencatat sisa kuota tiap jalur, dan pindah otomatis bila satu jalur kena
batas.

**Modelnya TIDAK berjalan di HP-mu** — yang lokal hanya routernya (ringan).
Model tetap berpikir di server penyedia lewat internet.

## Yang sudah terbukti (diuji agen sebelum paket ini dikirim)

- Router dinyalakan dari nol: dashboard hidup, API hidup.
- Tanpa kunci API apa pun, daftar model berisi 284 model.
- Satu pesan uji lewat router dijawab oleh **Qwen3.5-397B** (model 397 miliar
  parameter) lewat jalur tanpa kunci — rantai lengkapnya bekerja.

Paket ini sudah berisi 4 jalur tanpa kunci yang aktif sejak start pertama:
**Kilo, OVH, AI Horde, LLM7 (mode anonim)**. Kunci Z.ai dan kawan-kawan
tinggal kamu tambahkan sendiri belakangan (langkah 5) — jalur di atas sudah
cukup untuk Octop langsung pintar.

## 1. Ambil repo ini

Di Ubuntu (atau Termux) kamu:

```bash
git clone https://github.com/adiytharpansa/router-gratis-octop
cd router-gratis-octop
```

## 2. Pasang (sekali saja)

**Bila Ubuntu-mu yang dipakai** (Octop-mu berjalan di Ubuntu dalam Termux):

```bash
bash pasang-ubuntu.sh
```

Di Termux polos, berkasnya yang ini:

```bash
bash pasang.sh
```

Bedanya cuma cara memasang Node.js: di Ubuntu lewat nvm, di Termux polos
lewat `pkg`. Router dan Octop tetap saling menemukan karena alamat
localhost-nya sama.

Yang dikerjakan skrip: mengunduh kode FreeLLMAPI dari GitHub (dikunci ke
commit yang sudah diuji agen), memasang Node.js bila belum ada (atau
terlalu lama), membuat kunci enkripsi lokal, lalu `npm install`
(beberapa menit, sekali saja). Butuh ruang kosong sekitar 1 GB.

## 3. Nyalakan router

```bash
cd ~/router-gratis-octop && bash jalan.sh
```

Biarkan sesi ini terbuka selama Octop dipakai. Berhenti: `Ctrl+C`.

## 4. Ambil kunci gabungan (unified API key)

1. Buka **http://localhost:5173** di browser HP.
2. Buat akun dashboard: email + kata sandi **pilihanmu sendiri**
   (ini akun lokal di HP-mu, bukan akun internet).
3. Masuk ke halaman **Keys** — di bagian atas ada **unified API key**
   (diawali `freellmapi-…`). Salin kunci itu.

## 5. Sambungkan ke Octop

Di Octop: **Pengaturan → Penyedia Kustom (Custom Provider)**, isi:

| Kolom | Isi |
|---|---|
| Nama | Router Gratis |
| Base URL | `http://127.0.0.1:3001/v1` |
| API Key | kunci gabungan dari langkah 4 |
| Model | `auto` |

Selesai — Octop sekarang memakai kolam model gratis lewat router.

## 6. Tambah Z.ai (gratis permanen $0) — dan kawan-kawan

Z.ai tidak butuh kunci buatan agen; kuncinya **kamu buat dan kamu masukkan
sendiri** di HP-mu. Jangan pernah mengirim kunci API ke siapa pun, termasuk
lewat chat.

1. Buka **z.ai** → daftar (email/Google) → menu **API Keys** → buat kunci.
2. Dashboard router (http://localhost:5173) → **Keys** → **Add** →
   platform **Zhipu (Z.ai)** → tempel kuncimu → simpan.
3. Model Z.ai yang berharga $0 permanen: **GLM-4.7-Flash**,
   **GLM-4.5-Flash**, **GLM-4.6V-Flash** (bisa membaca gambar).

Opsional, pola yang sama persis lewat halaman Keys:

- **Google Gemini** — kunci gratis di aistudio.google.com/apikey
- **Groq** — kunci gratis di console.groq.com (sangat cepat)
- **NVIDIA** — kunci gratis di build.nvidia.com

## Catatan jujur

- **Privasi jalur tanpa kunci:** Kilo mencatat prompt untuk pelatihan.
  Untuk hal sensitif, pakai jalur berkunci milikmu sendiri (Z.ai / Gemini).
- **AI Horde itu antre** (bisa menit) — di router ini ia ban serep terakhir,
  bukan andalan harian.
- Router harus menyala selama Octop dipakai. Agar Android tidak membunuh
  Termux: pasang Termux:API dari toko yang sama dengan Termux-mu, dan
  matikan **optimasi baterai** untuk Termux di pengaturan Android.
- Berkas `freellmapi/.env` menyimpan kunci enkripsi lokal. Sesudah kamu
  menyimpan kunci provider apa pun, **jangan hapus/ganti .env** — semua
  kunci tersimpan terenkripsi dengan kunci itu.

## Masalah umum

- **Port 3001/5173 sudah dipakai** → ada sesi router lama yang masih jalan;
  tutup sesi Termux itu dulu.
- **npm meminta persetujuan skrip (esbuild)** → ikuti perintah yang
  ditampilkan npm untuk menyetujuinya, lalu jalankan `bash pasang.sh` lagi.
- **`node:sqlite` tidak tersedia** → Node terlalu lama:
  `pkg update && pkg install -y nodejs-lts`, lalu ulangi dari langkah 2.
- **Octop tidak bisa menyambung** → pastikan sesi `jalan.sh` masih terbuka
  dan alamatnya persis `http://127.0.0.1:3001/v1`.
