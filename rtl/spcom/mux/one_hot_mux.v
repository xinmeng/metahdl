module one_hot_mux (
		    din,
		    sel,
		    dout,
		    err
		    );

   parameter WIDTH         = 32;
   parameter CNT           = 5;
   parameter ONE_HOT_CHECK = 0;

   input  [WIDTH*CNT-1:0] din;
   input  [CNT-1:0] 	  sel;
   output [WIDTH-1:0] 	  dout;
   output 		  err;

   wire [WIDTH-1:0]       din_2d[CNT-1:0];
   genvar 		  cnt, w;

   generate 
      for (cnt=0; cnt<CNT; cnt=cnt+1) begin: create_2d
	 assign din_2d[cnt] = sel[cnt] ? din[cnt*WIDTH +: WIDTH] : {WIDTH{1'b0}};
      end
   endgenerate

   one_hot_mux_2d #(.WIDTH (WIDTH), .CNT (CNT), .ONE_HOT_CHECK (ONE_HOT_CHECK))
     one_hot_mux_2d 
       (.din (din_2d),
        .sel (sel), 
        .dout (dout), 
        .err (err));

endmodule
