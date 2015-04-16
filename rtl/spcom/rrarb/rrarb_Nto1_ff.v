module rrarb_Nto1_ff (clk, rst_n, 
                      req, 
                      grant, grant_ff, 
                      switch_to_next);
   parameter REQ_CNT = 4;

   input     clk, rst_n;
   input     switch_to_next;

   output [REQ_CNT-1:0] grant, grant_ff;
   input [REQ_CNT-1:0]  req;

   wire [REQ_CNT-1:0]   req_wo_grant, grant;
   reg [REQ_CNT-1:0]    grant_ff;
   wire                 no_grant;
   wire                 stn_internal;

   // - * Glue Logic
   assign req_wo_grant = req & (~grant_ff);
   assign no_grant     = ~|grant_ff;
   assign stn_internal = no_grant | switch_to_next; // internal switch to next

   // - * Instantiation
   rrarb_Nto1 #(.REQ_CNT(REQ_CNT)) rrarb_Nto1(.clk (clk), .rst_n (rst_n),
                         .switch_to_next (stn_internal),
                         .req (req_wo_grant), .grant (grant));

   // - * Flop out
   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       grant_ff <= {REQ_CNT{1'b0}};
     else if (stn_internal)
       grant_ff <= grant;
     else
       grant_ff <= grant_ff;

endmodule
