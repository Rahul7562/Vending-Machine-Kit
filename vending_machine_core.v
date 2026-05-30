`timescale 1ns / 1ps

module vending_machine_core (
    input  wire clk,
    input  wire rst,
    input  wire coin_5,
    input  wire coin_10,
    input  wire coin_20,
    input  wire select_water,
    input  wire select_coffee,
    input  wire select_softdrink,
    input  wire select_chips,
    input  wire cancel,
    output reg  dispense_water,
    output reg  dispense_coffee,
    output reg  dispense_softdrink,
    output reg  dispense_chips,
    output reg  [7:0] change_out,
    output reg  [7:0] current_balance,
    output reg  cancel_out,
    output wire [2:0] state_out
);

    localparam PRICE_WATER      = 8'd10;
    localparam PRICE_COFFEE     = 8'd15;
    localparam PRICE_SOFTDRINK  = 8'd20;
    localparam PRICE_CHIPS      = 8'd25;

    localparam S_IDLE          = 3'd0;
    localparam S_CHECK         = 3'd1;
    localparam S_DISPENSE      = 3'd2;
    localparam S_RETURN_CHANGE = 3'd3;

    reg [2:0] state;
    reg [7:0] price_to_check;
    reg [3:0] product_selected; 

    reg coin_5_d, coin_10_d, coin_20_d;
    reg sel_water_d, sel_coffee_d, sel_softdrink_d, sel_chips_d, cancel_d;
    
    wire coin_5_p = coin_5 && !coin_5_d;
    wire coin_10_p = coin_10 && !coin_10_d;
    wire coin_20_p = coin_20 && !coin_20_d;
    wire sel_water_p = select_water && !sel_water_d;
    wire sel_coffee_p = select_coffee && !sel_coffee_d;
    wire sel_softdrink_p = select_softdrink && !sel_softdrink_d;
    wire sel_chips_p = select_chips && !sel_chips_d;
    wire cancel_p = cancel && !cancel_d;

    assign state_out = state;

    always @(posedge clk) begin
        if (rst) begin
            coin_5_d <= 1'b0;
            coin_10_d <= 1'b0;
            coin_20_d <= 1'b0;
            sel_water_d <= 1'b0;
            sel_coffee_d <= 1'b0;
            sel_softdrink_d <= 1'b0;
            sel_chips_d <= 1'b0;
            cancel_d <= 1'b0;
        end else begin
            coin_5_d <= coin_5;
            coin_10_d <= coin_10;
            coin_20_d <= coin_20;
            sel_water_d <= select_water;
            sel_coffee_d <= select_coffee;
            sel_softdrink_d <= select_softdrink;
            sel_chips_d <= select_chips;
            cancel_d <= cancel;
        end
    end

    // Use a single procedural block to make pulse handling reliable
    always @(posedge clk) begin
        if (rst) begin
            state              <= S_IDLE;
            current_balance    <= 8'd0;
            dispense_water     <= 1'b0;
            dispense_coffee    <= 1'b0;
            dispense_softdrink <= 1'b0;
            dispense_chips     <= 1'b0;
            change_out         <= 8'd0;
            cancel_out         <= 1'b0;
            price_to_check     <= 8'd0;
            product_selected   <= 4'd0;
        end else begin
            // Clear pulses if not in the state that sets them
            dispense_water     <= 1'b0;
            dispense_coffee    <= 1'b0;
            dispense_softdrink <= 1'b0;
            dispense_chips     <= 1'b0;
            change_out         <= 8'd0;
            cancel_out         <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (coin_5_p)       current_balance <= current_balance + 8'd5;
                    else if (coin_10_p) current_balance <= current_balance + 8'd10;
                    else if (coin_20_p) current_balance <= current_balance + 8'd20;
                    
                    else if (sel_water_p) begin
                        price_to_check   <= PRICE_WATER;
                        product_selected <= 4'b0001;
                        state            <= S_CHECK;
                    end
                    else if (sel_coffee_p) begin
                        price_to_check   <= PRICE_COFFEE;
                        product_selected <= 4'b0010;
                        state            <= S_CHECK;
                    end
                    else if (sel_softdrink_p) begin
                        price_to_check   <= PRICE_SOFTDRINK;
                        product_selected <= 4'b0100;
                        state            <= S_CHECK;
                    end
                    else if (sel_chips_p) begin
                        price_to_check   <= PRICE_CHIPS;
                        product_selected <= 4'b1000;
                        state            <= S_CHECK;
                    end
                    else if (cancel_p && current_balance > 0) begin
                        state      <= S_RETURN_CHANGE;
                    end
                end

                S_CHECK: begin
                    if (current_balance >= price_to_check) begin
                        state           <= S_DISPENSE;
                        current_balance <= current_balance - price_to_check;
                    end else begin
                        state <= S_IDLE;
                    end
                end

                S_DISPENSE: begin
                    if (product_selected[0]) dispense_water     <= 1'b1;
                    if (product_selected[1]) dispense_coffee    <= 1'b1;
                    if (product_selected[2]) dispense_softdrink <= 1'b1;
                    if (product_selected[3]) dispense_chips     <= 1'b1;

                    if (current_balance > 0) begin
                        state <= S_RETURN_CHANGE;
                    end else begin
                        state <= S_IDLE;
                    end
                end

                S_RETURN_CHANGE: begin
                    change_out      <= current_balance;
                    if (cancel_p || cancel_d) cancel_out <= 1'b1; // if it was triggered by a cancel
                    current_balance <= 8'd0;
                    state           <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
