module tb_idecoder(output err);
  // your implementation here
  logic[15:0] ir_test;
  logic [1:0] reg_sel_test;
  logic [2:0] opcode_test;
  logic [1:0] ALU_op_test; 
  logic [1:0] shift_op_test;
	logic [15:0] sximm5_test;
  logic [15:0] sximm8_test;
  logic [2:0] r_addr_test; 
  logic [2:0] w_addr_test;
  logic err_reg;

  assign err = err_reg;

  idecoder dut(.ir(ir_test), .reg_sel(reg_sel_test), .opcode(opcode_test), .ALU_op(ALU_op_test), .shift_op(shift_op_test),
              .sximm5(sximm5_test), .sximm8(sximm8_test), .r_addr(r_addr_test), .w_addr(w_addr_test));

  integer num_passes = 0;
  integer num_fails = 0;

  task assign_values(input[15:0] ir_val, input[1:0] reg_val);
    assert(ir_val[15:13] == 3'b110 || ir_val[15:13] === 3'b101) begin
      assign ir_test = ir_val;
    end else begin
      assign err_reg = 1'b1;
    end
    assign reg_sel_test = reg_val;
    #5;
  endtask 

 

  task check_opcode(input[2:0] opcode_expect, input string msg);
    assert(opcode_test == opcode_expect) begin
      $diplay("PASS %s: output is %b", msg, opcode_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, opcode_test, opcode_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_ALU_op(input[1:0] ALU_expect, input string msg);
    assert(ALU_expect == ALU_op_test) begin
      $diplay("PASS %s: output is %b", msg, ALU_op_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, ALU_op_test, ALU_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_shift_op(input[1:0] shift_op_expect, input string msg);
    assert(shift_op_expect == shift_op_test) begin
      $diplay("PASS %s: output is %b", msg, shift_op_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, shift_op_test, shift_op_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_sximm5(input[15:0] sximm5_expect, input string msg);
    assert(sximm5_test == sximm5_expect) begin
      $diplay("PASS %s: output is %b", msg, sximm5_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, sximm5_test, sximm5_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_sximm8(input[15:0] sximm8_expect, input string msg);
    assert(sximm8_expect == sximm8_test) begin
      $diplay("PASS %s: output is %b", msg, sximm8_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, sximm8_test, sximm8_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_r_addr(input[2:0] r_addr_expect, input string msg);
    assert(r_addr_expect == r_addr_test) begin
      $diplay("PASS %s: output is %b", msg, r_addr_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, r_addr_test, r_addr_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

   task check_w_addr(input[2:0] w_addr_expect, input string msg);
    assert(w_addr_expect == w_addr_test) begin
      $diplay("PASS %s: output is %b", msg, w_addr_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, w_addr_test, w_addr_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  initial begin
    assign err_reg = 1'b0;

    assign_values(16'b1101000100000000, 2'b00);
    check_opcode(3'b110, "TEST OPCODE 1");
    check_ALU_op(2'b10, "TEST ALU OP 1");
    check_shift_op(2'b00, "TEST SHIFT OP NO SHIFT");
    check_sximm5(16'b0000000000000000, "TEST SXIM5");
    check_sximm8(16'b0000000000000000, "TEXT SXIM8");

    

    $display("\n\n==== TEST SUMMARY ====");
    $display("  TEST COUNT: %-5d", num_passes + num_fails);
    $display("    - PASSED: %-5d", num_passes);
    $display("    - FAILED: %-5d", num_fails);
    $display("======================\n\n");
    $stop;
  end


endmodule: tb_idecoder
