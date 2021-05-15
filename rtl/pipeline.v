`default_nettype none
module pipeline(
  input var logic clk,
  input var logic reset
);
  logic       a1_ready, a1_valid;
  logic [4:0] a1_output;
  adder a1(
    .clk(clk),
    .reset(reset),
    .prev_valid(1),
    .this_ready(a1_ready),
    .this_valid(a1_valid),
    .next_ready(d1_ready),
    .input_num(1),
    .output_num(a1_output)
  );

  logic       d1_ready, d1_valid;
  logic [4:0] d1_output;
  delayer d1(
    .clk(clk),
    .reset(reset),
    .prev_valid(a1_valid),
    .this_ready(d1_ready),
    .this_valid(d1_valid),
    .next_ready(a2_ready),
    .input_num(a1_output),
    .output_num(d1_output)
  );

  logic       a2_ready, a2_valid;
  logic [4:0] a2_output;
  adder a2(
    .clk(clk),
    .reset(reset),
    .prev_valid(d1_valid),
    .this_ready(a2_ready),
    .this_valid(a2_valid),
    .next_ready(1),
    .input_num(d1_output),
    .output_num(a2_output)
  );

  always_ff @(posedge clk) if(a2_valid) $display("num %d", a2_output);
 `ifdef FORMAL
  logic clocked;
  initial clocked = 0;
  always_ff @(posedge clk) clocked = 1;
  // assume we've reset at clk 0
  initial assume(reset);
  always @(*) if(!clocked) assume(reset);

  logic [4:0] counter;
  initial counter = 0;
  //always_ff @(posedge clk) counter = counter + 1;
  //always_ff @(posedge clk) if(counter == 5) assert(a2_output == 2);
 `endif
endmodule // pipeline

module adder(
  input  var logic       clk,
  input  var logic       reset,
  input  var logic       prev_valid,
  output var logic       this_ready,
  output var logic       this_valid,
  input  var logic       next_ready,
  input  var logic [4:0] input_num,
  output var logic [4:0] output_num
);
  always_ff @(posedge clk) begin
  end
endmodule

module delayer(
  input  var logic       clk,
  input  var logic       reset,
  input  var logic       prev_valid,
  output var logic       this_ready,
  output var logic       this_valid,
  input  var logic       next_ready,
  input  var logic [4:0] input_num,
  output var logic [4:0] output_num
);
  logic [1:0] counter;
  always_ff @(posedge clk) begin
    if(reset) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  always_ff @(posedge clk) begin
    output_num <= input_num;
  end
 `ifdef FORMAL
  logic clocked;
  initial clocked = 0;
  // delay for a cycle before we start counting
  always_ff @(posedge clk) clocked <= reset ? 0 : 1;
  always_ff @(posedge clk) if(clocked && $past(counter) < 2'b11) assert(counter == $past(counter) + 1);
  always_ff @(posedge clk) if(clocked && $past(counter) == 2'b11) assert(counter == 2'b00);
  always_ff @(posedge clk) if(!reset && $past(reset)) assert(counter == 2'b00);
 `endif
endmodule
