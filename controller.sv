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
        if(curr == A) begin
           if (start == 1'b1 && ALU_op == 2'b10 && opcode == 3'b110) next = F;
        else if (start == 1'b1 && ALU_op == 2'b00 && opcode == 3'b110) next = C;
        else if (start == 1'b1 || ALU_op == 2'b11) next = C;
        else if (start == 1'b1) next = B;
        else next = A;
        end
        else if (curr == B) next = C;
        else if (curr ==C) next = D;
        else if (curr ==D) begin
           if (ALU_op == 2'b01) next = E;
        else next = F;
        end
        else if (curr==E) next = A;
        else next = A;
  end

  always_ff @(posedge clk) begin
    if (rst_n == 1'b0) curr <= A;
    else curr <= next;
  end

  always_comb begin
        case(curr)
        A: begin
          waiting_reg = 1'b1;
          reg_sel_reg = 2'bxx;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          en_C_reg = 1'b0;
          w_en_reg = 1'b0;
          wb_sel_reg = 1'bx;
          sel_A_reg = 1'bx;
          sel_B_reg = 1'bx;
          en_status_reg = 1'b0;
        end
        B: begin
          waiting_reg = 1'b0;
          reg_sel_reg = 2'b10; //select Rn for r_addr
          en_A_reg = 1'b1;
          en_B_reg = 1'b0;
          w_en_reg = 1'b0;
          wb_sel_reg = 2'bxx;
          sel_A_reg = 1'bx;
          sel_B_reg = 1'bx;
          en_C_reg = 1'b0;
          en_status_reg = 1'b0;
        end
        C: begin
          waiting_reg = 1'b0;
          reg_sel_reg = 2'b00; //Select Rm for r_addr
          en_A_reg = 1'b0;
          en_B_reg = 1'b1;
          en_C_reg = 1'b0;
          w_en_reg = 1'b0; 
          wb_sel_reg = 2'bxx;
          sel_A_reg = 1'bx;
          sel_B_reg = 1'bx;
          en_status_reg = 1'b0;
        end
        D: if (opcode == 3'b110 && ALU_op == 2'b00) begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          wb_sel_reg = 2'bxx;
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
          wb_sel_reg = 2'bxx;
          reg_sel_reg = 2'bxx;
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
   sel_A_reg = 1'b0;
   sel_B_reg = 1'b0;
   en_C_reg = 1'bx;
        end
        F: if (ALU_op == 2'b10 && opcode == 3'b110) begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          w_en_reg = 1'b1;
          wb_sel_reg = 2'b10;
          en_C_reg = 1'b0;
          en_status_reg = 1'b0;
          reg_sel_reg = 2'b10;
          sel_A_reg = 1'bx;
          sel_B_reg = 1'bx;
        end else if (opcode == 3'b110 && ALU_op == 2'b00) begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          w_en_reg = 1'b1;
          wb_sel_reg = 2'b00;
          reg_sel_reg = 2'b01;
          en_C_reg = 1'b0;
          en_status_reg = 1'b0;
   sel_A_reg = 1'b1;
   sel_B_reg = 1'b0;
        end else begin
          waiting_reg = 1'b0;
          en_A_reg = 1'b0;
          en_B_reg = 1'b0;
          w_en_reg = 1'b1;
          wb_sel_reg = 2'b00;
          reg_sel_reg = 2'b01;
          en_C_reg = 1'b0;
          en_status_reg = 1'b0;
   sel_A_reg = 1'b0;
   sel_B_reg = 1'b0;
        end
        default: begin
 waiting_reg = 1'bx;
 reg_sel_reg = 1'bx;
 en_A_reg = 1'bx;
 en_B_reg = 1'bx;
 w_en_reg = 1'bx;
 wb_sel_reg = 2'bxx;
 sel_A_reg = 1'bx;
 sel_B_reg = 1'bx;
 en_C_reg = 1'bx;
 en_status_reg = 1'bx;
 end
        endcase
    end

endmodule: controller
