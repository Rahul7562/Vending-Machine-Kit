`timescale 1ns / 1ps

module vending_machine_boolean (
    input  wire clk,
    input  wire [6:0] sw,     // Switches for coins and selections
    input  wire [3:0] btn,    // Buttons (BTN0=rst, BTN3=cancel; BTN1,BTN2=unused)
    output wire [3:0] led,    // LEDs for dispense indicators
    output wire [7:0] seg,    // Seven Segment Data (active low, bit 7=DP)
    output wire [3:0] an      // Seven Segment Anode (active low)
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

    // 7-Segment Display (Multiplexed) — shows current_balance
    reg [15:0] clk_div;
    always @(posedge clk) clk_div <= clk_div + 1;

    wire [3:0] digit0 = current_balance % 10;
    wire [3:0] digit1 = (current_balance / 10) % 10;

    reg [3:0] current_digit;
    reg [3:0] an_reg;

    always @(*) begin
        case (clk_div[15])
            1'b0: begin current_digit = digit0; an_reg = 4'b1110; end
            1'b1: begin current_digit = digit1; an_reg = 4'b1101; end
        endcase
    end

    assign an = an_reg;

    // 7-segment encoding (active low, common anode)
    reg [6:0] seg_reg;
    always @(*) begin
        case (current_digit)
            4'd0: seg_reg = 7'b1000000;
            4'd1: seg_reg = 7'b1111001;
            4'd2: seg_reg = 7'b0100100;
            4'd3: seg_reg = 7'b0110000;
            4'd4: seg_reg = 7'b0011001;
            4'd5: seg_reg = 7'b0010010;
            4'd6: seg_reg = 7'b0000010;
            4'd7: seg_reg = 7'b1111000;
            4'd8: seg_reg = 7'b0000000;
            4'd9: seg_reg = 7'b0010000;
            default: seg_reg = 7'b1111111;
        endcase
    end

    assign seg = {1'b1, seg_reg}; // DP off (bit 7 = 1), segments active low

endmodule
