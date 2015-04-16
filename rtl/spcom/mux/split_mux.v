// - \insertfigure{Split MUX structure}{split-mux}{fig:split-mux}
module split_mux (clk, rst_n, 
                  din, sel, dout_vld, dout);
   parameter WIDTH         = 32;
   parameter CNT           = 31;
   parameter GROUP_SIZE    = 128;

   localparam GROUP_COUNT   = CNT / GROUP_SIZE; // calc(CNT, GROUP_SIZE, 0);
   localparam REM_MUX_SIZE  = CNT % GROUP_SIZE; // calc(CNT, GROUP_SIZE, 1);
   localparam HAS_REM_MUX   = REM_MUX_SIZE ? 1 : 0;

   input     clk, rst_n;
   input [CNT-1:0] sel;
   input [WIDTH*CNT-1:0] din;
   output reg                dout_vld;
   output reg [WIDTH-1:0]    dout;

   reg [(GROUP_COUNT+HAS_REM_MUX)*WIDTH-1:0] level_1_dout;
   reg [GROUP_COUNT+HAS_REM_MUX-1 :0]        level_1_sel;

   genvar i;

   // - *Level-1 MUX group
   generate
      for (i=0; i<GROUP_COUNT; i=i+1) begin:g_group_mux
         one_hot_mux_ff #(.WIDTH (WIDTH), .CNT (GROUP_SIZE)) 
           l1_full_size_mux (.din     (din[i*GROUP_SIZE*WIDTH +: GROUP_SIZE*WIDTH]), 
                             .sel     (sel[i*GROUP_SIZE       +: GROUP_SIZE]), 
                             .dout_ff (level_1_dout[i*WIDTH   +: WIDTH]), 
                             .sel_ff  (level_1_sel[i]), 
                             .clk     (clk),
                             .rst_n   (rst_n));
      end
      
      if (HAS_REM_MUX) begin:g_remainder_mux
         one_hot_mux_ff #(.WIDTH (WIDTH), .CNT (REM_MUX_SIZE)) 
           l1_remainder_mux (.din     (din[WIDTH*CNT-1  -: REM_MUX_SIZE*WIDTH]), 
                             .sel     (sel[CNT-1        -: REM_MUX_SIZE]), 
                             .dout_ff (level_1_dout[(GROUP_COUNT+HAS_REM_MUX)*WIDTH-1 -: WIDTH]), 
                             .sel_ff  (level_1_sel[GROUP_COUNT+HAS_REM_MUX-1]), 
                             .clk     (clk),
                             .rst_n   (rst_n));
      end
   endgenerate

   // - * Level-2 MUX
   generate
      if (GROUP_COUNT + HAS_REM_MUX > 1) begin: g_has_level2_mux
      one_hot_mux_ff #(.WIDTH (WIDTH), .CNT (GROUP_COUNT+HAS_REM_MUX))
        l2_one_hot_mux_ff (.din     (level_1_dout), 
                           .sel     (level_1_sel), 
                           .dout_ff (dout), 
                           .sel_ff  (dout_vld), 
                           .clk     (clk),
                           .rst_n   (rst_n)
                           );
      end
      else begin: g_no_level2_mux
         assign dout     = level_1_dout;
         assign dout_vld = level_1_sel;
      end
   endgenerate


   // function int unsigned calc(int unsigned count,
   //                            int unsigned size,
   //                            int unsigned selection
   //                            );
   //    int unsigned last_mux_cnt, group_count;
   //    while (count) begin
   //       if (count >= size) begin
   //          count -= size;
   //          last_mux_cnt = 0;
   //          group_count += 1;
   //       end
   //       else begin
   //          last_mux_cnt = count;
   //          count = 0;
   //       end
   //    end

   //    if (selection == 0)
   //      calc = group_count;
   //    else if (selection == 1)
   //      calc = last_mux_cnt;
   // endfunction

endmodule
