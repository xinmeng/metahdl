module right_find_1st_one (din, dout);
   parameter WIDTH = 4;

   output [WIDTH-1:0] dout;
   input [WIDTH-1:0]  din;

   wire [WIDTH-1:0]   din_m1, din_msk;

   assign din_m1  = din - 1'b1;
   assign din_msk = din ^ din_m1;
   assign dout    = din & din_msk;

endmodule
