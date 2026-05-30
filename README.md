# Vending Machine RTL Design

A fully synthesizable, complete Verilog-based vending machine targeting the Real Digital Boolean FPGA board (XC7S50CSGA324-1) and ASIC synthesis flows.

## Project Overview
This project implements a digital vending machine controlled by a Finite State Machine (FSM). Users can insert coins (₹5, ₹10, ₹20) and select products (Water, Coffee, Soft Drink, Chips). The FSM ensures sufficient balance before dispensing and calculates any change due. The design is modular, with a pure RTL core and an FPGA wrapper.

## FSM Description
The core uses a 4-state synchronous Moore/Mealy hybrid FSM:
1. `S_IDLE`: Waits for coin insertions or product selections. Accumulates balance on coin input.
2. `S_CHECK`: Evaluates if `current_balance >= price_to_check`.
3. `S_DISPENSE`: Triggers the dispense signal for 1 clock cycle.
4. `S_RETURN_CHANGE`: Returns remaining balance to `change_out` and resets the transaction.

## Files
- `vending_machine_core.v`: Pure synthesizable core module. No platform-dependent code.
- `vending_machine_tb.v`: Comprehensive, self-checking Verilog testbench covering 10 distinct cases (change, insufficient funds, resets).
- `vending_machine_boolean.v`: Wrapper module for the Boolean FPGA board. Connects switches, LEDs, and handles Seven-Segment multiplexing.
- `vending_machine_constraints.xdc`: Vivado constraint file with Boolean board pin mappings.

## Simulation Instructions
You can simulate the core using Icarus Verilog or any standard EDA tool.

```bash
# Compile the design and testbench
iverilog -o sim.vvp vending_machine_core.v vending_machine_tb.v

# Run the simulation
vvp sim.vvp
```
All tests should indicate `PASS: Case X`. A `.vcd` file is dumped automatically for waveform viewing in GTKWave.

## Vivado Synthesis Instructions
1. Create a new Vivado project.
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
- Toggle SW0, SW1, SW2, then toggle back to 0 to insert 5, 10, 20 coins respectively.
- Seven-segment display will show the current balance in base-10 live.
- Toggle SW3-SW6, then back to 0, to select a product.
- If balance is sufficient, the corresponding LED (LED0-LED3) will illuminate indicating a successful dispense.
- BTN0 resets the system.
- BTN3 cancels a transaction and returns change.

## Changelog
- **v1.1** (2026-05-30): Fixed reset polarity — buttons on Boolean board are active LOW, added `~btn[0]` inversion in boolean wrapper.
- **v1.0** (2026-05-29): Initial release — 4-state FSM, 10/10 tests pass, synthesizable on Vivado and Cadence Genus.
