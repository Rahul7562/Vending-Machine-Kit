# VENDING MACHINE — RTL DESIGN PROJECT

**Target:** Real Digital Boolean Board (XC7S50CSGA324-1)
**Author:** Rahul | B.Tech EE VLSI, CVR College Hyderabad
**Repo:** https://github.com/Rahul7562/Vending-Machine-Kit

---

## TABLE OF CONTENTS

```
  1. Project Overview
  2. Architecture & Design Philosophy
  3. FSM Core — How It Works
  4. Boolean Board Wrapper — Hardware Interface
  5. Testbench & Verification
  6. Pin Constraints
  7. Synthesis & Bitstream Generation
  8. User Manual — Operating the Vending Machine on FPGA
  9. Waveform Guide
 10. Project Summary
```

---

# 1. PROJECT OVERVIEW

This project implements a fully digital vending machine on a **Xilinx Spartan-7 FPGA** (XC7S50CSGA324-1) using **Verilog HDL**. The design follows a clean, modular architecture with a pure RTL core that can target both FPGA and ASIC flows, plus a board-specific wrapper for the Real Digital Boolean FPGA development board.

**Key Features:**
- 4-state Moore-style Finite State Machine (FSM)
- Edge detection on all inputs (no missed pulses)
- Sticky LED indicators for dispense events (human-visible)
- RGB LED showing real-time FSM state
- Dual-digit 7-segment balance display with multiplexing
- Comprehensive testbench with 12 test cases — all passing
- Zero compilation warnings across all files

**Project Files:**

| File | Description | Lines |
|------|-------------|-------|
| `vending_machine_core.v` | Pure RTL FSM (portable) | 160 |
| `vending_machine_boolean.v` | Board wrapper (RGB + 7-seg) | 95 |
| `vending_machine_tb.v` | Testbench (12 tests, self-documenting) | 167 |
| `vending_machine_constraints.xdc` | Official pin constraints (38 pins) | 68 |

---

# 2. ARCHITECTURE & DESIGN PHILOSOPHY

The design is split into two independent modules that communicate through a clean interface. This separation means the **core logic is portable** — it can be synthesized for any FPGA or ASIC technology without modification.

```
  ┌──────────────────────────────────────────────────────────────┐
  │                    BOOLEAN BOARD (Hardware)                   │
  │  Switches  Buttons  LEDs  RGB  7-Seg Display                 │
  └──────┬───────┬───────┬─────┬────┬──────────┬────────────────┘
         │       │       │     │    │          │
  ┌──────▼───────▼───────▼─────▼────▼──────────▼────────────────┐
  │              VENDING_MACHINE_BOOLEAN (Wrapper)                │
  │  • Active-low button inversion                               │
  │  • Sticky LED latch                                          │
  │  • RGB LED state indicator                                   │
  │  • 7-segment multiplexer                                     │
  └──────────────┬───────────────────────────────────────────────┘
                 │  Clean interface (coins, select, cancel)
  ┌──────────────▼───────────────────────────────────────────────┐
  │              VENDING_MACHINE_CORE (FSM)                       │
  │  • 4-state FSM (IDLE→CHECK→DISPENSE→RETURN_CHANGE)           │
  │  • Edge detection on all inputs                              │
  │  • Priority encoding: coins > select > cancel                │
  │  • Balance accumulation & change calculation                 │
  └──────────────────────────────────────────────────────────────┘
```

**Design Principles:**
- **Core is frozen** — `vending_machine_core.v` was never modified during FPGA integration
- **Zero warnings** — Every file compiles with zero warnings (strict quality standard)
- **Self-documenting testbench** — Signal names like `insert_5`, `buy_water`, `balance`

---

# 3. FSM CORE — HOW IT WORKS

The heart of the vending machine is a **4-state synchronous Moore FSM** implemented in a single `always @(posedge clk)` block. All inputs use **edge detection** (not level sensing).

## 3.1 State Diagram

