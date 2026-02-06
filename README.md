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
- `make` — build a tiny raw disk image (`build/os.img`)
- `make run` — boot it in QEMU

## What it boots today
- Stage 1 (`src/boot.asm`): 512-byte boot sector that prints a message, loads stage2 from disk sector 2, then jumps.
- Stage 2 (`src/stage2.asm`): prints a message and halts.

## Daily Updates
- `daily/YYYY-MM-DD.md` — daily log
- `.daily_update.txt` — last update summary (auto-generated)
