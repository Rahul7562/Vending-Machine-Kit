`timescale 1ns / 1ps

module vending_machine_tb;

    // Top-level friendly signals
    reg clk, rst;
    
    // Inputs: what the user does
    reg insert_5, insert_10, insert_20;
    reg buy_water, buy_coffee, buy_softdrink, buy_chips;
    reg press_cancel;
    
    // Outputs: what the user sees
    wire [7:0] balance;
    wire [7:0] change_returned;
    wire water_ready;
    wire coffee_ready;
    wire softdrink_ready;
    wire chips_ready;
    wire [2:0] state;

    vending_machine_core uut(
        .clk(clk), .rst(rst),
        .coin_5(insert_5), .coin_10(insert_10), .coin_20(insert_20),
        .select_water(buy_water), .select_coffee(buy_coffee),
        .select_softdrink(buy_softdrink), .select_chips(buy_chips),
        .cancel(press_cancel),
        .dispense_water(water_ready), .dispense_coffee(coffee_ready),
        .dispense_softdrink(softdrink_ready), .dispense_chips(chips_ready),
        .change_out(change_returned), .current_balance(balance),
        .cancel_out(), .state_out(state)
    );

    always #5 clk = ~clk;

    // Sticky captures
    reg got_water, got_coffee, got_softdrink, got_chips;
    reg [7:0] last_change;

    always @(posedge clk) begin
        if (water_ready)     got_water <= 1;
        if (coffee_ready)    got_coffee <= 1;
        if (softdrink_ready) got_softdrink <= 1;
        if (chips_ready)     got_chips <= 1;
        if (change_returned > last_change) last_change <= change_returned;
    end

    task reset_caps;
        begin got_water=0; got_coffee=0; got_softdrink=0; got_chips=0; last_change=0; end
    endtask

    // Pulse tasks (split for Icarus NBA compat)
    task pulse_insert_5;    begin @(negedge clk); insert_5=1;    @(negedge clk); insert_5=0;    #1; end endtask
    task pulse_insert_10;   begin @(negedge clk); insert_10=1;   @(negedge clk); insert_10=0;   #1; end endtask
    task pulse_insert_20;   begin @(negedge clk); insert_20=1;   @(negedge clk); insert_20=0;   #1; end endtask
    task pulse_buy_water;   begin @(negedge clk); buy_water=1;   @(negedge clk); buy_water=0;   #1; end endtask
    task pulse_buy_coffee;  begin @(negedge clk); buy_coffee=1;  @(negedge clk); buy_coffee=0;  #1; end endtask
    task pulse_buy_soft;    begin @(negedge clk); buy_softdrink=1; @(negedge clk); buy_softdrink=0; #1; end endtask
    task pulse_buy_chips;   begin @(negedge clk); buy_chips=1;   @(negedge clk); buy_chips=0;   #1; end endtask
    task pulse_cancel;      begin @(negedge clk); press_cancel=1; @(negedge clk); press_cancel=0; #1; end endtask

    task wait_idle;
        input integer cycles;
        begin repeat(cycles) @(posedge clk); end
    endtask

    initial begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);

        clk=0; rst=1;
        insert_5=0; insert_10=0; insert_20=0;
        buy_water=0; buy_coffee=0; buy_softdrink=0; buy_chips=0;
        press_cancel=0;
        reset_caps();

        repeat(4) @(posedge clk);
        @(negedge clk); rst=0;
        repeat(4) @(posedge clk);

        $display("");
        $display("====== VENDING MACHINE TESTS ======");
        $display("");

        // T1: Insert 10, Buy Water (exact)
        $display("[T1] Insert 10 | Buy Water");
        pulse_insert_10; pulse_buy_water; wait_idle(12);
        $display("      bal=%0d | change=%0d | water=%d | %s", balance, last_change, got_water, (got_water && last_change==0) ? "PASS" : "FAIL");
        reset_caps();

        // T2: Insert 5+10, Buy Coffee (exact)
        $display("[T2] Insert 5+10 | Buy Coffee");
        pulse_insert_5; pulse_insert_10; pulse_buy_coffee; wait_idle(12);
        $display("      bal=%0d | change=%0d | coffee=%d | %s", balance, last_change, got_coffee, (got_coffee && last_change==0) ? "PASS" : "FAIL");
        reset_caps();

        // T3: Insert 20, Buy Soft Drink (exact)
        $display("[T3] Insert 20 | Buy Soft Drink");
        pulse_insert_20; pulse_buy_soft; wait_idle(12);
        $display("      bal=%0d | change=%0d | softdrink=%d | %s", balance, last_change, got_softdrink, (got_softdrink && last_change==0) ? "PASS" : "FAIL");
        reset_caps();

        // T4: Insert 20+5, Buy Chips (exact)
        $display("[T4] Insert 20+5 | Buy Chips");
        pulse_insert_20; pulse_insert_5; pulse_buy_chips; wait_idle(12);
        $display("      bal=%0d | change=%0d | chips=%d | %s", balance, last_change, got_chips, (got_chips && last_change==0) ? "PASS" : "FAIL");
        reset_caps();

        // T5: Insert 10, Buy Coffee (REJECT - not enough)
        $display("[T5] Insert 10 | Buy Coffee (REJECT)");
        pulse_insert_10; pulse_buy_coffee; wait_idle(12);
        $display("      bal=%0d | change=%0d | coffee=%d | %s", balance, last_change, got_coffee, (!got_coffee && balance==10) ? "PASS" : "FAIL");
        pulse_cancel; wait_idle(8); reset_caps();

        // T6: Insert 20, Buy Chips (REJECT - not enough)
        $display("[T6] Insert 20 | Buy Chips (REJECT)");
        pulse_insert_20; pulse_buy_chips; wait_idle(12);
        $display("      bal=%0d | change=%0d | chips=%d | %s", balance, last_change, got_chips, (!got_chips && balance==20) ? "PASS" : "FAIL");
        pulse_cancel; wait_idle(8); reset_caps();

        // T7: Insert 20, Buy Water (OVERPAY - change=10)
        $display("[T7] Insert 20 | Buy Water (change=10)");
        pulse_insert_20; pulse_buy_water; wait_idle(12);
        $display("      bal=%0d | change=%0d | water=%d | %s", balance, last_change, got_water, (got_water && last_change==10) ? "PASS" : "FAIL");
        reset_caps();

        // T8: Insert 5x4=20, Buy Soft Drink
        $display("[T8] Insert 5x4 | Buy Soft Drink");
        pulse_insert_5; pulse_insert_5; pulse_insert_5; pulse_insert_5;
        wait_idle(4); pulse_buy_soft; wait_idle(12);
        $display("      bal=%0d | change=%0d | softdrink=%d | %s", balance, last_change, got_softdrink, (got_softdrink && balance==0) ? "PASS" : "FAIL");
        reset_caps();

        // T9: Reset mid-transaction
        $display("[T9] Insert 10 | RESET");
        pulse_insert_10; wait_idle(4);
        @(negedge clk); rst=1;
        repeat(4) @(posedge clk);
        @(negedge clk); rst=0;
        repeat(4) @(posedge clk);
        $display("      bal=%0d | %s", balance, (balance==0) ? "PASS" : "FAIL");
        reset_caps();

        // T10: Cancel returns change
        $display("[T10] Insert 5+10 | CANCEL");
        pulse_insert_5; pulse_insert_10; wait_idle(4);
        pulse_cancel; wait_idle(12);
        $display("      bal=%0d | change=%0d | %s", balance, last_change, (last_change==15 && balance==0) ? "PASS" : "FAIL");
        reset_caps();

        // T11: Back-to-back
        $display("[T11] Insert 40 | Buy Water | re-insert 25 | Buy Chips");
        pulse_insert_20; pulse_insert_20; wait_idle(4);
        pulse_buy_water; wait_idle(12);
        $display("      Part A: bal=%0d | change=%0d | water=%d | %s", balance, last_change, got_water, (got_water && last_change==30) ? "PASS" : "FAIL");
        reset_caps();
        pulse_insert_20; pulse_insert_5; wait_idle(4);
        pulse_buy_chips; wait_idle(12);
        $display("      Part B: bal=%0d | change=%0d | chips=%d | %s", balance, last_change, got_chips, (got_chips && last_change==0) ? "PASS" : "FAIL");
        reset_caps();

        $display("");
        $display("====== ALL TESTS COMPLETE ======");
        $display("");
        $finish;
    end

endmodule
