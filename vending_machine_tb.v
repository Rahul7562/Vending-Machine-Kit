`timescale 1ns / 1ps

module vending_machine_tb;

    reg clk;
    reg rst;
    reg coin_5, coin_10, coin_20;
    reg sel_water, sel_coffee, sel_softdrink, sel_chips;
    reg cancel;

    wire disp_water, disp_coffee, disp_softdrink, disp_chips;
    wire [7:0] change;
    wire [7:0] balance;
    wire cancel_out;
    wire [2:0] state_out;

    vending_machine_core uut (
        .clk(clk),
        .rst(rst),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .coin_20(coin_20),
        .select_water(sel_water),
        .select_coffee(sel_coffee),
        .select_softdrink(sel_softdrink),
        .select_chips(sel_chips),
        .cancel(cancel),
        .dispense_water(disp_water),
        .dispense_coffee(disp_coffee),
        .dispense_softdrink(disp_softdrink),
        .dispense_chips(disp_chips),
        .change_out(change),
        .current_balance(balance),
        .cancel_out(cancel_out),
        .state_out(state_out)
    );

    always #5 clk = ~clk;

    task pulse_signal;
        input integer sig_idx;
        begin
            case (sig_idx)
                0: coin_5 = 1;
                1: coin_10 = 1;
                2: coin_20 = 1;
                3: sel_water = 1;
                4: sel_coffee = 1;
                5: sel_softdrink = 1;
                6: sel_chips = 1;
                7: cancel = 1;
            endcase
            #10;
            coin_5 = 0; coin_10 = 0; coin_20 = 0;
            sel_water = 0; sel_coffee = 0; sel_softdrink = 0; sel_chips = 0; cancel = 0;
            #30;
        end
    endtask
    
    reg passed;
    reg disp_w, disp_c, disp_s, disp_ch;
    reg [7:0] change_captured;

    always @(posedge clk) begin
        if (disp_water) disp_w <= 1;
        if (disp_coffee) disp_c <= 1;
        if (disp_softdrink) disp_s <= 1;
        if (disp_chips) disp_ch <= 1;
        if (change > 0) change_captured <= change;
    end
    
    task clear_captures;
        begin
            disp_w = 0;
            disp_c = 0;
            disp_s = 0;
            disp_ch = 0;
            change_captured = 0;
        end
    endtask

    initial begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);
        
        clk = 0; rst = 1;
        coin_5 = 0; coin_10 = 0; coin_20 = 0;
        sel_water = 0; sel_coffee = 0; sel_softdrink = 0; sel_chips = 0; cancel = 0;
        clear_captures();
        
        #20 rst = 0; #20;

        $display("========================================");
        $display("Starting Vending Machine Testbench");
        $display("========================================");

        // Case 1: Insert 10, Buy Water (10)
        $display("Test Case 1: Insert 10, Buy Water");
        pulse_signal(1); pulse_signal(3);
        #30;
        if (disp_w && change_captured == 0) $display("PASS: Case 1"); else $display("FAIL: Case 1");
        clear_captures();

        // Case 2: Insert 5 + 10, Buy Coffee (15)
        $display("Test Case 2: Insert 5 + 10, Buy Coffee");
        pulse_signal(0); pulse_signal(1); pulse_signal(4);
        #30;
        if (disp_c && change_captured == 0) $display("PASS: Case 2"); else $display("FAIL: Case 2");
        clear_captures();

        // Case 3: Insert 20, Buy Soft Drink (20)
        $display("Test Case 3: Insert 20, Buy Soft Drink");
        pulse_signal(2); pulse_signal(5);
        #30;
        if (disp_s && change_captured == 0) $display("PASS: Case 3"); else $display("FAIL: Case 3");
        clear_captures();

        // Case 4: Insert 20 + 5, Buy Chips (25)
        $display("Test Case 4: Insert 20 + 5, Buy Chips");
        pulse_signal(2); pulse_signal(0); pulse_signal(6);
        #30;
        if (disp_ch && change_captured == 0) $display("PASS: Case 4"); else $display("FAIL: Case 4");
        clear_captures();

        // Case 5: Insufficient balance for Coffee
        $display("Test Case 5: Insufficient balance for Coffee");
        pulse_signal(1); pulse_signal(4);
        #30;
        if (!disp_c && balance == 10) $display("PASS: Case 5"); else $display("FAIL: Case 5");
        pulse_signal(7);
        clear_captures();

        // Case 6: Insufficient balance for Chips
        $display("Test Case 6: Insufficient balance for Chips");
        pulse_signal(2); pulse_signal(6);
        #30;
        if (!disp_ch && balance == 20) $display("PASS: Case 6"); else $display("FAIL: Case 6");
        pulse_signal(7);
        clear_captures();

        // Case 7: Overpayment and change return (Insert 20, Buy Water, Change = 10)
        $display("Test Case 7: Overpayment and change return");
        pulse_signal(2); pulse_signal(3);
        #30;
        if (disp_w && change_captured == 10) $display("PASS: Case 7"); else $display("FAIL: Case 7");
        clear_captures();

        // Case 8: Multiple coin insertions (5+5+5+5 = 20)
        $display("Test Case 8: Multiple coin insertions");
        pulse_signal(0); pulse_signal(0); pulse_signal(0); pulse_signal(0);
        pulse_signal(5);
        #30;
        if (disp_s) $display("PASS: Case 8"); else $display("FAIL: Case 8");
        clear_captures();

        // Case 9: Reset during operation
        $display("Test Case 9: Reset during operation");
        pulse_signal(1);
        rst = 1; #20; rst = 0; #20;
        if (balance == 0) $display("PASS: Case 9"); else $display("FAIL: Case 9");
        clear_captures();

        // Case 10: Back-to-back purchases
        $display("Test Case 10: Back-to-back purchases");
        pulse_signal(2); pulse_signal(2);
        pulse_signal(3);
        #30;
        if (disp_w && change_captured == 30) $display("PASS: Case 10a"); else $display("FAIL: Case 10a");
        clear_captures();

        pulse_signal(2); pulse_signal(0);
        pulse_signal(6);
        #30;
        if (disp_ch) $display("PASS: Case 10b"); else $display("FAIL: Case 10b");
        clear_captures();

        $display("========================================");
        $display("All tests completed.");
        $display("========================================");
        $finish;
    end

endmodule
