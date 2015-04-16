// - \insertfigure{Algorithmetic view of Round Robin design}{rrarb_Nto1}{fig:rrarb_Nto1}

module rrarb_Nto1 (clk, rst_n,
                   req, grant, 
                   switch_to_next );

   parameter REQ_CNT = 4;

   input     clk, rst_n;
   input     switch_to_next;
   
   output [REQ_CNT-1:0] grant;
   input [REQ_CNT-1:0]  req;

   wire [REQ_CNT-1:0]   req_hi_mskd, req_lo_mskd,
                        hi_msk_hi_nxt, hi_msk_lo_nxt,
                        lo_msk_hi_nxt, lo_msk_lo_nxt,
                        msk_hi_nxt, msk_lo_nxt,
                        grant_hi, grant_lo;

   reg [REQ_CNT-1:0]    msk_hi, msk_lo;

   // - * Logic
   assign req_hi_mskd = req & msk_hi;
   assign req_lo_mskd = req & msk_lo;

   wire   has_req_hi;
   assign has_req_hi    = |req_hi_mskd;
   assign hi_msk_lo_nxt = req_hi_mskd ^ (req_hi_mskd - 1'b1);
   assign hi_msk_hi_nxt = ~hi_msk_lo_nxt;
   assign grant_hi      = req_hi_mskd & hi_msk_lo_nxt;


   wire   has_req_lo;
   assign has_req_lo    = |req_lo_mskd;
   assign lo_msk_lo_nxt = req_lo_mskd ^ (req_lo_mskd - 1'b1);
   assign lo_msk_hi_nxt = ~lo_msk_lo_nxt;
   assign grant_lo      = req_lo_mskd & lo_msk_lo_nxt;

   assign grant = has_req_hi ? grant_hi : 
		  has_req_lo ? grant_lo : {REQ_CNT{1'b0}};

   assign msk_hi_nxt = has_req_hi ? hi_msk_hi_nxt : 
		       has_req_lo ? lo_msk_hi_nxt : msk_hi;

   assign msk_lo_nxt = has_req_hi ? hi_msk_lo_nxt : 
		       has_req_lo ? lo_msk_lo_nxt : msk_lo;

   // - * Mask
   always @(posedge clk or negedge rst_n)
     if ( ~rst_n ) begin
        msk_hi <= {REQ_CNT{1'b1}};
        msk_lo <= {REQ_CNT{1'b0}};
     end
     else if ( switch_to_next ) begin
        msk_hi <= msk_hi_nxt;
        msk_lo <= msk_lo_nxt;
     end
     else begin
        msk_hi <= msk_hi;
        msk_lo <= msk_lo;
     end

endmodule
