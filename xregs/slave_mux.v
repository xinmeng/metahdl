module slave_mux (clk, rst_n, 
		  rd_req, 
		  all_words, rd_words, 
		  rd_data);

   parameter W_WIDTH = 32;
   parameter W_CNT   = 5;

   input clk, rst_n;
   input rd_req;
   input [W_WIDTH*W_CNT-1:0] all_words;
   input [W_CNT-1:0] 	     rd_words;
   output [W_WIDTH-1:0]      rd_data;

   wire [W_WIDTH-1:0] 	     rd_data_comb;
   reg [W_WIDTH-1:0] 	     rd_data;

   one_hot_mux #(.WIDTH (W_WIDTH), .CNT (W_CNT))
   rd_data_mux (.din  (all_words), 
		.sel  (rd_words),
		.dout (rd_data_comb),
		.err  ());

   always_ff @(posedge clk or negedge rst_n)
     if (!rst_n)
       rd_data[W_WIDTH-1:0] <= {W_WIDTH{1'b0}};
     else if (rd_req)
       rd_data[W_WIDTH-1:0] <= rd_data_comb[W_WIDTH-1:0];
     else
       rd_data[W_WIDTH-1:0] <= rd_data[W_WIDTH-1:0];

endmodule   