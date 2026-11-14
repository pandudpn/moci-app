#!/usr/bin/env bash
# Build dan pasang Moci langsung ke perangkat sendiri (tanpa App Store / Play Store).
#
#   scripts/moci.sh devices             daftar perangkat yang terhubung
#   scripts/moci.sh run [debug|profile] jalankan dengan hot reload (bawaan: debug)
#   scripts/moci.sh install             build release (debug untuk simulator), pasang, lalu buka
#   scripts/moci.sh build ios|apk       build release saja
#   scripts/moci.sh check               format, analyze, tes, validator konten
#
# Pilih perangkat dengan DEVICE=<id atau nama>. Tanpa DEVICE, perangkat fisik
# pertama (iOS lalu Android) yang dipakai. DEVICE=<UDID simulator> memasang
# build debug ke simulator iOS (lihat: xcrun simctl list devices).
set -euo pipefail

cd "$(dirname "$0")/.."

readonly BUNDLE_ID="id.pandudpn.moci"
readonly ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
readonly ADB="$ANDROID_HOME/platform-tools/adb"

die() { echo "galat: $*" >&2; exit 1; }
info() { echo "==> $*"; }

command -v fvm >/dev/null || die "fvm tidak ditemukan (brew install fvm)"
command -v jq >/dev/null || die "jq tidak ditemukan (brew install jq)"

devices_json() {
  fvm flutter devices --machine --device-timeout 10 2>/dev/null
}

# Simulator hanya dikenali lewat UDID, supaya nama iPad fisik tidak tertukar.
is_simulator() {
  xcrun simctl list devices -j 2>/dev/null |
    jq -e --arg d "$1" '[.devices[][] | select(.udid == $d)] | length > 0' >/dev/null
}

# Mencetak "<id>\t<platform>" untuk perangkat yang dipilih.
pick_device() {
  local json
  if [[ -n "${DEVICE:-}" ]] && is_simulator "$DEVICE"; then
    printf '%s\tios-simulator\n' "$DEVICE"
    return
  fi
  json="$(devices_json)"
  if [[ -n "${DEVICE:-}" ]]; then
    jq -r --arg d "$DEVICE" '
      map(select(.id == $d or .name == $d)) | first // empty
      | "\(.id)\t\(.targetPlatform)"' <<<"$json"
  else
    jq -r '
      map(select(.emulator == false and
                 (.targetPlatform == "ios" or (.targetPlatform | startswith("android")))))
      | sort_by(if .targetPlatform == "ios" then 0 else 1 end)
      | first // empty
      | "\(.id)\t\(.targetPlatform)"' <<<"$json"
  fi
}

require_device() {
  local picked
  picked="$(pick_device)"
  [[ -n "$picked" ]] || die "tidak ada perangkat. Sambungkan iPad/HP (buka kuncinya, aktifkan Developer Mode) atau set DEVICE=<id>. Lihat: scripts/moci.sh devices"
  DEVICE_ID="${picked%%$'\t'*}"
  PLATFORM="${picked##*$'\t'}"
  info "perangkat: $DEVICE_ID ($PLATFORM)"
}

cmd_devices() {
  fvm flutter devices --device-timeout 10
}

cmd_run() {
  local mode="${1:-debug}"
  [[ "$mode" == debug || "$mode" == profile ]] || die "mode run: debug atau profile"
  require_device
  fvm flutter run "--$mode" -d "$DEVICE_ID"
}

build_ios() {
  info "build iOS release"
  if ! fvm flutter build ios --release; then
    cat >&2 <<'EOF'

Build iOS gagal. Kalau galatnya "No Accounts" atau "No profiles for 'id.pandudpn.moci'":
  1. Xcode > Settings > Accounts: masuk dengan Apple ID tim 84AH25JJZF.
  2. open ios/Runner.xcworkspace, target Runner > Signing & Capabilities:
     centang "Automatically manage signing", pilih tim itu.
  3. Jalankan lagi: make install
EOF
    exit 1
  fi
}

build_apk() {
  info "build APK release (arm64)"
  # Sisa integration test bisa mendaftarkan plugin tes di build release;
  # berkas ini dibuat ulang oleh Flutter.
  rm -f android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java
  fvm flutter build apk --release --target-platform android-arm64
}

cmd_build() {
  case "${1:-}" in
    ios) build_ios ;;
    apk) build_apk ;;
    *) die "build: ios atau apk" ;;
  esac
}

cmd_install() {
  require_device
  case "$PLATFORM" in
    ios)
      build_ios
      info "memasang ke $DEVICE_ID"
      xcrun devicectl device install app --device "$DEVICE_ID" build/ios/iphoneos/Runner.app ||
        die "gagal memasang. Kalau galatnya 'Developer mode is not enabled', nyalakan di iPad: Pengaturan > Privasi & Keamanan > Mode Pengembang, restart, pilih Nyalakan, lalu ulangi make install."
      info "membuka aplikasi"
      xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID" ||
        echo "Aplikasi terpasang. Kalau iPad menolak membukanya, percayai sertifikat pengembang di Pengaturan > Umum > VPN & Manajemen Perangkat."
      ;;
    ios-simulator)
      # Build debug untuk simulator: cepat dan tanpa codesign.
      info "build iOS simulator (debug)"
      fvm flutter build ios --simulator --debug
      xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
      open -a Simulator 2>/dev/null || info "Simulator.app tidak ada; simulator berjalan tanpa jendela"
      info "memasang ke $DEVICE_ID"
      xcrun simctl install "$DEVICE_ID" build/ios/iphonesimulator/Runner.app
      info "membuka aplikasi"
      xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" >/dev/null
      ;;
    android*)
      [[ -x "$ADB" ]] || die "adb tidak ditemukan di $ADB (set ANDROID_HOME)"
      build_apk
      info "memasang ke $DEVICE_ID"
      "$ADB" -s "$DEVICE_ID" install -r build/app/outputs/flutter-apk/app-release.apk
      "$ADB" -s "$DEVICE_ID" shell monkey -p "$BUNDLE_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
      ;;
    *) die "platform $PLATFORM tidak didukung untuk install" ;;
  esac
  info "selesai"
}

cmd_check() {
  rm -rf build/test
  fvm dart format --output=none --set-exit-if-changed lib test tool integration_test
  fvm flutter analyze
  fvm flutter test --exclude-tags golden
  fvm dart run tool/validate_content.dart
}

usage() { sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; }

case "${1:-}" in
  devices) cmd_devices ;;
  run) shift; cmd_run "$@" ;;
  install) cmd_install ;;
  build) shift; cmd_build "$@" ;;
  check) cmd_check ;;
  -h | --help | help | "") usage ;;
  *) usage; exit 1 ;;
esac
