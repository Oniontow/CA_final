module ALU (
    input           clk,
    input           rst_n,
    input           valid,
    input   [31:0]  in_A,
    input   [31:0]  in_B,
    input   [3:0]   mode,
    output  reg     ready,
    output  reg [63:0]  out_data
);
// ===============================================
//                    wire & reg
// ===============================================
reg [31:0] sum;
reg [63:0] result;
reg [31:0] count;
reg [64:0] mul_rem;
reg [3:0] Mode;
reg [31:0] A;
reg [31:0] B;
       

// ===============================================
//                   combinational
// ===============================================
always @(*) begin
    if (valid) begin
        Mode = mode;
        sum = 32'b0;
        result = 64'b0;
    end
    case (Mode)
        4'b0000: begin
            sum = in_A + in_B;
            if ((in_A[31] == in_B[31]) && (sum[31] != in_A[31])) begin
                if (in_A[31] == 1) begin
                    result = {32'b0, 32'h80000000}; // Smallest negative value
                end else begin
                    result = {32'b0, 32'h7FFFFFFF}; // Largest positive value
                end
            end else begin
                result = {32'b0, sum};
            end
            
        end
        4'b0001: begin
            sum = in_A - in_B;
            if ((in_A[31] !=in_B[31]) && (sum[31] != in_A[31])) begin
                if (in_A[31] == 1) begin
                    result = {32'b0, 32'h80000000}; // Smallest negative value
                end else begin
                    result = {32'b0, 32'h7FFFFFFF}; // Largest positive value
                end
            end else begin
                result = {32'b0, sum};
            end
        end
        4'b0010: begin
            result = {32'b0,in_A & in_B};
        end
        4'b0011: begin
            result = {32'b0, in_A | in_B};
        end
        4'b0100: begin
            result = {32'b0, in_A ^ in_B};
        end
        4'b0101: begin
            result = {63'd0, (in_A == in_B) };
        end
        4'b0110: begin
            result = {63'd0, ($signed(in_A) >= $signed(in_B)) };
        end
        4'b0111: begin
            result = {32'b0, in_A >> in_B};
        end
        4'b1000: begin
            result = {32'b0, in_A << in_B};
        end
        4'b1001: begin
            if(valid) begin
                A = in_A;
                B = in_B;
            end
            if(ready) begin
                Mode = 4'b0000;
            end
        end
        4'b1010: begin
            if(valid) begin
                
                A = in_A;
                B = in_B;
            end
            if(ready) begin
                Mode = 4'b0000;
            end
        end
    endcase
    
end

// ===============================================
//                    sequential
// ===============================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ready <= 1'b0;
        out_data <= 64'b0;
        mul_rem <= 64'b0;
        count <= 32'b0;
    end else begin
        ready <= 1'b0;
        case (Mode)
            4'b0000: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b0001: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b0010: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b0011: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b0100: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b0101: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b0110: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b0111: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b1000: begin
                if(valid) begin
                    out_data <= result;
                    ready <= 1'b1;
                end
            end
            4'b1001: begin
                if (count == 0) begin
                    mul_rem <= {32'b0, in_B};
                    count <= count + 1;
                end else if (count == 32) begin
                    out_data <= (mul_rem >> 1) + (mul_rem[0] ? (A << 31) : 64'b0);
                    ready <= 1'b1;
                    count <= 0;
                    
                end else begin
                    mul_rem <= (mul_rem >> 1) + (mul_rem[0] ? (A << 31) : 64'b0);
                    count <= count + 1;
                end
            end
            4'b1010: begin
                if (count == 0) begin
                    if ({31'b0, in_A[31]} >= B) begin
                        mul_rem <= (({31'b0, in_A, 1'b0} - {B, 32'b0}) << 1) + 1;
                    end else begin
                        mul_rem <= {31'b0, in_A, 1'b0} << 1;
                    end
                    count <= count + 1;
                end else if (count == 32) begin
                    out_data <= {mul_rem[64:33], mul_rem[31:0]};
                    ready <= 1'b1;
                    count <= 0;
                    
                end else begin
                    if (mul_rem[63:32] >= B) begin
                        mul_rem <= ((mul_rem - {B, 32'b0}) << 1) + 1;
                    end else begin
                        mul_rem <= mul_rem << 1;
                    end
                    count <= count + 1;
                end
            end
        endcase
        if (ready) begin
            ready <= 1'b0;
        end
    end
end

endmodule