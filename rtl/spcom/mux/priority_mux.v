module priority_mux (din, sel, dout);

   parameter WIDTH         = 32;
   parameter CNT           = 5;

   input  [WIDTH*CNT-1:0] din;
   input  [CNT-1:0]       sel;
   output [WIDTH-1:0] dout;

   wire [CNT-1:0]     sel_oh; 
   
   right_find_1st_one #(.WIDTH (CNT)) gen_oh_sel
     (.din (sel), .dout (sel_oh));

   one_hot_mux #(.WIDTH (WIDTH), .CNT (CNT), .ONE_HOT_CHECK (0))
     x_one_hot_mux (.din  (din),
                    .sel  (sel_oh),
                    .dout (dout),
                    .err  ());
   
   
endmodule
