// Your code
module CPU(clk,
            rst_n,
            // For mem_D (data memory)
            wen_D,
            addr_D,
            wdata_D,
            rdata_D,
            // For mem_I (instruction memory (text))
            addr_I,
            rdata_I);


    input         clk, rst_n ;
    // For mem_D
    output        wen_D  ;
    output [31:0] addr_D ;
    output [31:0] wdata_D;
    input  [31:0] rdata_D;
    // For mem_I
    output [31:0] addr_I ;
    input  [31:0] rdata_I;
    

    //---------------------------------------//
    // Do not modify this part!!!            //
    // Exception: You may change wire to reg //
    reg    [31:0] PC          ;              //
    reg    [31:0] PC_nxt      ;              //
    reg           regWrite    ;              //
    reg    [ 4:0] rs1, rs2, rd;              //
    reg    [31:0] rs1_data    ;              //
    reg    [31:0] rs2_data    ;              //
    reg    [31:0] rd_data     ;              //
    //---------------------------------------//

    // Todo: other wire/reg
    parameter LW    = 7'b0000011;
    parameter SW    = 7'b0100011;
    parameter ADD   = 7'b0110011;// =SUB=MUL=DIVU=REMU
    parameter ADDI  = 7'b0010011;// =SLLI=SRLI=SRAI=SLTI
    parameter BEQ   = 7'b1100011;// =BNE=BGE=BLT
    parameter JAL   = 7'b1101111;
    parameter JALR  = 7'b1100111;
    parameter AUIPC = 7'b0010111;
    parameter LUI   = 7'b0110111;

    parameter ADD_FUNC3 = 3'b000;
    parameter SUB_FUNC3 = 3'b000;
    parameter ADDI_FUNC3 = 3'b000;
    parameter SLLI_FUNC3 = 3'b001;
    parameter SRLI_FUNC3 = 3'b101;
    parameter SRAI_FUNC3 = 3'b101;
    parameter SLTI_FUNC3 = 3'b010;
    parameter BEQ_FUNC3 = 3'b000;
    parameter BNE_FUNC3 = 3'b001;
    parameter BGE_FUNC3 = 3'b101;
    parameter BLT_FUNC3 = 3'b100;
    parameter MUL_FUNC3 = 3'b000;
    parameter DIVU_FUNC3 = 3'b101;
    parameter REMU_FUNC3 = 3'b111;

    parameter ADD_FUNC7 = 7'b0000000;
    parameter SUB_FUNC7 = 7'b0100000;
    parameter SLLI_FUNC7 = 7'b0000000;
    parameter SRLI_FUNC7 = 7'b0000000;
    parameter SRAI_FUNC7 = 7'b0100000;
    parameter MUL_FUNC7 = 7'b0000001;
    parameter DIVU_FUNC7 = 7'b0000001;
    parameter REMU_FUNC7 = 7'b0000001;

    parameter MULDIV_FREE = 2'b00;
    parameter MULDIV_EXECUTE = 2'b01;
    parameter MULDIV_EXECUTE_MULDIV = 2'b10;

    reg [6:0]   opcode;
    reg [31:0]  input_instrction;
    reg [1:0]   state_w;
    reg [1:0]   state_r;
    reg [2:0]   funct3;
    reg [6:0]   funct7;
    reg [31:0]  immediate;
    reg [31:0]  addr_D_w;
    reg [31:0]  wdata_D_w;
    reg         wen_D_w;
    reg         muldiv_valid;
    reg         muldiv_ready;
    reg [1:0]   muldiv_mode;
    reg [31:0]  muldiv_in_A;
    reg [31:0]  muldiv_in_B;
    reg [63:0]  muldiv_out;

    mulDiv muldivALU(.clk(clk), .rst_n(rst_n), .valid(mulDiv_valid), .ready(mulDiv_ready),
        .mode(mulDiv_mode),   .in_A(mulDiv_in_A), .in_B(mulDiv_in_B),   .out(mulDiv_out));

    //---------------------------------------//
    // Do not modify this part!!!            //
    reg_file reg0(                           //
        .clk(clk),                           //
        .rst_n(rst_n),                       //
        .wen(regWrite),                      //
        .a1(rs1),                            //
        .a2(rs2),                            //
        .aw(rd),                             //
        .d(rd_data),                         //
        .q1(rs1_data),                       //
        .q2(rs2_data));                      //
    //---------------------------------------//

    // Todo: any combinational/sequential circuit
    
    assign addr_I = PC;
    assign addr_D = addr_D_w;
    assign wdata_D = wdata_D_w;
    assign wen_D = wen_D_w;

    always @(*) begin
        input_instrction = rdata_I;
        PC_nxt = PC + 4;
        opcode = input_instrction[6:0];
        funct3 = input_instrction[14:12];
        funct7 = input_instrction[31:25];
        immediate = 0;
        rs1 = input_instrction[19:15];
        rs2 = input_instrction[24:20];
        rd = input_instrction[11:7];
        rd_data = 0;
        addr_D_w = 0;
        wdata_D_w = 0;
        wen_D_w = 0;
        regWrite = 0;
        muldiv_valid = 0;
        muldiv_in_A = rs1_data;
        muldiv_in_B = rs2_data;
        muldiv_mode = MULDIV_FREE;
        case (opcode)
            ADD: begin // = SUB = MUL = DIVU = REMU
                if ({funct3,funct7} == {ADD_FUNC3,ADD_FUNC7}) begin // ADD
                    regWrite = 1;
                    rd_data = $signed(rs1_data) + $signed(rs2_data);

                end else if ({funct3,funct7} == {SUB_FUNC3,SUB_FUNC7}) begin // SUB
                    regWrite = 1;
                    rd_data = $signed(rs1_data) - $signed(rs2_data);

                end else if ({funct3,funct7} == {MUL_FUNC3,MUL_FUNC7}) begin // MUL
                    if(muldiv_ready) begin
                        regWrite = 1;
                        rd_data = muldiv_out[31:0];
                    end else begin
                        regWrite = 0;
                        PC_nxt = PC;
                    end
                    muldiv_valid = 1;
                    muldiv_mode = 0;

                end else if ({funct3,funct7} == {DIVU_FUNC3,DIVU_FUNC7}) begin // DIVU
                    if(muldiv_ready) begin
                        regWrite = 1;
                        rd_data = muldiv_out[63:32];
                    end else begin
                        regWrite = 0;
                        PC_nxt = PC;
                    end
                    muldiv_valid = 1;
                    muldiv_mode = 0;

                end else if ({funct3,funct7} == {REMU_FUNC3,REMU_FUNC7}) begin // REMU
                    if(muldiv_ready) begin
                        regWrite = 1;
                        rd_data = muldiv_out[31:0];
                    end else begin
                        regWrite = 0;
                        PC_nxt = PC;
                    end
                    muldiv_valid = 1;
                    muldiv_mode = 0;
                end
            end
            ADDI: begin // =SLLI=SRLI=SRAI=SLTI
                immediate[11:0] = input_instrction[31:20]; 
                if (funct3 == ADDI_FUNC3) begin // ADDI
                    regWrite = 1;
                    rd_data = $signed(rs1_data) + immediate[11:0];

                end else if (funct3 == SLLI_FUNC3) begin // SLLI
                    regWrite = 1;
                    rd_data = rs1_data << immediate[11:0];

                end else if (funct3 == SRLI_FUNC3) begin // SRLI
                    regWrite = 1;
                    rd_data = rs1_data >> immediate[11:0];

                end else if (funct3 == SRAI_FUNC3) begin // SRAI
                    regWrite = 1;
                    rd_data = $signed(rs1_data) >>> immediate;

                end else if (funct3 == SLTI_FUNC3) begin // SLTI
                    regWrite = 1;
                    rd_data = ($signed(rs1_data) < $signed(immediate)) ? 1 : 0;
                end
            end
            LW: begin
                regWrite = 1;
                immediate[11:0] = input_instrction[31:20];
                addr_D_w = $signed(rs1_data) + $signed(immediate[11:0]);
                rd_data = rdata_D;
            end
            BEQ: begin // =BNE=BGE=BLT
                immediate[12] = input_instrction[31];
                immediate[11] = input_instrction[7];
                immediate[10:5] = input_instrction[30:25];
                immediate[4:1] = input_instrction[11:8];
                immediate[0] = 0;
                if (funct3 == BEQ_FUNC3) begin // BEQ
                    if (rs1_data == rs2_data) begin
                        PC_nxt = PC + $signed(immediate);
                    end
                end else if (funct3 == BNE_FUNC3) begin // BNE
                    if (rs1_data != rs2_data) begin
                        PC_nxt = PC + $signed(immediate);
                    end
                end else if (funct3 == BGE_FUNC3) begin // BGE
                    if ($signed(rs1_data) >= $signed(rs2_data)) begin
                        PC_nxt = PC + $signed(immediate);
                    end
                end else if (funct3 == BLT_FUNC3) begin // BLT
                    if ($signed(rs1_data) < $signed(rs2_data)) begin
                        PC_nxt = PC + $signed(immediate);
                    end
                end
            end
            SW: begin
                immediate[11:5] = input_instrction[31:25];
                immediate[4:0] = input_instrction[11:7];
                addr_D_w = $signed({1'b0, rs1_data}) + $signed(immediate[11:0]);
                wdata_D_w = rs2_data;
                wen_D_w = 1;
            end
            AUIPC: begin
                immediate[19:0] = input_instrction[31:12];
                regWrite = 1;
                rd_data = PC + immediate;
            end
            JAL: begin
                immediate[20] = input_instrction[31];
                immediate[19:12] = input_instrction[19:12];
                immediate[11] = input_instrction[20];
                immediate[10:1] = input_instrction[30:21];
                immediate[0] = 0;
                regWrite = 1;
                rd_data = PC + 4;
                PC_nxt = PC + $signed(immediate);
            end
            JALR: begin
                immediate[11:0] = input_instrction[31:20];
                regWrite = 1;
                rd_data = PC + 4;
                PC_nxt = $signed({1'b0, rs1_data}) + $signed(immediate);
            end
        endcase
    end

    always @(*) begin
        state_w = state_r;
        case(state_r)
            MULDIV_FREE: begin
                if(opcode == ADD && (  {funct3,funct7} == {MUL_FUNC3,MUL_FUNC7}
                                    || {funct3,funct7} == {DIVU_FUNC3,DIVU_FUNC7}
                                    || {})) begin
                    state_w = MULDIV_EXECUTE_MULDIV;
                end else if(opcode == ADD && {funct3,funct7} == {DIVU_FUNC3,DIVU_FUNC7}) begin
                    state_w = MULDIV_EXECUTE_MULDIV;
                end else if(opcode == ADD && {funct3,funct7} == {REMU_FUNC3,REMU_FUNC7}) begin
                    state_w = MULDIV_EXECUTE_MULDIV;
                end else begin
                    state_w = MULDIV_EXECUTE;
                end
            end
            MULDIV_EXECUTE: begin
                if(opcode == ADD && (  {funct3,funct7} == {MUL_FUNC3,MUL_FUNC7}
                                    || {funct3,funct7} == {DIVU_FUNC3,DIVU_FUNC7}
                                    || {})) begin
                    state_w = MULDIV_EXECUTE_MULDIV;
                end else if(opcode == ADD && {funct3,funct7} == {DIVU_FUNC3,DIVU_FUNC7}) begin
                    state_w = MULDIV_EXECUTE_MULDIV;
                end else if(opcode == ADD && {funct3,funct7} == {REMU_FUNC3,REMU_FUNC7}) begin
                    state_w = MULDIV_EXECUTE_MULDIV;
                end else begin
                    state_w = MULDIV_EXECUTE;
                end
            end
            MULDIV_EXECUTE_MULDIV: begin
                if(opcode == ADD && (  {funct3,funct7} == {MUL_FUNC3,MUL_FUNC7}
                                    || {funct3,funct7} == {DIVU_FUNC3,DIVU_FUNC7}
                                    || {})) begin
                    state_w = MULDIV_EXECUTE;
                end else if(opcode == ADD && {funct3,funct7} == {DIVU_FUNC3,DIVU_FUNC7}) begin
                    state_w = MULDIV_EXECUTE;
                end else if(opcode == ADD && {funct3,funct7} == {REMU_FUNC3,REMU_FUNC7}) begin
                    state_w = MULDIV_EXECUTE;
                end else begin
                    state_w = MULDIV_EXECUTE_MULDIV;
                end
                
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'h00010000; // Do not modify this value!!!
            state_r <= MULDIV_FREE;
        end
        else begin
            PC <= PC_nxt;
            state_r <= state_w;
        end
    end
endmodule

// Do not modify the reg_file!!!
module reg_file(clk, rst_n, wen, a1, a2, aw, d, q1, q2);

    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth

    input clk, rst_n, wen; // wen: 0:read | 1:write
    input [BITS-1:0] d;
    input [addr_width-1:0] a1, a2, aw;

    output [BITS-1:0] q1, q2;

    reg [BITS-1:0] mem [0:word_depth-1];
    reg [BITS-1:0] mem_nxt [0:word_depth-1];

    integer i;

    assign q1 = mem[a1];
    assign q2 = mem[a2];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (aw == i)) ? d : mem[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1) begin
                case(i)
                    32'd2: mem[i] <= 32'hbffffff0;
                    32'd3: mem[i] <= 32'h10008000;
                    default: mem[i] <= 32'h0;
                endcase
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1)
                mem[i] <= mem_nxt[i];
        end
    end
endmodule

module mulDiv(clk, rst_n, valid, ready, mode, in_A, in_B, out);
    // Todo: your HW2
    input         clk, rst_n;
    input         valid;
    input  [1:0]  mode; // 0: mulu, 1: divu, 2: remu
    output        ready;
    input  [31:0] in_A;
    input  [31:0] in_B;
    output [63:0] out;

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
            2'd0: begin
                if(valid) begin
                    A = in_A;
                    B = in_B;
                end
                if(ready) begin
                    Mode = 4'd3;
                end
            end
            2'd1: begin
                if(valid) begin
                    A = in_A;
                    B = in_B;
                end
                if(ready) begin
                    Mode = 4'd3;
                end
            end
            2'd2: begin
                if(valid) begin
                    A = in_A;
                    B = in_B;
                end
                if(ready) begin
                    Mode = 4'd3;
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