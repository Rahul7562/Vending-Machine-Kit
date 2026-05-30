`timescale 1ns / 1ps

module vending_machine_tb;

    reg clk, rst;
    reg coin_5, coin_10, coin_20;
    reg sel_water, sel_coffee, sel_softdrink, sel_chips, cancel;
    wire dw, dc, ds, dch;
    wire [7:0] change;
    wire [7:0] balance;
    wire cancel_out;
    wire [2:0] state_out;

    vending_machine_core uut(
        .clk(clk), .rst(rst),
        .coin_5(coin_5), .coin_10(coin_10), .coin_20(coin_20),
        .select_water(sel_water), .select_coffee(sel_coffee),
        .select_softdrink(sel_softdrink), .select_chips(sel_chips),
        .cancel(cancel),
        .dispense_water(dw), .dispense_coffee(dc),
        .dispense_softdrink(ds), .dispense_chips(dch),
        .change_out(change), .current_balance(balance),
        .cancel_out(cancel_out), .state_out(state_out)
    );

    always #5 clk = ~clk;

    // STICKY CAPTURES
    reg got_w, got_c, got_s, got_ch;
    reg [7:0] max_chg;
    reg got_cancel;

    always @(posedge clk) begin
        if (dw)          got_w <= 1;
        if (dc)          got_c <= 1;
        if (ds)          got_s <= 1;
        if (dch)         got_ch <= 1;
        if (change > max_chg) max_chg <= change;
        if (cancel_out)  got_cancel <= 1;
    end

    task caps_off;
        begin got_w=0; got_c=0; got_s=0; got_ch=0; max_chg=0; got_cancel=0; end
    endtask

    // PULSE TASKS (split per signal for Icarus NBA compat)
    task p5;  begin @(negedge clk); coin_5=1;  @(negedge clk); coin_5=0;  #1; end endtask
    task p10; begin @(negedge clk); coin_10=1; @(negedge clk); coin_10=0; #1; end endtask
    task p20; begin @(negedge clk); coin_20=1; @(negedge clk); coin_20=0; #1; end endtask
    task pw;  begin @(negedge clk); sel_water=1;     @(negedge clk); sel_water=0;     #1; end endtask
    task pcf; begin @(negedge clk); sel_coffee=1;    @(negedge clk); sel_coffee=0;    #1; end endtask
    task psd; begin @(negedge clk); sel_softdrink=1; @(negedge clk); sel_softdrink=0; #1; end endtask
    task pch; begin @(negedge clk); sel_chips=1;     @(negedge clk); sel_chips=0;     #1; end endtask
    task pcan;begin @(negedge clk); cancel=1;        @(negedge clk); cancel=0;        #1; end endtask

    task wait_n;
        input integer n;
        begin repeat(n) @(posedge clk); end
    endtask

    integer pass_count;

    initial begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);

        clk=0; rst=1; coin_5=0; coin_10=0; coin_20=0;
        sel_water=0; sel_coffee=0; sel_softdrink=0; sel_chips=0; cancel=0;
        caps_off();

        repeat(4) @(posedge clk);
        @(negedge clk); rst=0;
        repeat(4) @(posedge clk);

        pass_count = 0;

        // T1: Insert 10, Buy Water (exact)
        $display("T1:  Insert 10 | Buy Water");
        p10; pw; wait_n(12);
        if (got_w && max_chg==0 && balance==0) begin $display("      PASS"); pass_count=pass_count+1; end
        else $display("      FAIL  w=%b chg=%0d bal=%0d", got_w, max_chg, balance);
        caps_off();

        // T2: Insert 5+10, Buy Coffee (exact)
        $display("T2:  Insert 5+10 | Buy Coffee");
        p5; p10; pcf; wait_n(12);
        if (got_c && max_chg==0 && balance==0) begin $display("      PASS"); pass_count=pass_count+1; end
        else $display("      FAIL  c=%b chg=%0d bal=%0d", got_c, max_chg, balance);
        caps_off();

        // T3: Insert 20, Buy Soft Drink (exact)
        $display("T3:  Insert 20 | Buy Soft Drink");
        p20; psd; wait_n(12);
        if (got_s && max_chg==0) begin $display("      PASS"); pass_count=pass_count+1; end
        else $display("      FAIL  s=%b chg=%0d", got_s, max_chg);
        caps_off();

        // T4: Insert 20+5, Buy Chips (exact)
        $display("T4:  Insert 20+5 | Buy Chips");
        p20; p5; pch; wait_n(12);
        if (got_ch && max_chg==0) begin $display("      PASS"); pass_count=pass_count+1; end
        else $display("      FAIL  ch=%b chg=%0d", got_ch, max_chg);
        caps_off();

        // T5: Insufficient 10<15 for Coffee
        $display("T5:  Insert 10 | Buy Coffee  (REJECT 10<15)");
        p10; pcf; wait_n(12);
        if (!got_c && balance==10) begin $display("      PASS  (rejected, bal=%0d)", balance); pass_count=pass_count+1; end
        else $display("      FAIL  c=%b bal=%0d", got_c, balance);
        pcan; wait_n(8); caps_off();

        // T6: Insufficient 20<25 for Chips
        $display("T6:  Insert 20 | Buy Chips  (REJECT 20<25)");
        p20; pch; wait_n(12);
        if (!got_ch && balance==20) begin $display("      PASS  (rejected, bal=%0d)", balance); pass_count=pass_count+1; end
        else $display("      FAIL  ch=%b bal=%0d", got_ch, balance);
        pcan; wait_n(8); caps_off();

        // T7: Overpay - Insert 20, Buy Water (change=10)
        $display("T7:  Insert 20 | Buy Water  (CHANGE=10)");
        p20; pw; wait_n(12);
        if (got_w && max_chg==10 && balance==0) begin $display("      PASS  change=%0d", max_chg); pass_count=pass_count+1; end
        else $display("      FAIL  w=%b chg=%0d bal=%0d", got_w, max_chg, balance);
        caps_off();

        // T8: 5x4=20, Buy Soft Drink
        $display("T8:  Insert 5x4=20 | Buy Soft Drink");
        p5; p5; p5; p5; wait_n(4); psd; wait_n(12);
        if (got_s && balance==0) begin $display("      PASS"); pass_count=pass_count+1; end
        else $display("      FAIL  s=%b bal=%0d", got_s, balance);
        caps_off();

        // T9: Reset mid-transaction
        $display("T9:  Insert 10 | RESET");
        p10; wait_n(4);
        @(negedge clk); rst=1;
        repeat(4) @(posedge clk);
        @(negedge clk); rst=0;
        repeat(4) @(posedge clk);
        if (balance==0) begin $display("      PASS  (cleared)"); pass_count=pass_count+1; end
        else $display("      FAIL  bal=%0d", balance);
        caps_off();

        // T10: Cancel returns change (5+10=15)
        $display("T10: Insert 5+10 | CANCEL (change=15)");
        p5; p10; wait_n(4); pcan; wait_n(12);
        if (max_chg==15 && got_cancel) begin $display("      PASS  change=%0d", max_chg); pass_count=pass_count+1; end
        else $display("      FAIL  chg=%0d cancel=%b", max_chg, got_cancel);
        caps_off();

        // T11: Back-to-back
        $display("T11: Insert 40 | Buy Water(10) | x | Buy Chips(25)");
        p20; p20; wait_n(4); pw; wait_n(12);
        if (got_w && max_chg==30) begin $display("      PASS(a)  water change=%0d", max_chg); pass_count=pass_count+1; end
        else $display("      FAIL(a)  w=%b chg=%0d", got_w, max_chg);
        caps_off();
        p20; p5; wait_n(4); pch; wait_n(12);
        if (got_ch && max_chg==0) begin $display("      PASS(b)  chips"); pass_count=pass_count+1; end
        else $display("      FAIL(b)  ch=%b", got_ch);
        caps_off();

        $display("");
        $display("==================================");
        $display("  RESULTS: %0d / 12 PASSED", pass_count);
        $display("==================================");
        $display("");
        $finish;
    end

endmodule