```
                    ┌─────────────────────────────────────────────┐
                    │                                             │
                    ▼                                             │
  ┌──────────────────────────────────────────────────────────┐   │
  │  S_IDLE  (state = 0)                                      │   │
  │                                                           │   │
  │  Waits for user input:                                    │   │
  │    coin_5_p  → balance += 5                               │   │
  │    coin_10_p → balance += 10                              │   │
  │    coin_20_p → balance += 20                              │   │
  │    sel_water_p      → price=10,  product=0001 → CHECK     │   │
  │    sel_coffee_p     → price=15,  product=0010 → CHECK     │   │
  │    sel_softdrink_p  → price=20,  product=0100 → CHECK     │   │
  │    sel_chips_p      → price=25,  product=1000 → CHECK     │   │
  │    cancel_p (bal>0) → RETURN_CHANGE                       │   │
  └───────────────────────────┬───────────────────────────────┘   │
                              │                                    │
                              ▼                                    │
  ┌──────────────────────────────────────────────────────────┐   │
  │  S_CHECK  (state = 1)                                     │   │
  │                                                           │   │
  │  Compares balance vs price:                               │   │
  │    balance >= price → subtract price, go to DISPENSE      │   │
  │    balance <  price → reject, go back to IDLE             │   │
  └───────────────────────────┬───────────────────────────────┘   │
                              │                                    │
                              ▼                                    │
  ┌──────────────────────────────────────────────────────────┐   │
  │  S_DISPENSE  (state = 2)                                  │   │
  │                                                           │   │
  │  Fires dispense pulse for 1 clock cycle:                  │   │
  │    product[0] → dispense_water  = 1                       │   │
  │    product[1] → dispense_coffee = 1                       │   │
  │    product[2] → dispense_softdrink = 1                    │   │
  │    product[3] → dispense_chips  = 1                       │   │
  │                                                           │   │
  │  Then: balance > 0 → RETURN_CHANGE                        │   │
  │        balance = 0 → IDLE                                 │   │
  └───────────────────────────┬───────────────────────────────┘   │
                              │                                    │
                              ▼                                    │
  ┌──────────────────────────────────────────────────────────┐   │
  │  S_RETURN_CHANGE  (state = 3)                             │   │
  │                                                           │   │
  │  Returns balance as change, resets to IDLE                │   │
  └──────────────────────────────────────────────────────────┘   │
```

## 3.2 Edge Detection

All 7 inputs use the same pattern — a pulse fires for exactly **one clock cycle** on the rising edge:

```verilog
wire coin_5_p = coin_5 && !coin_5_d;
//                     ↑           ↑
//                 current    1-cycle delayed
```

This prevents a single switch toggle from being counted multiple times.

## 3.3 Priority Encoding

In `S_IDLE`: `coin_5 > coin_10 > coin_20 > sel_water > sel_coffee > sel_softdrink > sel_chips > cancel`

If a coin and product button coincide, the coin is processed first.

---

# 4. BOOLEAN BOARD WRAPPER — HARDWARE INTERFACE

## 4.1 Button Inversion

Buttons on the Boolean board are **active LOW** (pressed = 0). The wrapper inverts for the active-high core:

```verilog
wire rst = ~btn0;    // BTN0 = reset
```

## 4.2 Sticky LED Latch

The FSM fires dispense signals for only 1 clock cycle (10 ns at 100 MHz) — too fast to see. The wrapper latches them:

```
  LED lights up when product is dispensed → STAYS LIT
  LED turns off when RESET or CANCEL pressed
```

## 4.3 RGB LED — FSM State Indicator

```
  COLOR       STATE              MEANING
  ──────────  ─────────────────  ──────────────────────────
  🔵 Blue     S_IDLE (0)         Waiting for input
  🔴 Red      S_CHECK (1)        Checking if balance >= price
  🟢 Green    S_DISPENSE (2)     Product being dispensed
  🟢 Green    S_RETURN_CHANGE (3) Returning change
```

## 4.4 7-Segment Display

Dual-digit multiplexed display at ~1.5 kHz refresh. Segment encoding (active LOW):

