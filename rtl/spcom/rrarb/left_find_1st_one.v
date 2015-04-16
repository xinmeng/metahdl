module left_find_1st_one (din, dout);
   parameter WIDTH = 4;

   input [WIDTH-1:0] din;
   output [WIDTH-1:0] dout;


   wire [WIDTH-1:0]   din_r, dout_r;

   genvar          i;
   generate
      for (i=0; i<WIDTH; i=i+1) begin: reverse_din
         assign din_r[i] = din[WIDTH-1-i];
      end
   endgenerate

   right_find_1st_one #(.WIDTH (WIDTH))
     right_find_1st_one (.din (din_r), 
                         .dout (dout_r));

   generate
      for (i=0; i<WIDTH; i=i+1) begin: reverse_dout
         assign dout[i] = dout_r[WIDTH-1-i];
      end
   endgenerate

endmodule
