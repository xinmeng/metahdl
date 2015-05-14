module a (
  b, 
  c, 
  clk, 
  rst_n);

parameter A = 3;

input   [1   :0]  b;
output  [1   :0]  c;
input             clk;
input             rst_n;

reg     [1   :0]  a;
wire    [1   :0]  b;
reg     [1   :0]  c;
wire              clk;
wire              i;
wire              j;
wire              rst_n;

always @(*)  begin
  integer i
  for (i = 0; i < A; i = i + 1)
    a[i] = b;
end

always @(posedge clk or negedge rst_n) begin
  integer i;
  integer j;
  if ( !rst_n )
    for (i = 0; i < 100; i = i + 1)
      a[i] <= b[i];
  else
    for (j = 0; j < 100; j = j + 1)
      c[j] <= a[i];
end

endmodule
