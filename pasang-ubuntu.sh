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

# --- 2) Pastikan git ada (untuk mengunduh kode FreeLLMAPI).
if ! command -v git >/dev/null 2>&1; then
  echo "Git belum ada. Memasang git..."
  apt-get update -y && apt-get install -y git
fi

# --- 3) Unduh kode FreeLLMAPI dari GitHub bila belum ada.
#        Dikunci ke commit yang sudah diuji agen (fb07845f).
if [ ! -f "$DIR/freellmapi/package.json" ]; then
  echo "Mengunduh kode FreeLLMAPI dari GitHub (sekali saja)..."
  git clone --depth 1 https://github.com/tashfeenahmed/freellmapi.git "$DIR/freellmapi"
  git -C "$DIR/freellmapi" fetch --depth 1 origin fb07845faf7cf986ea9f3692e055076035dd8739 2>/dev/null \
    && git -C "$DIR/freellmapi" checkout -q FETCH_HEAD \
    || echo "(Memakai versi terbaru; penguncian versi dilewati.)"
fi

# --- 4) Pastikan Node.js cukup baru (perlu >= 22.13 untuk SQLite bawaan Node).
#        Di Ubuntu, Node dipasang lewat nvm (tanpa perlu sudo).
export NVM_DIR="$HOME/.nvm"
load_nvm() { [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; }
load_nvm
if ! command -v node >/dev/null 2>&1 || [ "$(node -p 'process.versions.node.split(".")[0]')" -lt 22 ]; then
  echo "Memasang Node.js 24 lewat nvm (sekali saja)..."
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
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
