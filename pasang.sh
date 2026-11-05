#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  PASANG Router Gratis (FreeLLMAPI) untuk Octop — versi TERMUX polos.
#  Cara pakai di Termux:  bash pasang.sh
# ============================================================
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"

# --- 1) Bila paket masih di penyimpanan bersama, pindah ke home Termux dulu.
#        npm tidak bisa bekerja dengan benar dari /sdcard.
case "$DIR" in
  /storage/*|/sdcard/*)
    echo "Paket masih di penyimpanan bersama. Memindahkan ke home Termux..."
    rm -rf "$HOME/RouterGratis-Octop"
    cp -r "$DIR" "$HOME/RouterGratis-Octop"
    echo ""
    echo "Sudah dipindah. Sekarang jalankan perintah ini:"
    echo "  cd ~/RouterGratis-Octop && bash pasang.sh"
    exit 0
    ;;
esac

# --- 2) Pastikan Node.js cukup baru dan git ada.
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js belum ada. Memasang dari repositori Termux..."
  pkg update -y && pkg install -y nodejs-lts git
fi
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo "Node terlalu lama ($(node --version)). Memasang nodejs-lts..."
  pkg update -y && pkg install -y nodejs-lts
fi
command -v git >/dev/null 2>&1 || pkg install -y git
echo "Node terpasang: $(node --version)"

# --- 3) Unduh kode FreeLLMAPI bila belum ada — lewat ZIP yang BISA
#        DILANJUTKAN bila putus (curl -C -), dikunci ke commit teruji.
command -v curl >/dev/null 2>&1 || pkg install -y curl
command -v unzip >/dev/null 2>&1 || pkg install -y unzip
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
  echo "Unduhan belum utuh. Jalankan 'bash pasang.sh' SEKALI LAGI —"
  echo "unduhannya MELANJUTKAN dari posisi terakhir, bukan mengulang dari nol."
  exit 1
fi

# --- 4) Salin konfigurasi jalur tanpa kunci ke folder aplikasi.
cp -f "$DIR/freellmapi.config.json" "$DIR/freellmapi/freellmapi.config.json"

# --- 5) Buat .env (kunci enkripsi lokal router) bila belum ada.
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

# --- 6) Pasang dependensi (sekali saja; bisa beberapa menit).
echo "Memasang dependensi (ini yang paling lama)..."
ok=0
for i in 1 2 3 4 5 6; do
  if npm install --no-audit --no-fund --fetch-retries=10 --fetch-retry-mintimeout=5000 --fetch-retry-maxtimeout=120000 --fetch-timeout=900000 --maxsockets=3; then ok=1; break; fi
  echo "Koneksi sempat putus. Mencoba lagi (percobaan $i dari 6)..."
  sleep 5
done
if [ "$ok" != 1 ]; then
  echo "Pemasangan paket belum tuntas setelah 6 percobaan."
  echo "Jalankan skrip ini sekali lagi nanti — cache membuat sisanya makin sedikit."
  exit 1
fi

echo ""
echo "============================================================"
echo " SELESAI. Nyalakan router dengan:"
echo "   cd ~/router-gratis-octop && bash jalan.sh"
echo "============================================================"
