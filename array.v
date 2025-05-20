
`include "pe.v"

module PE_Array (
    input clk,
    input rst_n,
    input in_valid,
    input signed [15:0] x_in, // Q4.12
    output signed [63:0] y_out, // Q8.24
    output out_valid
);
    wire signed [3:0] x_int = x_in[15:12];                     // 整數部分
    wire signed [15:0] x_frac = {4'd0, x_in[11:0]};            // 小數部分，仍為 Q4.12
    wire signed [31:0] x_frac_ext = x_frac <<< 12;             // Q4.12 → Q8.24

    wire signed [31:0] T0 = 32'd16777216; // 1.0
    wire signed [31:0] T1 = 32'd16777216; // 1.0
    wire signed [31:0] T2 = 32'd8388608;  // 0.5
    wire signed [31:0] T3 = 32'd2796203;  // 1/6 ≈ 0.1666667
    wire signed [31:0] T4 = 32'd699051;   // 1/24 ≈ 0.0416667
    wire signed [31:0] T5 = 32'd139810;   // 1/120 ≈ 0.0083333
    wire signed [31:0] T6 = 32'd23268;    // 1/720 ≈ 0.0013889
    wire signed [31:0] T7 = 32'd3324;     // 1/5040 ≈ 0.0001984
    wire signed [31:0] T8 = 32'd416;      // 1/40320 ≈ 0.0000248

    wire [3:0] table_index;
    wire signed [31:0] exp_int;
    wire signed [31:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7;
    wire signed [31:0] x1, x2, x3, x4, x5, x6, x7, x8;
    logic vstart, v0, v1, v2, v3, v4, v5, v6, v7;

    PE pe0(clk, rst_n, in_valid, x_frac_ext,  32'd16777216,  T0,  32'd0, acc0, x1, v0);
    PE pe1(clk, rst_n,       v0, x_frac_ext,            x1,  T1,   acc0, acc1, x2, v1);
    PE pe2(clk, rst_n,       v1, x_frac_ext,            x2,  T2,   acc1, acc2, x3, v2);
    PE pe3(clk, rst_n,       v2, x_frac_ext,            x3,  T3,   acc2, acc3, x4, v3);
    PE pe4(clk, rst_n,       v3, x_frac_ext,            x4,  T4,   acc3, acc4, x5, v4);
    PE pe5(clk, rst_n,       v4, x_frac_ext,            x5,  T5,   acc4, acc5, x6, v5);
    PE pe6(clk, rst_n,       v5, x_frac_ext,            x6,  T6,   acc5, acc6, x7, v6);
    PE pe7(clk, rst_n,       v6, x_frac_ext,            x7,  T7,   acc6, acc7, x8, v7);

    // Lookup table for exp(x)
    reg signed [31:0] exp_table [0:8];
    initial begin
        exp_table[0] = 32'd4540260;   // e^-4 ≈ 0.0183
        exp_table[1] = 32'd12337974;  // e^-3 ≈ 0.0498
        exp_table[2] = 32'd33500749;  // e^-2 ≈ 0.1353
        exp_table[3] = 32'd9052064;   // e^-1 ≈ 0.3679
        exp_table[4] = 32'd16777216;  // e^0  = 1.0
        exp_table[5] = 32'd45505423;  // e^1  ≈ 2.71828
        exp_table[6] = 32'd123456790;// e^2  ≈ 7.38906
        exp_table[7] = 32'd335544320;// e^3  ≈ 20.0855
        exp_table[8] = 32'd906438115;// e^4  ≈ 54.5981
    end

    assign table_index = x_int + 4; // [-4,4] → [0,8]
    assign exp_int = exp_table[table_index];
    assign y_out = (acc7 * exp_int) >> 24; // Q8.24 * Q8.24 = Q16.48
    assign out_valid = v7;

endmodule
