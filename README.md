# Vending Machine RTL Design

A fully synthesizable, complete Verilog-based vending machine targeting the Real Digital Boolean FPGA board (XC7S50CSGA324-1) and ASIC synthesis flows.

## Project Overview
This project implements a digital vending machine controlled by a Finite State Machine (FSM). Users can insert coins (5, 10, 20) and select products (Water, Coffee, Soft Drink, Chips). The FSM ensures sufficient balance before dispensing and calculates any change due. The design is modular, with a pure RTL core and an FPGA wrapper.

## FSM Description
The core uses a 4-state synchronous Moore-style FSM:
1. `S_IDLE`: Waits for coin insertions or product selections. Accumulates balance on coin input.
2. `S_CHECK`: Evaluates if `current_balance >= price_to_check`.
3. `S_DISPENSE`: Triggers the dispense signal for 1 clock cycle. Returns change if balance > 0.
4. `S_RETURN_CHANGE`: Returns remaining balance to `change_out` and resets the transaction.

## Product Pricing
| Product | Price |
|---------|-------|
| Water | 10 |
| Coffee | 15 |
| Soft Drink | 20 |
| Chips | 25 |

## Files
- `vending_machine_core.v`: Pure synthesizable core module. No platform-dependent code. 4-state FSM with edge detection on all inputs.
- `vending_machine_boolean.v`: Wrapper module for the Boolean FPGA board. Connects switches, LEDs, RGB LED, and 7-segment display. Active-low reset inversion.
- `vending_machine_tb.v`: Comprehensive self-checking testbench with 12 test cases. Real-time state transition monitor. 12/12 PASS.
- `vending_machine_constraints.xdc`: Vivado constraint file with official Boolean board pin mappings (verified against realdigital.org boolean.xdc).

## Simulation Instructions
```bash
# Compile the design and testbench
iverilog -o sim.vvp vending_machine_core.v vending_machine_tb.v

# Run the simulation
vvp sim.vvp
```
All 12 tests should indicate PASS. A `.vcd` file is dumped automatically for waveform viewing in GTKWave.

## Boolean Board Pin Mapping
| Signal | Port | Pins |
|--------|------|------|
| Clock | `clk` | F14 (100 MHz) |
| Switches | `sw[0..6]` | V2, U2, U1, T2, T1, R2, R1 |
| LEDs | `led[0..3]` | G1, G2, F1, F2 |
| RGB LED | `led_rgb[0..2]` | V6, V4, U6 |
| Buttons | `btn[0..3]` | J2, J5, H2, J1 |
| 7-Seg D0 (ones) | `D0_SEG[0..7]`, `D0_AN[0..3]` | D7,C5,A5,B7,A7,D6,B5,A6 / D5,C4,C7,A8 |
| 7-Seg D1 (tens) | `D1_SEG[0..7]`, `D1_AN[0..3]` | F4,J3,D2,C2,B1,H4,D1,C1 / H3,J4,F3,E4 |

## Vivado Synthesis Instructions
1. Create a new Vivado project. Select part: `xc7s50csga324-1`.
2. Add `vending_machine_core.v` and `vending_machine_boolean.v` as design sources.
3. Add `vending_machine_constraints.xdc` as your constraints file.
4. Set `vending_machine_boolean` as the top module.
5. Run Synthesis -> Implementation -> Generate Bitstream.

## FPGA Programming
1. Connect the Real Digital Boolean board via USB.
2. Open Hardware Manager in Vivado.
3. Auto-connect to the target.
4. Program device with the generated `.bit` file.

**Expected FPGA Output:**
- Toggle SW0, SW1, SW2 to insert 5, 10, 20 coins respectively.
- Seven-segment display shows the current balance in base-10 live.
- Toggle SW3-SW6 to select a product (Water, Coffee, Soft Drink, Chips).
- If balance is sufficient, the corresponding LED (LED0-LED3) illuminates.
- RGB LED shows FSM state: Blue=IDLE, Green=DISPENSE/CHANGE, Red=CHECK.
- BTN0 resets the system. BTN3 cancels and returns change.

## Test Coverage (12/12 PASS)
1. Exact payment: Insert 10, Buy Water
2. Multi-coin exact: Insert 5+10, Buy Coffee
3. Exact payment: Insert 20, Buy Soft Drink
4. Multi-coin exact: Insert 20+5, Buy Chips
5. Insufficient funds: Insert 10, Buy Coffee (10<15)
6. Insufficient funds: Insert 20, Buy Chips (20<25)
7. Overpayment: Insert 20, Buy Water (change=10)
8. Multiple coins: Insert 5+5+5+5=20, Buy Soft Drink
9. Mid-transaction reset
10. Cancel returns change: Insert 5+10, Cancel (change=15)
11. Back-to-back: Insert 40, Buy Water (change=30), re-insert 25, Buy Chips
12. All edge cases verified with real-time state monitoring
