# FTB Backups stalls headless CI launches; packs ship either config shape.
# $1 = game dir (client|server|run).
d="$1"
[ -f "$d/config/ftbbackups2.json" ] \
  && sed -i 's/"enabled" *: *true/"enabled": false/' "$d/config/ftbbackups2.json" || true
[ -f "$d/config/ftbbackups.cfg" ] \
  && sed -i 's/B:enabled *= *true/B:enabled=false/' "$d/config/ftbbackups.cfg" || true
