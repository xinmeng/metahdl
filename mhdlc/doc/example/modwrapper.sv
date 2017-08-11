module modwrapper (
  x0_i1, 
  x0_i2, 
  x0_o1, 
  x1_i1, 
  x1_i2, 
  x1_o1, 
  x2_i1, 
  x2_i2, 
  x2_o1);

parameter SETA = 8;
parameter SETB = 9;

input   [1   :0]  x0_i1;
input   [4   :0]  x0_i2;
output  [6   :0]  x0_o1;
input   [SETA - 1:0]  x1_i1;
input   [SETB - 1:0]  x1_i2;
output  [SETA + SETB - 1:0]  x1_o1;
input   [SETA - 1:0]  x2_i1;
input   [4   :0]  x2_i2;
output  [10  :0]  x2_o1;

logic   [1   :0]  x0_i1;
logic   [4   :0]  x0_i2;
logic   [6   :0]  x0_o1;
logic   [SETA - 1:0]  x1_i1;
logic   [SETB - 1:0]  x1_i2;
logic   [SETA + SETB - 1:0]  x1_o1;
logic   [SETA - 1:0]  x2_i1;
logic   [4   :0]  x2_i2;
logic   [10  :0]  x2_o1;

modc #(
       .A( 2 ),
       .B( 5 ),
       .C( 2 + 5 )	 
      ) x0_modc (
                 .i1 (x0_i1),
                 .i2 (x0_i2),
                 .o1 (x0_o1)
                );

modc #(
       .A( SETA ),
       .B( SETB ),
       .C( SETA + SETB )	 
      ) x1_modc (
                 .i1 (x1_i1),
                 .i2 (x1_i2),
                 .o1 (x1_o1)
                );

modc #(
       .A( SETA ),
       .B( 5 ),
       .C( SETA + 5 )	 
      ) x2_modc (
                 .i1 (x2_i1),
                 .i2 (x2_i2),
                 .o1 (x2_o1[10:0])
                );

endmodule
