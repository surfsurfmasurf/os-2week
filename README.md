# os-2week

Two-week OS build log (MS-DOS / minimal Linux style).

## Goal
- Build a tiny, demoable OS project in 14 days
- Keep daily notes and ship code every day

## Build / Run
Requirements:
- `nasm`
- `qemu-system-i386` (optional, for `make run`)

Commands:
- `make` — build a minimal boot sector (`build/boot.bin`)
- `make run` — boot it in QEMU

## Daily Updates
- `daily/YYYY-MM-DD.md` — daily log
- `.daily_update.txt` — last update summary (auto-generated)
