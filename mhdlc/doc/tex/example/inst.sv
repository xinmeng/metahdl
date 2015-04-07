module inst (
  i1, 
  i2, 
  in1, 
  in2, 
  o1, 
  o2, 
  out1, 
  out2, 
  x1_i1, 
  x1_i2, 
  x1_o1, 
  x1_o2, 
  x2_i1_22, 
  x2_i2_22, 
  x2_o1_22, 
  x2_o2_22);


input             i1;
input             i2;
input             in1;
input             in2;
output            o1;
output  [1   :0]  o2;
output            out1;
output  [1   :0]  out2;
input             x1_i1;
input             x1_i2;
output            x1_o1;
output  [1   :0]  x1_o2;
input             x2_i1_22;
input             x2_i2_22;
output            x2_o1_22;
output  [1   :0]  x2_o2_22;

logic             i1;
logic             i2;
logic             in1;
logic             in2;
logic             o1;
logic   [1   :0]  o2;
logic             out1;
logic   [1   :0]  out2;
logic             x1_i1;
logic             x1_i2;
logic             x1_o1;
logic   [1   :0]  x1_o2;
logic             x2_i1_22;
logic             x2_i2_22;
logic             x2_o1_22;
logic   [1   :0]  x2_o2_22;

moda x_moda (
                .i1 (i1),
                .i2 (i2),
                .o1 (o1),
                .o2 (o2)
            );

moda x1_moda (
                 .i1 (x1_i1),
                 .i2 (x1_i2),
                 .o1 (x1_o1),
                 .o2 (x1_o2)
             );

moda x2_moda (
                 .i1 (x2_i1_22),
                 .i2 (x2_i2_22),
                 .o1 (x2_o1_22),
                 .o2 (x2_o2_22)
             );

moda x3_moda (
                 .i1 (in1),
                 .i2 (in2),
                 .o1 (out1),
                 .o2 (out2)
             );

endmodule
