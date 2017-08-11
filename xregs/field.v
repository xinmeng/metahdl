module field (hw_pulse, hw_value, 
              sw_rd, sw_wr, sw_wr_data,
              field_value,
              ext_clear_type_ctrl,
              ext_write_en,
              clk, rst_n, sync_rst);

   localparam SW_RW   = 0;
   localparam SW_RO   = 1;
   localparam SW_RW1C = 2;
   localparam SW_RW1S = 3;
   localparam SW_ROC  = 4;
   localparam SW_ConC = 5;
   localparam SW_WonC = 6;

   localparam HW_PS = 0;
   localparam HW_PC = 1;
   localparam HW_PI = 2;
   localparam HW_PD = 3;
   localparam HW_SV = 4;
   localparam HW_HW = 5;


   parameter F_WIDTH   = 4;
   parameter S_CNT     = 3;
   parameter RST_VALUE = 4'd0;
   parameter HAS_SYNC_RST = 1;
   parameter WR_PRIORITY = 0;   // 0: HW, 1: SW
   parameter SW_TYPE     = SW_RW;
   parameter HW_TYPE     = HW_PI;



   input clk, rst_n, sync_rst;

   input [F_WIDTH-1:0] hw_value;
   input               hw_pulse;

   input [F_WIDTH*S_CNT-1:0] sw_wr_data;
   input [S_CNT-1:0]         sw_rd, sw_wr;
   input                     ext_clear_type_ctrl, ext_write_en;

   output [F_WIDTH-1:0]      field_value;
   reg [F_WIDTH-1:0] 	     field_value;    

   wire                      sw_modify;
   wire [F_WIDTH-1:0]        sw_mux_value, nxt_sw_value;

   // ------------------------------
   //   SW control
   // ------------------------------
   generate
      if (HW_TYPE != HW_HW)
	case (SW_TYPE)
          SW_RW: begin:g_SW_RW
             assign sw_modify = |sw_wr;
             priority_mux #(.WIDTH(F_WIDTH), .CNT (S_CNT)) 
	     sw_mux (.din (sw_wr_data), 
                     .sel (sw_wr),
                     .dout (sw_mux_value));

             assign nxt_sw_value = sw_mux_value;
          end

          SW_RO: begin:g_SW_RO
             assign sw_modify = 1'b0;
             assign nxt_sw_value = field_value;
          end

          SW_RW1C: begin:g_SW_RW1C
             assign sw_modify = |sw_wr;
             priority_mux #(.WIDTH(F_WIDTH), .CNT (S_CNT)) 
	     sw_mux (.din (sw_wr_data), 
                     .sel (sw_wr),
                     .dout (sw_mux_value));

             assign nxt_sw_value = field_value & (~sw_mux_value);
          end

          SW_RW1S: begin:g_SW_RW1S
             assign sw_modify = |sw_wr;
             priority_mux #(.WIDTH(F_WIDTH), .CNT (S_CNT)) 
	     sw_mux (.din (sw_wr_data), 
                     .sel (sw_wr),
                     .dout (sw_mux_value));

             assign nxt_sw_value = field_value | sw_mux_value;
          end

          SW_ROC: begin:g_SW_ROC
             assign sw_modify = |sw_rd;
             assign nxt_sw_value = {F_WIDTH{1'b0}};
          end

          SW_ConC: begin:g_SW_ConC
             assign sw_modify = ext_clear_type_ctrl ? |sw_wr : |sw_rd;
             priority_mux #(.WIDTH(F_WIDTH), .CNT (S_CNT)) 
	     sw_mux (.din (sw_wr_data), 
                     .sel (sw_wr),
                     .dout (sw_mux_value));

             assign nxt_sw_value = ext_clear_type_ctrl ? 
                                   field_value & (~sw_mux_value) : {F_WIDTH{1'b0}};
          end
          
          SW_WonC: begin:g_SW_WonC
             assign sw_modify = ext_write_en ? |sw_wr : 1'b0;
             priority_mux #(.WIDTH(F_WIDTH), .CNT (S_CNT)) 
	     sw_mux (.din (sw_wr_data), 
                     .sel (sw_wr),
                     .dout (sw_mux_value));

             assign nxt_sw_value = ext_write_en ? 
				   sw_mux_value : field_value;
          end
	endcase
   endgenerate



   

   // ------------------------------
   //    Hardware control
   // ------------------------------
   wire [F_WIDTH-1:0] nxt_hw_value;
   wire               hw_modify;

   assign hw_modify = hw_pulse;
   generate
      case (HW_TYPE)
        HW_PS: begin:g_HW_PS
           assign nxt_hw_value = {F_WIDTH{1'b1}};
        end

        HW_PC: begin:g_HW_PC
           assign nxt_hw_value = {F_WIDTH{1'b0}};
        end

        HW_PI: begin:g_HW_PI
           assign nxt_hw_value = field_value + 1'b1;
        end

        HW_PD: begin:g_HW_PD
           assign nxt_hw_value = field_value - 1'b1;
        end

        HW_SV, HW_HW: begin:g_HW_SV_HW
           assign nxt_hw_value = hw_value;
        end
      endcase // case (HW_TYPE)
   endgenerate



   // ------------------------------
   //  ultimate mux
   // ------------------------------
   generate
      wire new_value_update;
      if (HW_TYPE == HW_HW) begin:hard_wired
	 always_ff @(posedge clk or negedge rst_n)
	   if (!rst_n)
	     field_value <= RST_VALUE;
	   else
	     field_value <= hw_value;
      end
      else begin:ultimate_mux
	 wire [F_WIDTH-1:0] 	 nxt_field_value;

	 if (HAS_SYNC_RST) begin:with_synchrous_reset
	    wire [F_WIDTH*3-1:0] all_nxt_value;
	    wire [2:0] 		 all_modify;	      
	    
	    assign all_nxt_value = WR_PRIORITY ? 
				   {nxt_hw_value, nxt_sw_value, RST_VALUE} : 
				   {nxt_sw_value, nxt_hw_value, RST_VALUE};
	    assign all_modify    = WR_PRIORITY ?
				   {hw_modify, sw_modify, sync_rst} :
				   {sw_modify, hw_modify, sync_rst};
	    assign new_value_update = |all_modify;
	    
	    priority_mux #(.WIDTH (F_WIDTH), .CNT (3)) 
	    nxt_value_mux (.din (all_nxt_value),
			   .sel (all_modify),
			   .dout (nxt_field_value));
	 end
	 else begin:without_synchronous_reset
	    wire [F_WIDTH*2-1:0] all_nxt_value;
	    wire [1:0] 		 all_modify;	      
	    
	    assign all_nxt_value = WR_PRIORITY ? 
				   {nxt_hw_value, nxt_sw_value} : 
				   {nxt_sw_value, nxt_hw_value};
	    assign all_modify    = WR_PRIORITY ?
				   {hw_modify, sw_modify} :
				   {sw_modify, hw_modify};
	    assign new_value_update = |all_modify;
	    
	    priority_mux #(.WIDTH (F_WIDTH), .CNT (2)) 
	    nxt_value_mux (.din (all_nxt_value),
			   .sel (all_modify),
			   .dout (nxt_field_value));
	 end

	 always_ff @(posedge clk or negedge rst_n)
	   if (!rst_n)
	     field_value <= RST_VALUE;
	   else if (new_value_update)
	     field_value <= nxt_field_value;
	   else
	     field_value <= field_value;
      end
   endgenerate
	 
endmodule
