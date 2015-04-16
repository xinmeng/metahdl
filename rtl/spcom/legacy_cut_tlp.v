module legacy_cut_tlp(
  bcnt,
  last_req,
  ms_pld,
  nxt_bcnt32,
  nxt_sptr,
  sptr,
  tlp_len
);

parameter WITH_RCB = 1;

input   [31:0]  bcnt;                
input   [3 :0]  ms_pld;              
input   [63:0]  sptr;                
output          last_req;            
output  [31:0]  nxt_bcnt32;          
output  [63:0]  nxt_sptr;            
output  [10:0]  tlp_len;             

reg     [31:0]  nxt_bcnt_op1         ;
reg     [57:0]  nxt_sptr_op1         ;
reg     [4 :0]  nxt_sptr_op2         ;
reg     [10:0]  tlp_len              ;
reg     [9 :0]  tlp_len_op1          ;

wire    [31:0]  bcnt                 ;
wire            last_req             ;
wire    [3 :0]  ms_pld               ;
wire    [32:0]  nxt_bcnt             ;
wire    [31:0]  nxt_bcnt32           ;
wire    [63:0]  nxt_sptr             ;
wire    [57:0]  nxt_sptr_tmp         ;
wire            pld_1024b            ;
wire            pld_128b             ;
wire            pld_256b             ;
wire            pld_512b             ;
wire            pld_64b              ;
wire    [63:0]  sptr                 ;
wire            sptr_not_64_boundary ;


assign sptr_not_64_boundary = sptr[5:0] != 6'd0;

generate
   if (WITH_RCB) begin
      assign pld_64b = sptr_not_64_boundary;
      assign pld_128b = ms_pld[0] & ~sptr_not_64_boundary;
      assign pld_256b = ms_pld[1] & ~sptr_not_64_boundary;
      assign pld_512b = ms_pld[2] & ~sptr_not_64_boundary;
      assign pld_1024b = ms_pld[3] & ~sptr_not_64_boundary;
   end
   else begin
      assign pld_64b = 1'b0; //sptr_not_64_boundary;
      assign pld_128b = ms_pld[0];// & ~sptr_not_64_boundary;
      assign pld_256b = ms_pld[1];// & ~sptr_not_64_boundary;
      assign pld_512b = ms_pld[2];// & ~sptr_not_64_boundary;
      assign pld_1024b = ms_pld[3];// & ~sptr_not_64_boundary;
   end
endgenerate

always @( pld_128b
       or pld_1024b
       or sptr[63:0]
       or pld_64b
       or pld_256b
       or pld_512b)
