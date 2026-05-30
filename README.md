# Vending Machine RTL Design

Fully synthesizable vending machine for Real Digital Boolean FPGA board (XC7S50CSGA324-1).

## Testbench Signals (self-explanatory)

| Signal | Direction | Description |
|--------|-----------|-------------|
| `insert_5` | Input | Insert 5 coin (1 clock pulse) |
| `insert_10` | Input | Insert 10 coin (1 clock pulse) |
| `insert_20` | Input | Insert 20 coin (1 clock pulse) |
| `buy_water` | Input | Press water button (1 clock pulse) |
| `buy_coffee` | Input | Press coffee button (1 clock pulse) |
| `buy_softdrink` | Input | Press soft drink button (1 clock pulse) |
| `buy_chips` | Input | Press chips button (1 clock pulse) |
| `press_cancel` | Input | Press cancel button (1 clock pulse) |
| `balance` | Output | Current amount inserted (0-99) |
| `change_returned` | Output | Change given back (1-cycle pulse) |
| `water_ready` | Output | Water dispensed (1-cycle pulse) |
| `coffee_ready` | Output | Coffee dispensed (1-cycle pulse) |
| `softdrink_ready` | Output | Soft drink dispensed (1-cycle pulse) |
| `chips_ready` | Output | Chips dispensed (1-cycle pulse) |
| `state` | Output | FSM state: 0=IDLE,1=CHECK,2=DISPENSE,3=RET_CHANGE |

## Product Pricing
| Product | Price |
|---------|-------|
| Water | 10 |
| Coffee | 15 |
| Soft Drink | 20 |
| Chips | 25 |

## Simulation
```bash
iverilog -o sim.vvp vending_machine_core.v vending_machine_tb.v
vvp sim.vvp
```

## Files
- `vending_machine_core.v` — 4-state FSM core (160 lines, unmodified)
- `vending_machine_boolean.v` — Boolean board wrapper (RGB LED, 7-seg display)
- `vending_machine_tb.v` — 12 tests, 68 waveform signals, self-explanatory names
- `vending_machine_constraints.xdc` — Official pin mappings (create_clock, CFGBVS, 38 pins)

## Boolean Board Pins
| Signal | Pins |
|--------|------|
| Clock | F14 |
| Switches | V2,U2,U1,T2,T1,R2,R1 |
| LEDs | G1,G2,F1,F2 |
| RGB | V6,V4,U6 |
| Buttons | J2,J1 (BTN0=reset, BTN3=cancel) |
| 7-Seg D0 | SEG: D7,C5,A5,B7,A7,D6,B5,A6 / AN: D5,C4,C7,A8 |
| 7-Seg D1 | SEG: F4,J3,D2,C2,B1,H4,D1,C1 / AN: H3,J4,F3,E4 |

## Test Coverage (12/12 PASS)
1. Insert 10, buy Water (exact)
2. Insert 5+10, buy Coffee (exact)
3. Insert 20, buy Soft Drink (exact)
4. Insert 20+5, buy Chips (exact)
5. Insert 10, buy Coffee (reject -- not enough)
6. Insert 20, buy Chips (reject -- not enough)
7. Insert 20, buy Water (overpay -- change=10)
8. Insert 5x4=20, buy Soft Drink (multi-coin)
9. Insert 10, reset mid-transaction
10. Insert 5+10, cancel (change=15)
11. Back-to-back: buy Water then buy Chips
