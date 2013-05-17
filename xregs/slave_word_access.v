module slave_word_access(clk, rst_n,
		   ack_comb, abort,
		   address, request,
		   external_ack, 
		   qualified_req, qualified_ack);

   parameter ADDR_WIDTH = 16; 	// word address, NOT byte address
   parameter WORD_ADDR  = 16'd0;
   parameter NEED_EXTERNAL_ACK = 0;

   input clk, rst_n;
   input [ADDR_WIDTH-1:0] address;
   input 		  request, external_ack;
   input 		  ack_comb, abort; 		  
   output 		  qualified_req, qualified_ack;

   reg 			  qualified_req;


   always_ff @(posedge clk or negedge rst_n)
     if (!rst_n)
       qualified_req <= 1'b0;
     else if (ack_comb || abort)
       qualified_req <= 1'b0; 
     else if (request)
       qualified_req <= (address == WORD_ADDR);
     else
       qualified_req <= 1'b0;



   generate
      if (NEED_EXTERNAL_ACK) begin:g_need_external_ack
	 assign qualified_ack = qualified_req & external_ack;
      end
      else begin:g_immediate_ack
	 assign qualified_ack = qualified_req;
      end
   endgenerate


endmodule
