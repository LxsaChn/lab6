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
        else sximm5_reg = {11'b1111111111, ir[4:0]};

        if (ir[7] == 1'b0) sximm8_reg =  {8'b00000000, ir[7:0]};
        else sximm8_reg =  {8'b11111111, ir[7:0]};
  end


  


  assign shift_op = shift_op_reg;
  assign shift_op_reg = ir[4:3];
  
  wire[2:0] rn = ir[10:8];
  wire[2:0] rd = ir[7:5];
  wire[2:0] rm = ir[2:0];

  always_comb begin
        case (reg_sel)
        00: begin
                r_addr_reg = rm;
                w_addr_reg = rm;
        end
        01: begin
                r_addr_reg = rd;
                w_addr_reg = rd;
        end
        10: begin
                r_addr_reg = rn;
                w_addr_reg = rn;
        end
        endcase
  end
endmodule: idecoder
