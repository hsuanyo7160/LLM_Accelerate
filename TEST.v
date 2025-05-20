`include "array.v"

module testbench;
    reg clk = 0;
    reg rst_n;
    reg in_valid;
    logic signed [15:0] x_in; // Q4.12
    logic signed [63:0] y_out; // Q8.24
    logic out_valid;

    PE_Array dut(clk, rst_n, in_valid, x_in, y_out, out_valid);

    always #10 clk = ~clk;

    // 檔案相關變數
    integer infile;
    integer status;
    integer value;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);

        rst_n = 0;
        in_valid = 0;
        x_in = 0;

        #20 rst_n = 1;

        // 開啟輸入檔案
        infile = $fopen("input.txt", "r");
        if (infile == 0) begin
            $display("Failed to open input.txt");
            $finish;
        end

        // 讀檔並輸入資料
        while (!$feof(infile)) begin
            status = $fscanf(infile, "%d\n", value);  // 讀一行
            @(posedge clk);         // 對齊 clock
            x_in = value[15:0];     // 賦值
            in_valid = 1;
            @(posedge clk);         // 維持 1 cycle
            in_valid = 0;

            wait(out_valid);        // 等待結果
            $display("x_in = %d exp(%.2f) -> %f",
                     x_in, $itor(x_in) / (1 << 12), $itor(y_out) / (1 << 24));
        end

        $fclose(infile);
        #20 $finish;
    end
endmodule
