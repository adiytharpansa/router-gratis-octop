#!/usr/bin/env bash
# ============================================================
#  BUAT PERINTAH — memasang perintah singkat 'octop' yang
#  menyalakan server Octop + router bersamaan (lihat semua.sh).
#  Jalankan SEKALI saja:  bash buat-perintah.sh
# ============================================================
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
BARIS="alias octop='bash $DIR/semua.sh'"

touch "$HOME/.bashrc"
if grep -qxF "$BARIS" "$HOME/.bashrc"; then
  echo "Perintah 'octop' sudah terpasang sebelumnya."
else
  echo "$BARIS" >> "$HOME/.bashrc"
  echo "Perintah 'octop' terpasang."
fi
echo ""
echo "Mulai sekarang: buka Ubuntu, ketik  octop  lalu Enter —"
echo "server Octop dan router menyala berdua."
echo "(Untuk sesi terminal yang sedang terbuka ini, perintahnya"
echo " berlaku mulai jendela/sesi terminal berikutnya.)"
