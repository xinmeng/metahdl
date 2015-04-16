module req_his_mutable
  (clk, rst_n, 
   init_vld, init_tag, init_his, 
   query_tag, his_valid, his_content,
   update_done, update_vld, update_tag, update_his
   );

`include "common_funcs.vh"

   // - * Parameters
   parameter TAG_COUNT = 8;
   parameter HIS_WIDTH = 4;

   parameter WITH_VALID_BIT = 0;
   parameter TAG_WIDTH = log2(TAG_COUNT);


   // - * Ports
   input     clk, rst_n;

   input [HIS_WIDTH-1:0]   init_his;
   input                   init_vld;
   input [TAG_WIDTH-1:0]   init_tag;

   input [HIS_WIDTH-1:0]   update_his;
   input [TAG_WIDTH-1:0]   update_tag;
   input                   update_done, update_vld;

   output [HIS_WIDTH-1:0]   his_content;
   output                   his_valid;
   input [TAG_WIDTH-1:0]    query_tag;


   // - * Valid Bit map
   generate
      if (WITH_VALID_BIT)  begin: implment_valid_bit_map
         reg [TAG_COUNT-1:0] valid;
         always @(posedge clk or negedge rst_n) begin
            integer i;
            if (!rst_n)
              for (i=0; i<TAG_COUNT; i=i+1)
                valid[i] <= 1'b0;
            else
              for (i=0; i<TAG_COUNT; i=i+1)
                if (init_vld && init_tag == i)
                  valid[i] <= 1'b1;
                else if (update_done && update_vld && update_tag == i)
                  valid[i] <= 1'b0;
                else
                  valid[i] <= valid[i];
         end // always @ (posedge clk or negedge rst_n)
         assign     his_valid   = valid[query_tag];
      end // block: implment_valid_bit_map
      else begin: tie_valid_bit_map
         assign his_valid   = 1'b1;
      end
   endgenerate


   // - * Mutable History
   reg [HIS_WIDTH-1:0] m_his [TAG_COUNT-1:0];
   always @(posedge clk or negedge rst_n) begin
      integer i;
      if (!rst_n)
        for (i=0; i<TAG_COUNT; i=i+1)
          m_his[i] <= {HIS_WIDTH{1'b0}};
      else
        for (i=0; i<TAG_COUNT; i=i+1)
          if (init_vld && init_tag == i)
            m_his[i] <= init_his;
          else if (update_vld && update_tag == i)
            m_his[i] <= update_his;
          else
            m_his[i] <= m_his[i];
   end // always @ (posedge clk or negedge rst_n)


   // -* Query Interface
   assign     his_content = m_his[query_tag];

endmodule
