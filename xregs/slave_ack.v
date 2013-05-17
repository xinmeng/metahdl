module slave_ack (clk, rst_n, 
		     all_acks, 
		     ack_comb, ack );


   parameter ACK_CNT = 5;

   input clk, rst_n;
   input [ACK_CNT-1:0] all_acks;
   output 	       ack_comb, ack;

   reg 		       ack;


   assign ack_comb = |all_acks;
   always_ff @(posedge clk or negedge rst_n)
     if (!rst_n)
       ack <= 1'b0;
     else
       ack <= ack_comb;
   
endmodule