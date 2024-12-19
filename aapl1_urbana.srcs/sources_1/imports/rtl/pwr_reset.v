
module pwr_reset(
    input clk25,        // 25Mhz master clock
    input rst_n,        // active low synchronous reset
    input enable,       // clock enable
    output rst          // active high synchronous system reset
    );

    reg hard_reset;
    reg [5:0] reset_cnt;
    wire pwr_up_flag = &reset_cnt;

    always @(posedge clk25)
    begin
        if (rst_n == 1'b0)
        begin
            reset_cnt  <= 6'b0;
            hard_reset <= 1'b0;
        end
        else if (enable)
        begin
            if (!pwr_up_flag)
                reset_cnt <= reset_cnt + 6'b1;

            hard_reset <= pwr_up_flag;
        end
    end

    assign rst = ~hard_reset;

endmodule
