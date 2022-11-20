module tb_controller(output err);
  logic clk_test;
  logic rst_n_test; 
  logic start_test;
  logic [2:0] opcode_test;
  logic [1:0] ALU_op_test;
  logic [1:0] shift_op_test;
  logic Z_test; 
  logic N_test;
  logic V_test; 
  logic waiting_test;
  logic [1:0] reg_sel_test;
  logic [1:0] wb_sel_test; 
  logic w_en_test, en_A_test, en_B_test, en_C_test, en_status_test, sel_A_test, sel_B_test;
  logic err_reg;
  assign err = err_reg;

  controller dut(.clk(clk_test), .rst_n(rst_n_test), .start(start_test),
                  .opcode(opcode_test), .ALU_op(ALU_op_test), .shift_op(shift_op_test),
                  .Z(Z_test), .N(N_test), .V(V_test),
                  .waiting(waiting_test),
                  .reg_sel(reg_sel_test), .wb_sel(wb_sel_test), .w_en(w_en_test),
                  .en_A(en_A_test), .en_B(en_B_test), .en_C(en_C_test), .en_status(en_status_test),
                  .sel_A(sel_A_test), .sel_B(sel_B_test));

  integer num_passes = 0;
  integer num_fails = 0;

  task reset();
    assign rst_n_test = 1'b0;
    #20;
    assign rst_n_test = 1'b1;
    #10;
  endtask

  task start();
    assign start_test = 1'b1;
    #10;
    assign start_test = 1'b0;
  endtask

  task wait_status(input wait_expect, input string msg);
    assert (waiting_test == wait_expect) begin
       $diplay("PASS %s: output is %b", msg, waiting_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, waiting_test, wait_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_reg_sel(input[1:0] reg_sel_expect, input string msg);
    assert (reg_sel_expect == reg_sel_test) begin
       $diplay("PASS %s: output is %b", msg, reg_sel_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, reg_sel_test, reg_sel_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_wb_sel(input[1:0] wb_sel_expect, input string msg);
    assert (wb_sel_expect == wb_sel_test) begin
       $diplay("PASS %s: output is %b", msg, wb_sel_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, wb_sel_test, wb_sel_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_w_en(input w_en_expect, input string msg);
    assert (w_en_expect == w_en_test) begin
       $diplay("PASS %s: output is %b", msg, w_en_expect);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, w_en_test, w_en_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_enA(input en_A_expect, input string msg);
    assert (en_A_expect == en_A_test) begin
       $diplay("PASS %s: output is %b", msg, en_A_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, en_A_test, en_A_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_enB(input en_B_expect, input string msg);
    assert (en_B_expect == en_B_test) begin
       $diplay("PASS %s: output is %b", msg, en_B_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, en_B_test, en_B_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_enC(input en_C_expect, input string msg);
    assert (en_C_expect == en_C_test) begin
       $diplay("PASS %s: output is %b", msg, en_C_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, en_C_test, en_C_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_status(input status_expect, input string msg);
    assert (status_expect == en_status_test) begin
       $diplay("PASS %s: output is %b", msg, en_status_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, en_status_test, status_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_selA(input sel_A_expect, input string msg);
    assert (sel_A_expect == sel_A_test) begin
       $diplay("PASS %s: output is %b", msg, sel_A_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, sel_A_test, sel_A_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task check_selB(input sel_B_expect, input string msg);
    assert (sel_B_expect == sel_B_test) begin
       $diplay("PASS %s: output is %b", msg, sel_B_test);
      num_passes = num_passes + 1;
    end else begin
      $error("FAIL %s: output is %b, expected %b", msg, sel_B_test, sel_B_expect);
      num_fails = num_fails + 1;
      assign err_reg = 1'b1;
    end
  endtask

  task assign_stuff(input [2:0] opcode, input [1:0] ALU_op, input [1:0] shift_op,
                  input Z, input N, input V);
    assign opcode_test = opcode;
    assign ALU_op_test = ALU_op;
    assign shift_op_test = shift_op;
    assign Z_test = Z;
    assign N_test = N;
    assign V_test = V;
    #5;
  endtask

  initial begin
    clk_test = 1'b1;
    forever #5 clk_test = ~clk_test;
  end

  initial begin
    assign err_reg = 1'b0;
    #5;
    reset;

    //Op 1 Test
    assign_stuff(3'b110, 2'b10, 2'b10, 1'b0, 1'b0, 1'b0);
    wait_status(1'b1, "IS WAITING AT START");
    start;
    wait_status(1'b0, "NOT WAITING");
    check_enA(1'b0, "A NOT ON WHEN UPDATING");
    check_enB(1'b0, "B NOT ON WHEN UPDATING");
    check_enC(1'b0, "C NOT ON WHEN UPDATING");
    check_w_en(1'b1, "W_EN ON CuZ UPDATING STATUS");
    check_wb_sel(1'b0, "WB_SEL SAYS COMING FROM C");
    check_r_addr(3'b101, "WRITING TO 101");

    $display("\n\n==== TEST SUMMARY ====");
    $display("  TEST COUNT: %-5d", num_passes + num_fails);
    $display("    - PASSED: %-5d", num_passes);
    $display("    - FAILED: %-5d", num_fails);
    $display("======================\n\n");
    $stop;
  end

  // your implementation here
endmodule: tb_controller