| Digit | Hex  | Segments ON |
|-------|------|-------------|
| 0 | 0xC0 | a,b,c,d,e,f |
| 1 | 0xF9 | b,c |
| 2 | 0xA4 | a,b,d,e,g |
| 3 | 0xB0 | a,b,c,d,g |
| 4 | 0x99 | b,c,f,g |
| 5 | 0x92 | a,c,d,f,g |
| 6 | 0x82 | a,c,d,e,f,g |
| 7 | 0xF8 | a,b,c |
| 8 | 0x80 | all |
| 9 | 0x90 | a,b,c,d,f,g |

```
  Bit:  [7]  [6]  [5]  [4]  [3]  [2]  [1]  [0]
        DP    g    f    e    d    c    b    a
```

---

# 5. TESTBENCH & VERIFICATION

## 5.1 Test Signals (Self-Documenting)

```
  INPUTS:                            OUTPUTS:
  insert_5/10/20    Insert coin      balance          Money inserted
  buy_water/coffee  Select product   change_returned  Change pulse
  buy_softdrink/chips               water_ready      Water dispensed
  press_cancel      Cancel           coffee_ready     Coffee dispensed
                                     softdrink_ready  Soft drink dispensed
                                     chips_ready      Chips dispensed
                                     state            FSM state (0-3)
```

## 5.2 Test Cases (12/12 PASS)

| # | Test | Result |
|---|------|--------|
| 1 | Insert 10, Buy Water | PASS |
| 2 | Insert 5+10, Buy Coffee | PASS |
| 3 | Insert 20, Buy Soft Drink | PASS |
| 4 | Insert 20+5, Buy Chips | PASS |
| 5 | Insert 10, Buy Coffee (REJECT — 10<15) | PASS |
| 6 | Insert 20, Buy Chips (REJECT — 20<25) | PASS |
| 7 | Insert 20, Buy Water (OVERPAY — change=10) | PASS |
| 8 | Insert 5×4=20, Buy Soft Drink | PASS |
| 9 | Insert 10, RESET mid-transaction | PASS |
| 10 | Insert 5+10, CANCEL | PASS |
| 11 | Back-to-back: Water (change=30) + Chips | PASS |

## 5.3 Running Simulation

```bash
iverilog -o sim.vvp vending_machine_core.v vending_machine_tb.v
vvp sim.vvp
gtkwave vending_machine.vcd
```

---

# 6. PIN CONSTRAINTS (38 pins, verified vs official boolean.xdc)

| Peripheral | Pins |
|------------|------|
| Clock | F14 |
| Switches SW[0..6] | V2, U2, U1, T2, T1, R2, R1 |
| LEDs LED[0..3] | G1, G2, F1, F2 |
| RGB LED | V6, V4, U6 |
| Buttons BTN0, BTN3 | J2, J1 |
| 7-Seg D0 anodes | D5, C4, C7, A8 |
| 7-Seg D0 segments | D7, C5, A5, B7, A7, D6, B5, A6 |
| 7-Seg D1 anodes | H3, J4, F3, E4 |
| 7-Seg D1 segments | F4, J3, D2, C2, B1, H4, D1, C1 |

**Critical: `create_clock` must be defined or ALL timing checks fail.**

```tcl
create_clock -period 10.00 -waveform {0 5} [get_ports {clk}];
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];
```

---

# 7. SYNTHESIS & BITSTREAM

## Vivado Workflow

```
  1. Create Project → Select xc7s50csga324-1
  2. Add Sources → vending_machine_core.v + vending_machine_boolean.v
  3. Add Constraints → vending_machine_constraints.xdc
  4. Set Top → vending_machine_boolean
  5. Run Synthesis → Implementation → Generate Bitstream
  6. Open Hardware Manager → Connect → Program Device
```

---

# 8. USER MANUAL — OPERATING ON FPGA

## 8.1 Initial State

On power-up or reset:
- **RGB LED**: 🔵 Blue (IDLE)
- **7-Segment**: `00` (zero balance)
- **LEDs**: All OFF

