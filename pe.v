
module PE (
    input clk,
    input rst_n,
    input in_valid,
    input signed [31:0] x_init,
    input signed [31:0] x_n,     // Q8.24
    input signed [31:0] Tn,      // Q8.24
    input signed [31:0] acc_in,  // Q8.24
    output reg signed [31:0] acc_out,
    output reg signed [31:0] x_n1, // x^(n+1)
    output reg out_valid
);
    logic signed [63:0] mult1;
    logic signed [63:0] mult2;
    logic in_valid1;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_out <= 0;
            x_n1 <= 0;
            out_valid <= 0;
        end else if (in_valid1) begin
            mult1 = x_n * Tn;
            mult2 = x_n * x_init;
            acc_out <= acc_in + (mult1 >>> 24);
            x_n1 <= mult2 >>> 24;
            out_valid <= 1;
            in_valid1 <= 0;
        end
    end
    always @(posedge clk) begin
        if (in_valid) begin
            in_valid1 <= 1;
        end 
    end
    always @(posedge clk) begin
        if (out_valid) begin
            out_valid <= 0;
        end
    end
endmodule
