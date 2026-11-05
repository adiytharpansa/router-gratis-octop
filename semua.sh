#!/usr/bin/env bash
# ============================================================
#  SEMUA — menyalakan server Octop + router gratis bersamaan
#  dalam satu sesi tmux bernama "octop".
#  Dipanggil lewat perintah singkat:  octop
#  (alias dipasang oleh buat-perintah.sh)
# ============================================================
SESI="octop"

# Pastikan jendela router ada dan routernya jalan.
pastikan_router() {
  if ! tmux list-windows -t "$SESI" -F '#{window_name}' 2>/dev/null | grep -qx router; then
    tmux new-window -t "$SESI" -n router
    tmux send-keys -t "$SESI:router" "cd ~/router-gratis-octop && bash jalan.sh" Enter
  fi
}

if ! tmux has-session -t "$SESI" 2>/dev/null; then
  echo "Menyalakan Octop + router..."
  tmux new-session -d -s "$SESI" -n server
  # Perintah server Octop asli: dari venv khusus Octop milik user
  # (~/octop-venv). Jalur penuh, jadi tidak menabrak alias 'octop'.
  tmux send-keys -t "$SESI:server" "$HOME/octop-venv/bin/octop" Enter
  pastikan_router
else
  echo "Sesi 'octop' sudah jalan — memastikan router ikut jalan..."
  pastikan_router
fi

# Masuk ke sesinya (dari dalam tmux: pindah sesi, jangan menumpuk).
if [ -n "$TMUX" ]; then
  tmux switch-client -t "$SESI" 2>/dev/null || echo "Kamu sudah di dalam tmux sesi ini."
else
  tmux attach -t "$SESI"
fi