begin
nxt_sptr_op1[57:26]  = sptr[63:32];
`ifdef USE_UNIQUE
unique case(1'b1)
`else
case(1'b1)
`endif
	 pld_64b: begin                 // when address is not on 32 byte boundary
	    tlp_len_op1[9:0]   = { 4'b0000, ~sptr[5:0] };
	    nxt_bcnt_op1[31:0] = {{26{1'b1}}, sptr[5:0]};
	    nxt_sptr_op1[25:0] = sptr[31:6];
	    nxt_sptr_op2[4:0]  = 5'b00001;
	 end
	 pld_128b: begin                 // max payload size is 128B
	    tlp_len_op1[9:0]   = { 3'b000, ~sptr[6:0] };
	    nxt_bcnt_op1[31:0] = {{25{1'b1}}, sptr[6:0]};
	    nxt_sptr_op1[25:0] = {sptr[31:7], 1'b0};
	    nxt_sptr_op2[4:0]  = 5'b00010;
	 end
	 pld_256b: begin                // max payload size is 256B
	    tlp_len_op1[9:0]   = { 2'b00, ~sptr[7:0] };
	    nxt_bcnt_op1[31:0] = {{24{1'b1}}, sptr[7:0]};
	    nxt_sptr_op1[25:0] = {sptr[31:8], 2'b00};
	    nxt_sptr_op2[4:0]  = 5'b00100;
	 end
	 pld_512b: begin                // max payload size is 512B
	    tlp_len_op1[9:0]   = { 1'b0, ~sptr[8:0] };
	    nxt_bcnt_op1[31:0] = {{23{1'b1}}, sptr[8:0]};
	    nxt_sptr_op1[25:0] = {sptr[31:9], 3'b000};
	    nxt_sptr_op2[4:0]  = 5'b01000;
	 end
	 pld_1024b: begin                // max payload size is 1024B
	    tlp_len_op1[9:0]   = ~sptr[9:0];
	    nxt_bcnt_op1[31:0] = {{22{1'b1}}, sptr[9:0]};
	    nxt_sptr_op1[25:0] = {sptr[31:10], 4'b0000};
	    nxt_sptr_op2[4:0]  = 5'b10000;
	 end
	 default:begin   //to propagate X through it's typical full_case
	    tlp_len_op1[9:0]   = {10{1'b0}};    //hifn_fltcov_line_off
	    nxt_bcnt_op1[31:0] = {32{1'b0}};    //hifn_fltcov_line_off
	    nxt_sptr_op1[25:0] = {26{1'b0}};    //hifn_fltcov_line_off
	    nxt_sptr_op2[4:0]  = {5{1'b0}};     //hifn_fltcov_line_off
	 end
  endcase
// &CombEnd; @81
end

assign nxt_sptr_tmp[57:0] = nxt_sptr_op1[57:0] + nxt_sptr_op2[4:0];
assign nxt_sptr[63:0]     = {nxt_sptr_tmp[57:0], 6'b000000};
assign nxt_bcnt[32:0]     = bcnt[31:0] + nxt_bcnt_op1[31:0];
assign nxt_bcnt32[31:0]   = nxt_bcnt[31:0];

assign last_req = !nxt_bcnt[32] || ( nxt_bcnt[32] && ~(|nxt_bcnt[31:0]) );
// &CombBeg; @89
always @( pld_128b
       or pld_1024b
       or tlp_len_op1[9:0]
       or nxt_bcnt[32]
       or bcnt[10:0]
       or pld_64b
       or pld_256b
       or pld_512b)
begin
tlp_len[10:0]  = tlp_len_op1[9:0] + 1'b1;
`ifdef USE_UNIQUE
unique case(1'b1)
`else
case(1'b1)
`endif
	 pld_64b: begin                // when address is not on 32 byte boundary
	 //Hifn xCheck Off
	    if(nxt_bcnt[32]) begin  
// mutiple TLPs or the TLP ends at 64B boundary
	 //Hifn xCheck On
	    end
	    else begin
	       tlp_len[10:0] = bcnt[10:0];
	    end
	 end
	 pld_128b: begin                // max payload size is 128B
	 //Hifn xCheck Off
	    if(nxt_bcnt[32]) begin  
// mutiple TLPs or the TLP ends at 128B boundary
	 //Hifn xCheck On
	    end
	    else begin
	       tlp_len[10:0] = bcnt[10:0];
	    end
	 end
	 pld_256b: begin                // max payload size is 256B
	 //Hifn xCheck Off
	    if(nxt_bcnt[32]) begin  
// mutiple TLPs or the TLP ends at 128B boundary
	 //Hifn xCheck On
	    end
	    else begin
	       tlp_len[10:0] = bcnt[10:0];
	    end
	 end
	 pld_512b: begin                // max payload size is 512B
	 //Hifn xCheck Off
	    if(nxt_bcnt[32]) begin 
 // mutiple TLPs or the TLP ends at 128B boundary
	 //Hifn xCheck On
	    end
	    else begin
	       tlp_len[10:0] = bcnt[10:0];
	    end
	 end
	 pld_1024b: begin                // max payload size is 1024B
	 //Hifn xCheck Off
	    if(nxt_bcnt[32]) begin 
 // mutiple TLPs or the TLP ends at 128B boundary
	 //Hifn xCheck On
	    end
	    else begin
	       tlp_len[10:0] = bcnt[10:0];
	    end
	 end
	 default: tlp_len[10:0] = {11{1'b0}};   //hifn_fltcov_line_off
       endcase
end

endmodule



