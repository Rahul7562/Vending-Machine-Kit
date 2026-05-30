`timescale 1ns / 1ps

module vending_machine_boolean (
    input  wire clk,
    input  wire [6:0] sw,
    input  wire btn0,          // BTN0 = reset (active low on board)
    input  wire btn3,          // BTN3 = cancel (active low on board)
    output wire [3:0] led,
    output wire [2:0] led_rgb,
    output reg  [7:0] D0_SEG,
    output reg  [3:0] D0_AN,
    output reg  [7:0] D1_SEG,
    output reg  [3:0] D1_AN
);

    wire rst = ~btn0;
    wire cancel = btn3;

    wire dispense_water, dispense_coffee, dispense_softdrink, dispense_chips;
    wire [7:0] change_out, current_balance;
    wire cancel_out;
    wire [2:0] state_out;

    vending_machine_core core_inst (
        .clk(clk), .rst(rst),
        .coin_5(sw[0]), .coin_10(sw[1]), .coin_20(sw[2]),
        .select_water(sw[3]), .select_coffee(sw[4]),
        .select_softdrink(sw[5]), .select_chips(sw[6]),
        .cancel(cancel),
        .dispense_water(dispense_water), .dispense_coffee(dispense_coffee),
        .dispense_softdrink(dispense_softdrink), .dispense_chips(dispense_chips),
        .change_out(change_out), .current_balance(current_balance),
        .cancel_out(cancel_out), .state_out(state_out)
    );

    // Sticky LED latch
    reg [3:0] led_reg;
    always @(posedge clk) begin
        if (rst || cancel_out)
            led_reg <= 4'b0000;
        else begin
            if (dispense_water)     led_reg[0] <= 1'b1;
            if (dispense_coffee)    led_reg[1] <= 1'b1;
            if (dispense_softdrink) led_reg[2] <= 1'b1;
            if (dispense_chips)     led_reg[3] <= 1'b1;
        end
    end
    assign led = led_reg;

    // RGB LED (active HIGH): Blue=IDLE, Green=DISPENSE/CHANGE, Red=CHECK
    assign led_rgb[0] = (state_out == 3'd0);
    assign led_rgb[1] = (state_out == 3'd2 || state_out == 3'd3);
    assign led_rgb[2] = (state_out == 3'd1);

    // 7-Segment display multiplexer
    reg [15:0] clk_div;
    always @(posedge clk) clk_div <= clk_div + 1;

    wire [3:0] digit0 = current_balance % 10;
    wire [3:0] digit1 = (current_balance / 10) % 10;

    // Segment lookup: active low, common anode
    // Bit 7=DP, Bit 6=g, Bit 5=f, Bit 4=e, Bit 3=d, Bit 2=c, Bit 1=b, Bit 0=a
    function [7:0] seg;
        input [3:0] d;
        case (d)
            4'd0: seg = 8'hC0; // abcdef ON, g OFF
            4'd1: seg = 8'hF9; // bc ON
            4'd2: seg = 8'hA4; // abdeg ON
            4'd3: seg = 8'hB0; // abcdg ON
            4'd4: seg = 8'h99; // bcfg ON
            4'd5: seg = 8'h92; // acdfg ON
            4'd6: seg = 8'h82; // acdefg ON
            4'd7: seg = 8'hF8; // abc ON
            4'd8: seg = 8'h80; // all ON
            4'd9: seg = 8'h90; // abcdfg ON
            default: seg = 8'hFF; // blank
        endcase
    endfunction

    always @(*) begin
        if (clk_div[15] == 1'b0) begin
            D0_SEG = seg(digit0);
            D0_AN  = 4'b1110;
            D1_SEG = 8'hFF;
            D1_AN  = 4'b1111;
        end else begin
            D0_SEG = 8'hFF;
            D0_AN  = 4'b1111;
            D1_SEG = seg(digit1);
            D1_AN  = 4'b1110;
        end
    end

endmodule
