#!/usr/bin/env bash
# Mengubah efek suara mentah menjadi aset bundel.
#
# Pemakaian: tool/audio/proses_sfx.sh [folder-mentah]
#
# Folder mentah bawaannya `~/moci-audio-src/sfx`, di luar repo. Setiap berkas
# di sana dinamai sesuai nama efek di `lib/core/audio/sfx.dart` (`klik.mp3`,
# `benar.wav`). Skrip menulis `assets/audio/sfx/<nama>.wav` dan memperbarui
# baris `sfx/` di `assets/audio/LICENSES.csv` dari `meta.tsv` di folder mentah.
#
# meta.tsv: id, URL, pengunggah, lisensi, tanggal unduh, mutu, durasi maks.
# Kolom terakhir memotong efek; bawaannya 3 detik seperti suara hewan.
#
# Aman dijalankan berulang: hasil ditimpa, baris lisensi disusun ulang dari
# berkas yang benar-benar ada.
set -euo pipefail

src=${1:-$HOME/moci-audio-src/sfx}
root=$(cd "$(dirname "$0")/../.." && pwd)
out=$root/assets/audio/sfx
meta=$src/meta.tsv
licenses=$root/assets/audio/LICENSES.csv

command -v ffmpeg >/dev/null || {
  echo "ffmpeg tidak ada. Pasang dulu: brew install ffmpeg" >&2
  exit 1
}
command -v ffprobe >/dev/null || {
  echo "ffprobe tidak ada. Pasang dulu: brew install ffmpeg" >&2
  exit 1
}
[ -d "$src" ] || {
  echo "Folder mentah $src tidak ada" >&2
  exit 1
}

mkdir -p "$out"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Durasi maksimum per efek dari meta.tsv; kosong berarti 3 detik.
batas_durasi() {
  local id=$1 nilai
  nilai=""
  if [ -f "$meta" ]; then
    nilai=$(awk -F'\t' -v cari="$id" '$1 == cari { print $7; exit }' "$meta")
  fi
  case "$nilai" in
    '' | *[!0-9.]*) printf '3' ;;
    *) printf '%s' "$nilai" ;;
  esac
}

# Buang hening di awal, potong sesuai batas, redam 100 ms terakhir.
rapikan() {
  local masuk=$1 keluar=$2 batas=$3
  local dur fade
  ffmpeg -hide_banner -loglevel error -y -i "$masuk" -vn \
    -af "silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.08,atrim=0:${batas},asetpts=N/SR/TB,aresample=44100" \
    -ac 1 -c:a pcm_s16le "$keluar"
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$keluar")
  fade=$(awk -v d="$dur" 'BEGIN { f = d - 0.1; if (f < 0) f = 0; printf "%.3f", f }')
  echo "$fade"
}

# Kenyaringan diukur dengan EBU R128, lalu digeser sekali dengan volume.
# Gain dibatasi agar true peak tidak melewati -2 dBFS.
ukur_i() {
  ffmpeg -hide_banner -nostats -i "$1" -af ebur128=peak=true -f null - 2>&1 |
    sed -n '/Summary/,$p' |
    sed -n 's/^ *I: *\(-\{0,1\}[0-9.]*\) LUFS.*/\1/p' | head -1
}

ukur_tp() {
  ffmpeg -hide_banner -nostats -i "$1" -af ebur128=peak=true -f null - 2>&1 |
    sed -n '/Summary/,$p' |
    sed -n 's/^ *Peak: *\(-\{0,1\}[0-9.]*\) dBFS.*/\1/p' | head -1
}

normal() {
  local masuk=$1 keluar=$2 fade=$3
  local i tp gain
  i=$(ukur_i "$masuk")
  tp=$(ukur_tp "$masuk")
  [ -n "$i" ] || i=-70
  [ -n "$tp" ] || tp=0
  # Efek sependek klik lebih pendek dari jendela ukur LUFS, jadi angkanya
  # jatuh ke hening dan gain akan mentok di batas peak. Untuk berkas itu
  # kenyaringan diatur lewat peak saja supaya tidak jadi letupan keras.
  gain=$(awk -v i="$i" -v tp="$tp" -v batas=-2 '
    BEGIN {
      if (i < -40) batas = -6
      g = -16 - i
      batas = batas - tp
      if (g > batas) g = batas
      printf "%.2f", g
    }')
  ffmpeg -hide_banner -loglevel error -y -i "$masuk" \
    -af "volume=${gain}dB,afade=t=out:st=$fade:d=0.1" \
    -ac 1 -ar 44100 -c:a pcm_s16le "$keluar"
}

shopt -s nullglob
diproses=0
for mentah in "$src"/*; do
  [ -f "$mentah" ] || continue
  ext=${mentah##*.}
  case ${ext,,} in
  wav | mp3 | m4a | ogg | flac | aac | caf) ;;
  *)
    echo "Lewati $(basename "$mentah"): bukan berkas audio" >&2
    continue
    ;;
  esac
  id=$(basename "$mentah")
  id=${id%.*}
  batas=$(batas_durasi "$id")
  jembatan=$tmp/$id.wav
  hasil=$out/$id.wav
  fade=$(rapikan "$mentah" "$jembatan" "$batas")
  normal "$jembatan" "$hasil" "$fade"
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$hasil")
  ukuran=$(du -k "$hasil" | cut -f1)
  printf '%-12s %4.2f dtk  %4s KB\n' "$id" "$dur" "$ukuran"
  diproses=$((diproses + 1))
done

if [ "$diproses" -eq 0 ]; then
  echo "Tidak ada berkas audio di $src" >&2
  exit 1
fi

# Susun ulang baris sfx/ di LICENSES.csv dari berkas yang ada.
baru=$tmp/LICENSES.csv
[ -f "$licenses" ] || printf 'file,sumber,URL,lisensi,tanggal unduh,catatan\n' >"$licenses"
baris_sfx=$tmp/baris-sfx.csv
: >"$baris_sfx"
for hasil in "$out"/*.wav; do
  [ -f "$hasil" ] || continue
  id=$(basename "$hasil")
  id=${id%.wav}
  baris=""
  if [ -f "$meta" ]; then
    baris=$(awk -F'\t' -v cari="$id" '$1 == cari { print; exit }' "$meta")
  fi
  if [ -z "$baris" ]; then
    lama=$(grep "^sfx/$id.wav," "$licenses" || true)
    if [ -n "$lama" ]; then
      printf '%s\n' "$lama" >>"$baris_sfx"
    else
      echo "Tidak ada baris lisensi untuk $id.wav; lengkapi $meta" >&2
    fi
    continue
  fi
  url=$(printf '%s' "$baris" | cut -f2)
  pengunggah=$(printf '%s' "$baris" | cut -f3)
  lisensi=$(printf '%s' "$baris" | cut -f4)
  tanggal=$(printf '%s' "$baris" | cut -f5)
  mutu=$(printf '%s' "$baris" | cut -f6)
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$hasil")
  potong=$(awk -v d="$dur" 'BEGIN { printf "%.2f", d }')
  potong=${potong%0}
  potong=${potong%.}
  printf 'sfx/%s.wav,Freesound,%s,%s,%s,"oleh %s, dipotong %s detik (pratinjau %s)"\n' \
    "$id" "$url" "$lisensi" "$tanggal" "$pengunggah" "$potong" "$mutu" >>"$baris_sfx"
done
{
  head -1 "$licenses"
  grep -v '^sfx/' "$licenses" | tail -n +2 || true
  LC_ALL=C sort "$baris_sfx"
} >"$baru"
mv "$baru" "$licenses"
echo "Selesai: $diproses berkas, lisensi di $licenses"
