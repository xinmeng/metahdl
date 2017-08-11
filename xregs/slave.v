   parameter W_WIDTH = 32;
   parameter A_WIDTH = 16;
   parameter W_CNT   = 5;
   parameter WRITABLE_W_CNT = 3;


   slave_word_access #(A_WIDTH, 16'd0) 
   rd_wa_0 (.clk (clk), .rst_n (),
	    .ack_comb (ack_comb), .abort (abort), 
	    .address  (address),  .request (rd_req), 
	    .external_ack (), 
	    .qualified_req (rd_word_0), 
	    .qualified_ack (rd_word_0_ack)
	    );


   slave_word_access #(A_WIDTH, 16'd4, 1)
   rd_wa_4 (.clk (clk), .rst_n (),
	    .ack_comb (ack_comb), .abort (abort), 
	    .address  (address),  .request (rd_req), 
	    .external_ack (ext_mem_rd_ack), 
	    .qualified_req (rd_word_4), 
	    .qualified_ack (rd_word_4_ack)
	    );
   



   assign all_acks = {rd_word_0_ack, rd_word_4_ack, wr_word_4_ack};
   slave_ack #(W_CNT+3)
   slave_ack (.clk (clk), .rst_n (rst_n), 
	      .all_acks (all_acks), 
	      .ack_comb (ack_comb), .ack (ack)
	      );
   


   assign all_words[W_WIDTH*W_CNT-1:0] = {W_WIDTH*W_CNT{1'b0}};
   assign rd_words[W_CNT-1:0] = {W_CNT{1'b0}};
   slave_mux #(W_WIDTH, W_CNT)
   slave_mux (.clk (clk), .rst_n (rst_n),
	      .all_words (all_words), .rd_words (rd_words), 
	      .rd_data (rd_data)
	      );



