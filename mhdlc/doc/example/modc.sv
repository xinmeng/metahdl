module modc (
  i1, 
  i2, 
  o1);

parameter A = 4;
parameter B = 5;
parameter C = 4 + 5;

input   [A    - 1:0]  i1;
input   [B    - 1:0]  i2;
output  [C    - 1:0]  o1;

logic   [A    - 1:0]  i1;
logic   [B    - 1:0]  i2;
logic   [C    - 1:0]  o1;

assign o1[C - 1:0] = {~i1[A - 1:0], i2[B - 1:0]};

endmodule
