`include "common_funcs.vh"

module count_ones (clk, rst_n, enable, din, dout);
   parameter WIDTH  = 16;
   parameter STAGE  = 16;
   parameter FF_OUT = 1;

   input  [WIDTH-1:0] din;
   output [WIDTH-1:0] dout;
   input           clk, rst_n;
   input           enable;

   localparam      LEVEL = log2(WIDTH);

   reg  [WIDTH-1:0]    dout;
   wire [WIDTH-1:0]    mask [0:LEVEL-1];
   reg  [WIDTH-1:0]     cnt[0:LEVEL];
   reg  [WIDTH-1:0]      vld[0:LEVEL];

   always @(*) begin
      cnt[0] = din;
      vld[0] = enable;
   end

   genvar i;
   generate
      for (i=0; i<LEVEL; i=i+1) begin:partial_cnt
         // segment_width: 2**level
         // segment_count: WIDTH/segment_width/2
         assign mask[i] = {(WIDTH/2**i/2){{(2**i){1'b0}}, {(2**i){1'b1}}}};
         if ( ((i+1) % STAGE) == 0 ) begin: ff_stage
            always @(posedge clk or negedge rst_n)
              if (!rst_n) begin
                 vld[i+1] <= 1'b0;
                 cnt[i+1] <= {WIDTH{1'b0}};
              end
              else begin
                 vld[i+1] <= vld[i];
                 cnt[i+1] <= (cnt[i] & mask[i]) + 
                             ({{(2**i){1'b0}}, cnt[i][WIDTH-1: (2**i)]} & mask[i]);
              end
         end // block: ff_stage
         else begin:comb_stage
            always @(*) begin
               vld[i+1] = vld[i];
               cnt[i+1] = (cnt[i] & mask[i]) + 
                          ({{(2**i){1'b0}}, cnt[i][WIDTH-1: (2**i)]} & mask[i]);
            end
         end
      end
   endgenerate

   generate
      if (FF_OUT) begin:flop_out
         always @(posedge clk or negedge rst_n)
           if (~rst_n)
             dout <= {WIDTH{1'b0}};
           else
             dout <= vld[LEVEL] ? cnt[LEVEL] : {WIDTH{1'b0}};
      end
      else begin: comb_out
         assign dout = vld[LEVEL] ? cnt[LEVEL] : {WIDTH{1'b0}};
      end
endmodule
