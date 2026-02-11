# OS 2-Week Sprint Roadmap

A 14-day journey to build a minimal x86 OS from scratch.

## 🎯 Goal
Build a demoable OS that boots, accepts keyboard commands, and manages simple system tasks.

---

## 📅 Milestones

### Phase 1: Boot & Hardware Baseline (Days 1-4) - ✅ DONE
- [x] Day 1: Boot sector (Stage 1) - Print "Hello" from BIOS.
- [x] Day 2: Multi-stage loading - Load Stage 2 from disk.
- [x] Day 3: Entering 32-bit Protected Mode - GDT setup.
- [x] Day 4: Screen driver - VGA text mode (scrolling/colors).

### Phase 2: Shell & User Interaction (Days 5-8) - 🚧 IN PROGRESS
- [x] Day 5: Primitive shell - Keyboard IRQ + char echo.
- [x] Day 6: Basic commands - `reboot` (via PS/2 controller) and `halt`.
- [x] Day 7: Input Buffering - Buffer keystrokes into strings.
- [x] Day 8: Command Parser - Multi-character command support (e.g., `help`, `clear`).

### Phase 3: Kernel Foundations (Days 9-11)
- [ ] Day 9: Interrupt Descriptor Table (IDT) - Proper exception handling.
- [ ] Day 10: Physical Memory Manager - Bitmap-based page allocation.
- [ ] Day 11: Virtual Memory - Simple paging setup for kernel.

### Phase 4: System Services & Apps (Days 12-14)
- [ ] Day 12: System Calls - Software interrupt interface (Int 0x80 style).
- [ ] Day 13: Userspace Transition - Jump to Ring 3.
- [ ] Day 14: Final Demo App - Run a standalone "Hello World" app in userspace.

---

## 🛠 Tech Stack
- **Architecture**: x86 (IA-32)
- **Language**: Assembly (NASM), [Optionally C for Kernel logic later]
- **Emulator**: QEMU
- **Build System**: Makefile
