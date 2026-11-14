# Pintasan untuk scripts/moci.sh. Pilih perangkat dengan DEVICE=<id atau nama>.
#   make install            build release lalu pasang ke iPad/HP yang terhubung
#   make run                jalankan debug dengan hot reload
#   make install DEVICE=emulator-5554

.PHONY: help devices run run-profile install build-ios build-apk check

help:
	@scripts/moci.sh help

devices:
	@scripts/moci.sh devices

run:
	@scripts/moci.sh run debug

run-profile:
	@scripts/moci.sh run profile

install:
	@scripts/moci.sh install

build-ios:
	@scripts/moci.sh build ios

build-apk:
	@scripts/moci.sh build apk

check:
	@scripts/moci.sh check
