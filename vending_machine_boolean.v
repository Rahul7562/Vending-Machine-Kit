`timescale 1ns / 1ps

module vending_machine_boolean (
    input  wire clk,
    input  wire [6:0] sw,       // Switches: sw[0..2]=coins, sw[3..6]=product select
    input  wire [3:0] btn,      // Buttons: btn[0]=rst(btn[1..2]=unused), btn[3]=cancel
    output wire [3:0] led,      // LEDs: dispense indicators
    output wire [2:0] led_rgb,  // RGB LED: FSM state indicator (active HIGH)
    output reg  [7:0] D0_SEG,   // 7-seg display 0 segments (active low, bit 7=DP)
    output reg  [3:0] D0_AN,    // 7-seg display 0 anodes (active low)
    output reg  [7:0] D1_SEG,   // 7-seg display 1 segments (active low, bit 7=DP)
    output reg  [3:0] D1_AN     // 7-seg display 1 anodes (active low)
);

    // Boolean board: buttons active LOW (pressed=0 due to pull-up)
    // Core uses active-high rst, so invert btn[0]
    wire rst = ~btn[0];
    wire cancel = btn[3];

    wire dispense_water;
    wire dispense_coffee;
    wire dispense_softdrink;
    wire dispense_chips;
    wire [7:0] change_out;
    wire [7:0] current_balance;
    wire cancel_out;
    wire [2:0] state_out;

    vending_machine_core core_inst (
        .clk(clk),
        .rst(rst),
        .coin_5(sw[0]),
        .coin_10(sw[1]),
        .coin_20(sw[2]),
        .select_water(sw[3]),
        .select_coffee(sw[4]),
        .select_softdrink(sw[5]),
        .select_chips(sw[6]),
        .cancel(cancel),
        .dispense_water(dispense_water),
        .dispense_coffee(dispense_coffee),
        .dispense_softdrink(dispense_softdrink),
        .dispense_chips(dispense_chips),
        .change_out(change_out),
        .current_balance(current_balance),
        .cancel_out(cancel_out),
        .state_out(state_out)
    );

    // Sticky LED latch: stays on after 1-cycle dispense pulse
    reg [3:0] led_reg;
    always @(posedge clk) begin
        if (rst || cancel_out) begin
            led_reg <= 4'b0000;
        end else begin
            if (dispense_water)     led_reg[0] <= 1'b1;
            if (dispense_coffee)    led_reg[1] <= 1'b1;
            if (dispense_softdrink) led_reg[2] <= 1'b1;
            if (dispense_chips)     led_reg[3] <= 1'b1;
        end
    end
    assign led = led_reg;

    // RGB LED mapping (active HIGH — drives RGB0 on Boolean board)
    // IDLE: Blue, DISPENSE/CHANGE: Green, CHECK: Red
    assign led_rgb[0] = (state_out == 3'd0);                    // Blue
    assign led_rgb[1] = (state_out == 3'd2 || state_out == 3'd3); // Green
    assign led_rgb[2] = (state_out == 3'd1);                    // Red

    // 7-Segment Display (Multiplexed across D0 and D1)
    // Shows current_balance: D0=ones digit, D1=tens digit
    reg [15:0] clk_div;
    always @(posedge clk) clk_div <= clk_div + 1;

    wire [3:0] digit0 = current_balance % 10;         // ones
    wire [3:0] digit1 = (current_balance / 10) % 10;  // tens

    // Segment lookup (active low, common anode): bit 7=DP, bits 6:0=a..g
    function [7:0] seg_lookup;
        input [3:0] digit;
        case (digit)
            4'd0: seg_lookup = 8'b10000001;
            4'd1: seg_lookup = 8'b11110011;
            4'd2: seg_lookup = 8'b01001001;
            4'd3: seg_lookup = 8'b01100001;
            4'd4: seg_lookup = 8'b00110011;
            4'd5: seg_lookup = 8'b00100101;
            4'd6: seg_lookup = 8'b00000101;
            4'd7: seg_lookup = 8'b11110001;
            4'd8: seg_lookup = 8'b00000001;
            4'd9: seg_lookup = 8'b00100001;
            default: seg_lookup = 8'b11111111;
        endcase
    endfunction

    // Alternate between D0 (ones) and D1 (tens) at ~1.5kHz refresh
    always @(*) begin
        if (clk_div[15] == 1'b0) begin
            D0_SEG = seg_lookup(digit0);
            D0_AN  = 4'b1110;
            D1_SEG = 8'b11111111;
            D1_AN  = 4'b1111;
        end else begin
            D0_SEG = 8'b11111111;
            D0_AN  = 4'b1111;
            D1_SEG = seg_lookup(digit1);
            D1_AN  = 4'b1110;
        end
    end

endmodule