## 8.2 Board Layout

```
  SW6 SW5 SW4 SW3 SW2 SW1 SW0    ← Slide Switches (toggle ON then OFF)
  [Ch] [SD] [Cf] [Wt] [₹20][₹10][₹5]

  BTN3  BTN2  BTN1  BTN0         ← Push Buttons (press briefly)
  [Cancel] [—]  [—]  [RESET]

  LED3  LED2  LED1  LED0         ← Product LEDs (lit = dispensed)
  [Chips][SD] [Coffee][Water]

  RGB LED                        ← FSM state color indicator

  D1    D0                       ← 7-Segment (tens | ones)
```

## 8.3 Example: Buy Water (price = 10)

```
  Step 1: Toggle SW0 (₹5) ON→OFF    → Display: "05", RGB: Blue
  Step 2: Toggle SW0 (₹5) ON→OFF    → Display: "10", RGB: Blue  
  Step 3: Toggle SW3 (Water) ON→OFF → RGB: Red→Green, LED0: ON, Display: "00"
```

## 8.4 Example: Overpay (Insert ₹20, Buy Water ₹10)

```
  Step 1: Toggle SW2 (₹20) ON→OFF   → Display: "20", RGB: Blue
  Step 2: Toggle SW3 (Water) ON→OFF → RGB: Red→Green, LED0: ON, Display: "00"
                                           (change_out pulses ₹10 internally)
```

## 8.5 Example: Cancel Transaction

```
  Step 1: Toggle SW0 (₹5) ON→OFF    → Display: "05"
  Step 2: Toggle SW1 (₹10) ON→OFF   → Display: "15"
  Step 3: Press BTN3 (Cancel)       → Display: "00", change_out pulses 15
```

## 8.6 Example: Insufficient Funds

```
  Step 1: Toggle SW0 (₹5) ON→OFF    → Display: "05"
  Step 2: Toggle SW6 (Chips) ON→OFF → Nothing! (5 < 25) Display: "05"
```

## 8.7 RGB LED Quick Reference

```
  🔵 Blue   = Idle, waiting
  🔴 Red    = Checking funds (brief flash)
  🟢 Green  = Dispensing product OR returning change
```

---

# 9. WAVEFORM GUIDE

Add these 14 essential signals in GTKWave:

```
  clk              — 100 MHz reference
  rst              — Reset
  insert_5/10/20   — Coin inputs
  buy_water/coffee/softdrink/chips — Product selection
  press_cancel     — Cancel
  balance          — Current amount (0-99)
  change_returned  — Change pulse
  state            — FSM state (0=IDLE, 1=CHECK, 2=DISPENSE, 3=RET_CHANGE)
```

---

# 10. PROJECT SUMMARY

## What Was Built

A complete 4-state vending machine FSM on FPGA with coin handling, product selection, change return, and cancel/reset functionality.

## Verification

| Metric | Result |
|--------|--------|
| Tests | 12/12 PASS |
| Warnings | 0 (all files) |
| DRC | Clean |
| Pins | 38, all verified |
| Clock | create_clock present |

## Architecture Decisions

| Decision | Rationale |
|----------|----------|
| Separate core + wrapper | Core portable across FPGA/ASIC |
| Edge detection | Prevents double-counting |
| Single always block | Safer timing |
| Sticky LED latch | Human-visible dispense |
| `max_chg` accumulator | Reliable 1-cycle pulse capture |
| Per-signal pulse tasks | Icarus NBA compatibility |
| Individual btn pins | Eliminates DRC warnings |

## Tech Stack

```
  Language:       Verilog-2001
  Simulation:     Icarus Verilog + GTKWave
  Synthesis:      Xilinx Vivado 2023.2
  Target:         XC7S50CSGA324-1 (Spartan-7)
  Board:          Real Digital Boolean FPGA Board
  Clock:          100 MHz (F14)
  Repo:           github.com/Rahul7562/Vending-Machine-Kit
```
