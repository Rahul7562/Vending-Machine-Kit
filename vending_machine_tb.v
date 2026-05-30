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
        .clk(clk), .rst(rst),
        .coin_5(coin_5), .coin_10(coin_10), .coin_20(coin_20),
        .select_water(sel_water), .select_coffee(sel_coffee),
        .select_softdrink(sel_softdrink), .select_chips(sel_chips),
        .cancel(cancel),
        .dispense_water(disp_water), .dispense_coffee(disp_coffee),
        .dispense_softdrink(disp_softdrink), .dispense_chips(disp_chips),
        .change_out(change), .current_balance(balance),
        .cancel_out(cancel_out), .state_out(state_out)
    );

    always #5 clk = ~clk;

    // REAL-TIME MONITOR
    reg [2:0] prev_state;
    always @(posedge clk) begin
        if (state_out != prev_state) begin
            case (state_out)
                3'd0: $display("[T=%0t] >> IDLE       bal=%0d chg=%0d", $time, balance, change);
                3'd1: $display("[T=%0t] >> CHECK      bal=%0d price=%0d",
                               $time, balance, uut.price_to_check);
                3'd2: $display("[T=%0t] >> DISPENSE   bal=%0d prod=%4b",
                               $time, balance, uut.product_selected);
                3'd3: $display("[T=%0t] >> RET_CHANGE bal=%0d chg=%0d cancel=%b",
                               $time, balance, change, cancel_out);
            endcase
        end
        if (disp_water)     $display("[T=%0t] ** WATER dispensed", $time);
        if (disp_coffee)    $display("[T=%0t] ** COFFEE dispensed", $time);
        if (disp_softdrink) $display("[T=%0t] ** SOFTDRINK dispensed", $time);
        if (disp_chips)     $display("[T=%0t] ** CHIPS dispensed", $time);
        prev_state <= state_out;
    end

    // STICKY CAPTURE
    reg cap_w, cap_c, cap_s, cap_ch;
    reg [7:0] cap_change;
    reg cap_cancel;

    always @(posedge clk) begin
        if (disp_water)     cap_w <= 1;
        if (disp_coffee)    cap_c <= 1;
        if (disp_softdrink) cap_s <= 1;
        if (disp_chips)     cap_ch <= 1;
        if (change > 0)     cap_change <= change;
        if (cancel_out)     cap_cancel <= 1;
    end

    task clear_caps;
        begin
            cap_w = 0; cap_c = 0; cap_s = 0; cap_ch = 0;
            cap_change = 0; cap_cancel = 0;
        end
    endtask

    // PULSE TASKS (one per signal — works around Icarus Verilog case+NBA scheduling bug)
    task pulse_coin5;
        begin
            @(negedge clk); coin_5 = 1;
            @(negedge clk); coin_5 = 0;
            #1;
        end
    endtask

    task pulse_coin10;
        begin
            @(negedge clk); coin_10 = 1;
            @(negedge clk); coin_10 = 0;
            #1;
        end
    endtask

    task pulse_coin20;
        begin
            @(negedge clk); coin_20 = 1;
            @(negedge clk); coin_20 = 0;
            #1;
        end
    endtask

    task pulse_water;
        begin
            @(negedge clk); sel_water = 1;
            @(negedge clk); sel_water = 0;
            #1;
        end
    endtask

    task pulse_coffee;
        begin
            @(negedge clk); sel_coffee = 1;
            @(negedge clk); sel_coffee = 0;
            #1;
        end
    endtask

    task pulse_softdrink;
        begin
            @(negedge clk); sel_softdrink = 1;
            @(negedge clk); sel_softdrink = 0;
            #1;
        end
    endtask

    task pulse_chips;
        begin
            @(negedge clk); sel_chips = 1;
            @(negedge clk); sel_chips = 0;
            #1;
        end
    endtask

    task pulse_cancel;
        begin
            @(negedge clk); cancel = 1;
            @(negedge clk); cancel = 0;
            #1;
        end
    endtask

    task wait_idle;
        input integer cycles;
        begin
            repeat(cycles) @(posedge clk);
        end
    endtask

    integer pass_count;
    integer total;

    initial begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);

        clk = 0; rst = 1;
        coin_5 = 0; coin_10 = 0; coin_20 = 0;
        sel_water = 0; sel_coffee = 0; sel_softdrink = 0; sel_chips = 0; cancel = 0;
        clear_caps();
        prev_state = 3'd0;

        repeat(4) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat(4) @(posedge clk);

        $display("");
        $display("============================================================");
        $display("  VENDING MACHINE TESTBENCH v2.2");
        $display("============================================================");
        pass_count = 0;
        total = 0;

        $display("--- TEST 1: Insert 10, Buy Water ---");
        pulse_coin10; pulse_water; wait_idle(15);
        total = total + 1;
        if (cap_w && cap_change == 0 && balance == 0)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: cap_w=%b change=%0d bal=%0d", cap_w, cap_change, balance);
        clear_caps();

        $display("--- TEST 2: Insert 5+10, Buy Coffee ---");
        pulse_coin5; pulse_coin10; pulse_coffee; wait_idle(15);
        total = total + 1;
        if (cap_c && cap_change == 0 && balance == 0)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: cap_c=%b change=%0d bal=%0d", cap_c, cap_change, balance);
        clear_caps();

        $display("--- TEST 3: Insert 20, Buy Soft Drink ---");
        pulse_coin20; pulse_softdrink; wait_idle(15);
        total = total + 1;
        if (cap_s && cap_change == 0)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: cap_s=%b change=%0d", cap_s, cap_change);
        clear_caps();

        $display("--- TEST 4: Insert 20+5, Buy Chips ---");
        pulse_coin20; pulse_coin5; pulse_chips; wait_idle(15);
        total = total + 1;
        if (cap_ch && cap_change == 0)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: cap_ch=%b change=%0d", cap_ch, cap_change);
        clear_caps();

        $display("--- TEST 5: Insufficient 10<15 for Coffee ---");
        pulse_coin10; pulse_coffee; wait_idle(15);
        total = total + 1;
        if (!cap_c && balance == 10)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: cap_c=%b bal=%0d", cap_c, balance);
        pulse_cancel; wait_idle(10);
        clear_caps();

        $display("--- TEST 6: Insufficient 20<25 for Chips ---");
        pulse_coin20; pulse_chips; wait_idle(15);
        total = total + 1;
        if (!cap_ch && balance == 20)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: cap_ch=%b bal=%0d", cap_ch, balance);
        pulse_cancel; wait_idle(10);
        clear_caps();

        $display("--- TEST 7: Overpay 20, Buy Water (change=10) ---");
        pulse_coin20; pulse_water; wait_idle(15);
        total = total + 1;
        if (cap_w && cap_change == 10 && balance == 0)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: cap_w=%b change=%0d bal=%0d", cap_w, cap_change, balance);
        clear_caps();

        $display("--- TEST 8: 5x4=20, Buy Soft Drink ---");
        pulse_coin5; pulse_coin5; pulse_coin5; pulse_coin5;
        wait_idle(4); pulse_softdrink; wait_idle(15);
        total = total + 1;
        if (cap_s && balance == 0)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: cap_s=%b bal=%0d", cap_s, balance);
        clear_caps();

        $display("--- TEST 9: Reset during operation ---");
        pulse_coin10; wait_idle(4);
        @(negedge clk); rst = 1;
        repeat(4) @(posedge clk);
        @(negedge clk); rst = 0;
        repeat(4) @(posedge clk);
        total = total + 1;
        if (balance == 0)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: bal=%0d", balance);
        clear_caps();

        $display("--- TEST 10: Cancel returns 15 ---");
        pulse_coin5; pulse_coin10; wait_idle(4);
        pulse_cancel; wait_idle(15);
        total = total + 1;
        if (cap_change == 15 && cap_cancel)
            begin $display("PASS"); pass_count = pass_count + 1; end
        else $display("FAIL: change=%0d cancel=%b", cap_change, cap_cancel);
        clear_caps();

        $display("--- TEST 11: Back-to-back purchases ---");
        pulse_coin20; pulse_coin20; wait_idle(4);
        pulse_water; wait_idle(15);
        total = total + 1;
        if (cap_w && cap_change == 30)
            begin $display("PASS(a)"); pass_count = pass_count + 1; end
        else $display("FAIL(a): cap_w=%b change=%0d bal=%0d", cap_w, cap_change, balance);
        clear_caps();
        pulse_coin20; pulse_coin5; wait_idle(4);
        pulse_chips; wait_idle(15);
        total = total + 1;
        if (cap_ch && cap_change == 0)
            begin $display("PASS(b)"); pass_count = pass_count + 1; end
        else $display("FAIL(b): cap_ch=%b change=%0d", cap_ch, cap_change);
        clear_caps();

        $display("");
        $display("============================================================");
        $display("  RESULTS: %0d / %0d PASSED", pass_count, total);
        $display("============================================================");
        $finish;
    end

endmodule
