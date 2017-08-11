module priority_mux (din, sel, dout);

   parameter WIDTH         = 32;
   parameter CNT           = 5;

   input  [WIDTH*CNT-1:0] din;
   input  [CNT-1:0]       sel;
   output [WIDTH-1:0] dout;

   wire [CNT-1:0]         sel_m1, sel_msk, sel_oh;
   
   assign                 sel_m1  = sel - 1'b1;
   assign                 sel_msk = sel_m1 ^ sel;
   assign                 sel_oh  = sel_msk & sel;

   one_hot_mux #(.WIDTH (WIDTH), .CNT (CNT), .ONE_HOT_CHECK (0))
     x_one_hot_mux (.din  (din),
                    .sel  (sel_oh),
                    .dout (dout),
                    .err  ());
   
   
endmodule
