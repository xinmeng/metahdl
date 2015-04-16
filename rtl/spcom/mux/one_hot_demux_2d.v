module one_hot_demux_2d (
  din,
  sel,
  dout
);

parameter WIDTH = 2;
parameter CNT = 2;

input [WIDTH-1:0] din;
input [CNT-1:0] sel;
output [WIDTH-1:0] dout [CNT-1:0];

genvar i;

generate
  for(i=0; i<CNT; i++) begin: one_hot_demux_loop
    assign dout[i] = sel[i] ? din : {WIDTH{1'b0}};
  end
endgenerate

endmodule
