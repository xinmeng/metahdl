module req_his_immutable
  (clk, rst_n, 
   init_vld, init_tag, init_his,
   query_tag, his_valid, his_content,
   update_vld, update_tag
   );

`include "common_funcs.vh"

   // - * Parameters
   parameter TAG_COUNT = 8;
   parameter HIS_WIDTH = 4;

   parameter HIS_WIDTH_I = (HIS_WIDTH ? HIS_WIDTH : 1);

   parameter TAG_WIDTH = log2(TAG_COUNT);

   // - * Ports
   input     clk, rst_n;

   input [HIS_WIDTH_I-1:0] init_his;
   input                 init_vld;
   input [TAG_WIDTH-1:0] init_tag;

   output [HIS_WIDTH_I-1:0] his_content;
   output                 his_valid;
   input [TAG_WIDTH-1:0]  query_tag;

   input [TAG_WIDTH-1:0]  update_tag;
   input                  update_vld;

   // - * Valid Bit map
   reg [TAG_COUNT-1:0]    valid;
   always @(posedge clk or negedge rst_n) begin
      integer i;
      if (!rst_n)
        for (i=0; i<TAG_COUNT; i=i+1)
          valid[i] <= 1'b0;
      else
        for (i=0; i<TAG_COUNT; i=i+1)
          if (init_vld && init_tag == i)
            valid[i] <= 1'b1;
          else if (update_vld && update_tag == i)
            valid[i] <= 1'b0;
          else
            valid[i] <= valid[i];
   end // always @ (posedge clk or negedge rst_n)


         reg [HIS_WIDTH_I-1:0] i_his [TAG_COUNT-1:0];
   // -* History
   generate
      if (HIS_WIDTH) begin  
         always @(posedge clk or negedge rst_n) begin
            integer i;
            if (!rst_n)
              for (i=0; i<TAG_COUNT; i=i+1)
                i_his[i] <= {HIS_WIDTH_I{1'b0}};
            else
              for (i=0; i<TAG_COUNT; i=i+1)
                if (init_vld && init_tag == i)
                  i_his[i] <= init_his;
                else
                  i_his[i] <= i_his[i];
         end // always @ (posedge clk or negedge rst_n)
      end // if (HIS_WIDTH)
   endgenerate


   // -* Query Interface
   assign     his_valid   = valid[query_tag];

   generate
      if (HIS_WIDTH)  begin
         assign his_content = i_his[query_tag];
      end
      else begin
         assign his_content = 1'b0;
      end
  endgenerate

endmodule
