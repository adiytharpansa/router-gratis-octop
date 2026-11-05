# Router Gratis untuk Octop

Satu alamat untuk semua model AI gratis, berjalan di HP-mu sendiri
(FreeLLMAPI, sumber terbuka, berjalan di Termux/Ubuntu). Octop menunjuk ke
router ini; router yang memilih model gratis, mencatat sisa kuota, dan
pindah otomatis bila satu jalur kena batas.

Sudah termasuk 4 jalur **tanpa kunci** yang aktif sejak start pertama:
Kilo, OVH, AI Horde, LLM7 anonim. Kunci Z.ai/Gemini/Groq/NVIDIA bisa kamu
tambahkan sendiri belakangan lewat dashboard-nya.

## Pasang di Ubuntu (di dalam Termux)

```bash
git clone https://github.com/adiytharpansa/router-gratis-octop
cd router-gratis-octop
bash pasang-ubuntu.sh
```

## Pasang di Termux polos

```bash
git clone https://github.com/adiytharpansa/router-gratis-octop
cd router-gratis-octop
bash pasang.sh
```

## Nyalakan

```bash
bash jalan.sh
```

Lalu buka http://localhost:5173, buat akun dashboard, salin **unified API
key** di halaman **Keys**, dan isi ke Octop (Pengaturan → Penyedia Kustom):
Base URL `http://127.0.0.1:3001/v1`, Model `auto`.

Penjelasan lengkap langkah demi langkah: baca **PANDUAN.md**.
