module one_hot_mux (
		    din,
		    sel,
		    dout,
		    err
		    );

   parameter WIDTH = 32;
   parameter CNT = 5;

   input  [WIDTH*CNT-1:0] din;
   input  [CNT-1:0] 	  sel;
   output [WIDTH-1:0] 	  dout;

   output 		  err;
   wire 		  err;

   wire [WIDTH-1:0] 	  data_2d [0:CNT-1];
   wire [CNT-1:0] 	  data_2d_t [0:WIDTH-1];
   wire [WIDTH-1:0] 	  dout;
   

   genvar 		  cnt;
   genvar 		  w;

   generate 
      for (cnt=0; cnt<CNT; cnt=cnt+1) begin: create_2d
	 assign data_2d[cnt] = din[(cnt+1)*WIDTH-1:cnt] & {WIDTH{sel[cnt]}};
      end
   endgenerate

   generate
      for (cnt=0; cnt<CNT; cnt=cnt+1) begin: transform_2d_outter
	 for (w=0; w<WIDTH; w=w+1) begin: transform_2d_inner
	    assign data_2d_t[w][cnt] = data_2d[cnt][w];
	 end
      end
   endgenerate

   generate
      for (w=0; w<WIDTH; w=w+1) begin: or_all_din
	 assign dout[w] = |data_2d_t[w];
      end
   endgenerate


   wire [WIDTH-1:0] sel_m1, sel_msk;
   assign sel_m1  = sel - 1'b1;
   assign sel_msk = ~(sel_m1 ^ sel);
   assign err     = |(sel_msk & sel);
      
endmodule