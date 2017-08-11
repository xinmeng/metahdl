module encode_mux (
		    din,
		    sel,
		    dout
		    );

   parameter WIDTH     = 32;
   parameter CNT       = 5;
   parameter SEL_WIDTH = 3;

   input  [WIDTH*CNT-1:0] din;
   input  [SEL_WIDTH-1:0] sel;
   output [WIDTH-1:0] 	  dout;


   wire [WIDTH-1:0] 	  dout;
   wire [CNT-1:0]         sel_oh;
   
   genvar 		  cnt;

   generate 
      for (cnt=0; cnt<CNT; cnt=cnt+1) begin: create_2d
	 assign sel_oh[cnt] = (sel == cnt) ? 1'b1 : 1'b0;
      end
   endgenerate

   one_hot_mux #(.WIDTH (WIDTH), .CNT (CNT)) 
     one_hot_mux (.din  (din), 
                  .sel  (sel_oh),
                  .dout (dout),
                  .err  ());
endmodule
