#!/usr/bin/env bash
# ============================================================
#  PASANG Router Gratis (FreeLLMAPI) untuk Octop — versi UBUNTU.
#  Pakai berkas ini bila kamu menjalankan Ubuntu (di dalam Termux).
#  Cara pakai:  bash pasang-ubuntu.sh
# ============================================================
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"

# --- 1) Bila paket masih di penyimpanan bersama, pindah ke home dulu.
#        npm tidak bisa bekerja dengan benar dari /sdcard.
case "$DIR" in
  /storage/*|/sdcard/*)
    echo "Paket masih di penyimpanan bersama. Memindahkan ke home..."
    rm -rf "$HOME/RouterGratis-Octop"
    cp -r "$DIR" "$HOME/RouterGratis-Octop"
    echo ""
    echo "Sudah dipindah. Sekarang jalankan perintah ini:"
    echo "  cd ~/RouterGratis-Octop && bash pasang-ubuntu.sh"
    exit 0
    ;;
esac

# --- 2) Pastikan alat unduh ada.
command -v curl >/dev/null 2>&1 || apt-get install -y curl
command -v unzip >/dev/null 2>&1 || apt-get install -y unzip
command -v git >/dev/null 2>&1 || apt-get install -y git

# --- 3) Unduh kode FreeLLMAPI bila belum ada — lewat ZIP yang BISA
#        DILANJUTKAN bila putus (curl -C -), dikunci ke commit teruji.
SHA="fb07845faf7cf986ea9f3692e055076035dd8739"
if [ ! -f "$DIR/freellmapi/package.json" ]; then
  echo "Mengunduh kode FreeLLMAPI (bisa dilanjutkan bila putus)..."
  rm -rf "$DIR/freellmapi"
  (cd "$DIR" && curl -L -C - -o freellmapi.zip "https://codeload.github.com/tashfeenahmed/freellmapi/zip/$SHA" \
    && unzip -q -o freellmapi.zip && mv "freellmapi-$SHA" freellmapi) || true
fi
if [ ! -f "$DIR/freellmapi/package.json" ]; then
  echo "Mencoba jalur cadangan (git clone)..."
  rm -rf "$DIR/freellmapi"
  git clone --depth 1 https://github.com/tashfeenahmed/freellmapi.git "$DIR/freellmapi" || true
fi
if [ ! -f "$DIR/freellmapi/package.json" ]; then
  echo ""
  echo "Unduhan belum utuh. Jalankan 'bash pasang-ubuntu.sh' SEKALI LAGI —"
  echo "unduhannya MELANJUTKAN dari posisi terakhir, bukan mengulang dari nol."
  exit 1
fi

# --- 4) Pastikan Node.js cukup baru (perlu >= 22.13 untuk SQLite bawaan Node).
#        Jalur pertama: paket Ubuntu (apt) — paling tahan koneksi lambat.
#        Jalur cadangan: nvm.
export NVM_DIR="$HOME/.nvm"
load_nvm() { [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" || true; }
node_cukup() { command -v node >/dev/null 2>&1 && [ "$(node -p 'process.versions.node.split(".")[0]')" -ge 22 ]; }
load_nvm
if ! node_cukup; then
  echo "Mencoba Node.js dari repositori Ubuntu (apt)..."
  apt-get install -y nodejs npm || { apt-get update -y && apt-get install -y nodejs npm; } || true
fi
if ! node_cukup; then
  echo "Memasang Node.js 24 lewat nvm (sekali saja)..."
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    rm -rf "$NVM_DIR"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    load_nvm
  fi
  nvm install 24
  nvm use 24
fi
echo "Node terpasang: $(node --version)"

# --- 5) Salin konfigurasi jalur tanpa kunci ke folder aplikasi.
cp -f "$DIR/freellmapi.config.json" "$DIR/freellmapi/freellmapi.config.json"

# --- 6) Buat .env (kunci enkripsi lokal router) bila belum ada.
#        Berkas ini TIDAK BOLEH dihapus/diganti sesudah ada kunci provider
#        tersimpan, karena semua kunci terenkripsi memakainya.
cd "$DIR/freellmapi"
if [ ! -f .env ]; then
  ENCRYPTION_KEY="$(node -e 'console.log(require("crypto").randomBytes(32).toString("hex"))')"
  printf "ENCRYPTION_KEY=%s\nPORT=3001\n" "$ENCRYPTION_KEY" > .env
  echo ".env dibuat (kunci enkripsi lokal tersimpan di freellmapi/.env)."
else
  echo ".env sudah ada — dipertahankan, tidak diganti."
fi

# --- 7) Pasang dependensi (sekali saja; bisa beberapa menit).
echo "Memasang dependensi..."
npm install --no-audit --no-fund

echo ""
echo "============================================================"
echo " SELESAI. Nyalakan router dengan:"
echo "   cd ~/router-gratis-octop && bash jalan.sh"
echo "============================================================"
