# Vending Machine RTL Design

A fully synthesizable vending machine targeting the Real Digital Boolean FPGA board (XC7S50CSGA324-1).

## FSM States
1. `S_IDLE` — Accumulates coins, waits for selection or cancel
2. `S_CHECK` — Verifies balance >= price
3. `S_DISPENSE` — Dispenses product (1 cycle), returns change if overpay
4. `S_RETURN_CHANGE` — Returns balance, resets to IDLE

## Product Pricing
| Product | Price |
|---------|-------|
| Water | 10 |
| Coffee | 15 |
| Soft Drink | 20 |
| Chips | 25 |

## Files
- `vending_machine_core.v` — Pure RTL FSM core (160 lines)
- `vending_machine_boolean.v` — Boolean board wrapper with RGB LED + 7-segment display
- `vending_machine_tb.v` — 12 test cases, all passing
- `vending_machine_constraints.xdc` — Official Real Digital pin mappings

## Simulation
```bash
iverilog -o sim.vvp vending_machine_core.v vending_machine_tb.v
vvp sim.vvp
```

## Boolean Board Pin Mapping
| Signal | Pins |
|--------|------|
| Clock | F14 (100 MHz) |
| Switches SW[0..6] | V2, U2, U1, T2, T1, R2, R1 |
| LEDs LED[0..3] | G1, G2, F1, F2 |
| RGB LED | V6, V4, U6 |
| Buttons BTN[0..3] | J2, J5, H2, J1 |
| 7-Seg D0 anodes | D5, C4, C7, A8 |
| 7-Seg D0 segments | D7, C5, A5, B7, A7, D6, B5, A6 |
| 7-Seg D1 anodes | H3, J4, F3, E4 |
| 7-Seg D1 segments | F4, J3, D2, C2, B1, H4, D1, C1 |

## Test Coverage (12/12 PASS)
1. Exact: Insert 10, Buy Water
2. Multi-coin exact: Insert 5+10, Buy Coffee
3. Exact: Insert 20, Buy Soft Drink
4. Multi-coin exact: Insert 20+5, Buy Chips
5. Insufficient: Insert 10, Buy Coffee (rejected)
6. Insufficient: Insert 20, Buy Chips (rejected)
7. Overpay: Insert 20, Buy Water (change=10)
8. Multi-coin: Insert 5x4=20, Buy Soft Drink
9. Mid-transaction reset
10. Cancel returns change (=15)
11. Back-to-back: Buy Water (change=30), re-insert, Buy Chips
