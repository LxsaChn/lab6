module cpu(input clk, input rst_n, input load, input start, input [15:0] instr,
           output waiting, output [15:0] out, output N, output V, output Z);
  // your implementation here
  wire [15:0] sximm5, sximm8, mdata;
  reg [7:0] pc;
  wire [2:0] opcode, r_addr, w_addr;
  reg [1:0] reg_sel, wb_sel;
  wire [1:0] ALU_op, shift_op;
  reg en_A, en_B, en_C, en_status, sel_A, sel_B, w_en;
  
  // fetch
  
  // decode
  idecoder mydecoder (instr, reg_sel, opcode, ALU_op, shift_op, sximm5, sximm8, r_addr, w_addr);
  // execute
  controller mycontroller (clk, rst_n, start, opcode, ALU_op, shift_op, Z, N, V, waiting, reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B);
  // write back
  datapath mydatapath (clk, mdata, pc, wb_sel, w_addr, w_en, r_addr, en_A, en_B, shift_op, sel_A, sel_B, ALU_op, en_C, en_status, sximm8, sximm5, out, Z, N, V);
  
endmodule: cpu

module idecoder(input [15:0] ir, input [1:0] reg_sel,
                output [2:0] opcode, output [1:0] ALU_op, output [1:0] shift_op,
output [15:0] sximm5, output [15:0] sximm8,
                output [2:0] r_addr, output [2:0] w_addr);
  // your implementation here
  reg [2:0] opcode_reg;
  reg [1:0] ALU_op_reg;
  reg [1:0] shift_op_reg;
  reg [15:0] sximm5_reg;
  reg [15:0] sximm8_reg;
  reg [2:0] r_addr_reg;
  reg [2:0] w_addr_reg;


  assign opcode = opcode_reg;
  assign opcode_reg = ir[15:13];

  assign ALU_op = ALU_op_reg;
  assign ALU_op_reg = ir[12:11];
 
  assign sximm5 = sximm5_reg;
  assign sximm8 = sximm8_reg;
 
  always_comb begin
        if (ir[4] == 1'b0) sximm5_reg = {11'b00000000000, ir[4:0]};
        else sximm5_reg = {11'b11111111111, ir[4:0]};

        if (ir[7] == 1'b0) sximm8_reg =  {8'b00000000, ir[7:0]};
        else sximm8_reg =  {8'b11111111, ir[7:0]};
  end

  assign shift_op = shift_op_reg;
  assign shift_op_reg = ir[4:3];

  assign r_addr = r_addr_reg;
  assign w_addr = w_addr_reg;

  always_comb begin
        case (reg_sel)
        2'b00: begin
                r_addr_reg = ir[2:0];
                w_addr_reg = ir[2:0];
        end
        2'b01: begin
                r_addr_reg = ir[7:5];
                w_addr_reg = ir[7:5];
        end
        2'b10: begin
                r_addr_reg = ir[10:8];
                w_addr_reg = ir[10:8];
        end
        default: begin
                r_addr_reg = ir[2:0];
                w_addr_reg = ir[2:0];
        end
        endcase
  end
endmodule: idecoder

module controller(input clk, input rst_n, input start,
                  input [2:0] opcode, input [1:0] ALU_op, input [1:0] shift_op,
                  input Z, input N, input V,
                  output waiting,
                  output [1:0] reg_sel, output [1:0] wb_sel, output w_en,
                  output en_A, output en_B, output en_C, output en_status,
                  output sel_A, output sel_B);
  // your implementation here
  enum reg[2:0]{
        A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100, F = 3'b101
  } curr, next;

  logic waiting_reg;
  assign waiting = waiting_reg;

  logic [1:0] reg_sel_reg, wb_sel_reg;
  assign reg_sel = reg_sel_reg;
  assign wb_sel = wb_sel_reg;

  logic w_en_reg;
  assign w_en = w_en_reg;

  logic en_A_reg;
  assign en_A = en_A_reg;

  logic en_B_reg;
  assign en_B = en_B_reg;

  logic en_C_reg;
  assign en_C = en_C_reg;

  logic en_status_reg;
  assign en_status = en_status_reg;

  logic sel_A_reg;
  assign sel_A = sel_A_reg;

  logic sel_B_reg;  
  assign sel_B = sel_B_reg;              

  always_comb begin
     case(curr)
        A: if (start == 1'b1 && ALU_op == 2'b10 && opcode == 3'b110) next = F;
        else if (start == 1'b1 && ALU_op == 2'b00 && opcode == 3'b110) next = C;
        else if (start == 1'b1 || ALU_op == 2'b11) next = C;
        else if (start == 1'b1) next = B;
        else next = A;
        B: next = C;
        C: next = D;
        D: if (ALU_op == 2'b01) next = E;
        else next = F;
        E: next = A;
        F: next = A;
        default: next = A;
     endcase
  end

  always_ff @(posedge clk) begin
    if (rst_n == 1'b0) curr <= A;
    else curr <= next;
  end

  always_comb begin
        case(curr)
        A: begin
          waiting_reg = 1'b1;
reg_sel_reg = 1'bx;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          en_C_reg = 1'b0;
          w_en_reg = 1'b0;
   wb_sel_reg = 1'bx;
   sel_A_reg = 1'bx;
   sel_B_reg = 1'bx;
   en_status_reg = 1'bx;
        end
        B: begin
          waiting_reg = 1'b0;
          reg_sel_reg = 2'b10; //select Rn for r_addr
          en_A_reg = 1'b1;
          en_B_reg = 1'b0;
          w_en_reg = 1'b0;
   wb_sel_reg = 1'bx;
   sel_A_reg = 1'bx;
   sel_B_reg = 1'bx;
   en_C_reg = 1'bx;
      en_status_reg = 1'bx;
        end
        C: begin
          waiting_reg = 1'b0;
          reg_sel_reg = 2'b00; //Select Rm for r_addr
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
en_C_reg = 1'bx;
          w_en_reg = 1'b0; 
   wb_sel_reg = 1'bx;
   sel_A_reg = 1'bx;
   sel_B_reg = 1'bx;
   en_status_reg = 1'bx;
        end
        D: if (opcode == 3'b110 && ALU_op == 2'b00) begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
wb_sel_reg = 1'bx;
reg_sel_reg = 1'bx;
          w_en_reg = 1'b0;
          sel_A_reg = 1'b1;
          sel_B_reg = 1'b0;
          en_C_reg = 1'b1;
          en_status_reg = 1'b0;
        end else if (ALU_op == 2'b00) begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          w_en_reg = 1'b0;
          sel_A_reg = 1'b0;
          sel_B_reg = 1'b0;
          en_C_reg = 1'b1;
          en_status_reg = 1'b0;
wb_sel_reg = 1'bx;
reg_sel_reg = 1'bx;
        end else if (ALU_op == 2'b01) begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          w_en_reg = 1'b0;
          sel_A_reg = 1'b0;
          sel_B_reg = 1'b0;
          en_C_reg = 1'b0;
          en_status_reg = 1'b1;
wb_sel_reg = 1'bx;
reg_sel_reg = 1'bx;
        end else if (ALU_op == 2'b11) begin
          waiting_reg = 1'b0;
          en_A_reg = 0;
          en_B_reg = 0;
          w_en_reg = 0;
          sel_A_reg = 1'b0;
          sel_B_reg = 1'b0;
          en_C_reg = 1'b1;
          en_status_reg = 1'b0;
wb_sel_reg = 1'bx;
reg_sel_reg = 1'bx;
        end else begin
   waiting_reg = 1'bx;
   reg_sel_reg = 1'bx;
   en_A_reg = 1'bx;
   en_B_reg = 1'bx;
   w_en_reg = 1'bx;
  wb_sel_reg = 1'bx;
   sel_A_reg = 1'bx;
   sel_B_reg = 1'bx;
   en_C_reg = 1'bx;
   en_status_reg = 1'bx;
 end
        E: begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          w_en_reg = 1'b0;
          en_status_reg = 1'b1;
   reg_sel_reg = 1'bx;
   wb_sel_reg = 1'bx;
   sel_A_reg = 1'bx;
   sel_B_reg = 1'bx;
   en_C_reg = 1'bx;
        end
        F: if (start == 1'b1 && ALU_op == 2'b10 && opcode == 3'b110) begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          w_en_reg = 1'b1;
          wb_sel_reg = 2'b10;
          en_C_reg = 1'b1;
          en_status_reg = 1'b0;
   reg_sel_reg = 1'bx;
   sel_A_reg = 1'bx;
   sel_B_reg = 1'bx;
        end else begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          w_en_reg = 1'b1;
          wb_sel_reg = 2'b00;
          en_C_reg = 1'b1;
          en_status_reg = 1'b0;
reg_sel_reg = 1'bx;
   sel_A_reg = 1'bx;
   sel_B_reg = 1'bx;
        end
        default: begin
 waiting_reg = 1'bx;
 reg_sel_reg = 1'bx;
 en_A_reg = 1'bx;
 en_B_reg = 1'bx;
 w_en_reg = 1'bx;
 wb_sel_reg = 1'bx;
 sel_A_reg = 1'bx;
 sel_B_reg = 1'bx;
 en_C_reg = 1'bx;
 en_status_reg = 1'bx;
 end
        endcase
    end

endmodule: controller

module datapath(input clk, input [15:0] mdata, input [7:0] pc, input [1:0] wb_sel,
                input [2:0] w_addr, input w_en, input [2:0] r_addr, input en_A,
                input en_B, input [1:0] shift_op, input sel_A, input sel_B,
                input [1:0] ALU_op, input en_C, input en_status,
input [15:0] sximm8, input [15:0] sximm5,
                output [15:0] datapath_out, output Z_out, output N_out, output V_out);
  // your implementation here
  wire [15:0] w_data, r_data, data_A, data_B, shift_out, val_A, val_B, ALU_out;
  wire Z, N, V;
  
  regfile RF (w_data, w_addr, w_en, r_addr, clk, r_data);
  loadA LA (r_data, r_addr, clk, en_A, data_A);
  loadB LB (r_data, r_addr, clk, en_B, data_B);
  shifter SFT (data_B, shift_op, shift_out);
  selA SA (data_A, sel_A, val_A);
  selB SB (shift_out, sximm5, sel_B, val_B);
  ALU A (val_A, val_B, ALU_op, ALU_out, Z);
  enC C (ALU_out, en_C, datapath_out);
  enS S (Z, N, V, en_status, Z_out, N_out, V_out);
  write_back WB (wb_sel, datapath_out, mdata, sximm8, pc, w_data);
  
endmodule: datapath

module regfile(input [15:0] w_data, input [2:0] w_addr, input w_en, input [2:0] r_addr, input clk, output [15:0] r_data);
  reg [15:0] m[0:7];
  assign r_data = m[r_addr];
  always_ff @(posedge clk) if (w_en) m[w_addr] <= w_data;
endmodule: regfile

module loadA(input [15:0] r_data, input [2:0] r_addr, input clk, input en_A, output reg data_A);
  always_ff @(posedge clk) begin
if (en_A) data_A = r_data;
  end
endmodule: loadA

module loadB(input [15:0] r_data, input [2:0] r_addr, input clk, input en_B, output reg data_B);
  always_ff @(posedge clk) begin
if (en_B) data_B = r_data;
  end
endmodule: loadB

module shifter(input [15:0] data_B, input [1:0] shift_op, output reg [15:0] shift_out);
  always_comb begin
  case(shift_op)
  2'b00: shift_out = data_B;
  2'b01: shift_out = data_B << 1;
  2'b10: shift_out = data_B >> 1;
  2'b11: shift_out = {data_B[15], data_B[15:1]};
  default: shift_out = 16'bx;
  endcase
  end
endmodule: shifter

module selA(input [15:0] data_A, input sel_A, output reg [15:0] val_A);
  always_comb begin
if (sel_A) begin
val_A = 16'b0;
end else begin
val_A = data_A;
end
  end
endmodule: selA

module selB(input [15:0] shift_out, input [15:0] sximm5, input sel_B, output reg [15:0] val_B);
  always_comb begin
if (sel_B) begin
val_B = sximm5;
end else begin
val_B = shift_out;
end
  end
endmodule: selB

module ALU(input [15:0] val_A, input [15:0] shift_out, input [1:0] ALU_op, output reg [15:0] ALU_out, output reg Z, output reg N, output reg V);
  always_comb begin
    case(ALU_op)
    2'b00: ALU_out = val_A + shift_out;
    2'b01: ALU_out = val_A - shift_out;
    2'b10: ALU_out = val_A & shift_out;
    2'b11: ALU_out = ~shift_out;
    default: ALU_out = 16'bx;
    endcase
  end
  
  always_comb begin
    if (ALU_out == 16'b0) begin
Z = 1'b1;
N = 1'b0;
V = 1'b0;
end else if (ALU_out < 16'b0) begin
  Z = 1'b0;
  N = 1'b1;
V = 1'b0;
end else if (ALU_out > 16'b1) begin
  Z = 1'b0;
N = 1'b0;
  V = 1'b1;
end else begin
  Z = 1'b0;
N = 1'b0;
V = 1'b0;
    end 
  end
endmodule: ALU

module enC (input [15:0] ALU_out, input en_C, output reg [15:0] datapath_out);
  always_comb begin
   if (en_C) begin
datapath_out = ALU_out;
end else begin
datapath_out = 16'bx;
end
  end
endmodule: enC

module enS (input Z, input N, input V, input en_status, output reg Z_out, output reg N_out, output reg V_out);
  always_comb begin
if (en_status) begin
Z_out = Z;
N_out = N;
V_out = V;
end else begin
  Z_out = 1'bx;
N_out = 1'bx;;
V_out = 1'bx;
end
  end
endmodule: enS

module write_back (input [1:0] wb_sel, input [15:0] datapath_out, input [15:0] mdata, input [15:0] sximm8, input [7:0] pc, output reg [15:0] w_data);
  always_comb begin
case(wb_sel)
2'b11: w_data = mdata;
2'b10: w_data = sximm8;
2'b01: w_data = {8'b0, pc};
2'b00: w_data = datapath_out;
endcase
  end
endmodule: write_back
