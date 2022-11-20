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
