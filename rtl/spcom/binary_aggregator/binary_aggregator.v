module binary_aggregator (clk, rst_n, 
                          candidate_vld, candidate_key, candidate_data, 
                          winner_vld, winner_key, winnder_data);

   parameter CANDIDATE_CNT = 5;
   parameter KEY_WIDTH     = 6;
   parameter DATA_WIDTH    = 16;
   

   input clk, rst_n;
   input [CANDIDATE_CNT-1:0]            candidate_vld;
   input [CANDIDATE_CNT*KEY_WIDTH-1:0]  candidate_key;
   input [CANDIDATE_CNT*DATA_WIDTH-1:0] candidate_data;
   output                               winner_vld;
   output [KEY_WIDTH-1:0]               winnder_key;
   output [DATA_WIDTH-1:0]              winner_data;

   reg [KEY_WIDTH-1:0]                 candidate_key_2d [CANDIDATE_CNT-1:0];
   reg [DATA_WIDTH-1:0]                candidate_data_2d [CANDIDATE_CNT-1:0];

   always @(*) begin
      integer i;
      for (i=0; i<CANDIDATE_CNT; i=i+1) begin
         candidate_key_2d[i]  = candidate_key[i*KEY_WIDTH +: KEY_WIDTH];
         candidate_data_2d[i] = candidate_data[i*DATA_WIDTH +: DATA_WIDTH];
      end
   end


   binary_aggregator_2d
     #(.CANDIDATE_CNT (CANDIDATE_CNT), 
       .KEY_WIDTH (KEY_WIDTH), 
       .DATA_WIDTH (DATA_WIDTH)) 
       binary_aggregator_2d 
     (.clk (clk), .rst_n (rst_n),

      .candidate_vld (candidate_vld), 
      .candidate_key (candidate_key_2d), 
      .candidate_data (candidate_data_2d),
      
      .winner_vld (winner_vld),
      .winner_key (winner_key), 
      .winner_data (winner_data)
      );

endmodule // binary_aggregator

