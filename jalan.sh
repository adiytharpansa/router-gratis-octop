#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  JALANKAN Router Gratis. Biarkan sesi Termux ini TERBUKA
#  selama Octop dipakai — router berhenti bila sesi ditutup.
#  Cara pakai di Termux:  bash jalan.sh
# ============================================================
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR/freellmapi"

# Bila Node dipasang lewat nvm (jalur Ubuntu) dan belum terbaca, muat dulu.
if ! command -v node >/dev/null 2>&1 && [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  . "$NVM_DIR/nvm.sh"
fi

# Cegah Android mematikan proses saat layar mati (perlu Termux:API).
if command -v termux-wake-lock >/dev/null 2>&1; then
  termux-wake-lock
  echo "Wake-lock aktif (Termux dijaga tetap bangun)."
fi

# Terapkan konfigurasi jalur tanpa kunci pada setiap start (aman diulang).
export FREEAPI_CONFIG_PATH="$DIR/freellmapi/freellmapi.config.json"

echo ""
echo "  Dashboard router : http://localhost:5173"
echo "  API untuk Octop  : http://localhost:3001/v1"
echo "  Berhenti         : Ctrl+C"
echo ""
npm run dev
