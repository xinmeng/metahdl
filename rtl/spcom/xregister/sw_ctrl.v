`include "xregister.vh"

module sw_ctrl (field_value, 
		sw_wr, sw_rd, sw_wr_data, sw_type_alter_signal, 
                nxt_sw_value, sw_modify );

   parameter F_WIDTH = 4;
   parameter SW_CNT  = 1;
   parameter SW_TYPE = `SW_RW;

   input logic [F_WIDTH-1:0]          field_value;
   input logic [F_WIDTH*SW_CNT-1:0]   sw_wr_data;
   input logic [SW_CNT-1:0] 	      sw_wr, sw_rd;
   input logic 			      sw_type_alter_signal;

   output logic [F_WIDTH-1:0] 	      nxt_sw_value;
   output logic 		      sw_modify;

   logic [F_WIDTH-1:0] 		      sw_mux_value;

   generate
      if (SW_TYPE == `SW_RO) begin: g_SW_RO
         assign sw_modify    = 1'b0;
         assign nxt_sw_value = field_value;
      end
      else if (SW_TYPE == `SW_RW) begin: g_SW_RW
         assign sw_modify = |sw_wr;
         priority_mux #(.WIDTH(F_WIDTH), .CNT (SW_CNT)) sw_mux
           (.din (sw_wr_data), 
            .sel (sw_wr),
            .dout (sw_mux_value));
         assign nxt_sw_value = sw_mux_value;
      end
      else if (SW_TYPE == `SW_RW1C) begin:g_SW_RW1C
         assign sw_modify = |sw_wr;
         priority_mux #(.WIDTH(F_WIDTH), .CNT (SW_CNT)) sw_mux
           (.din (sw_wr_data), 
            .sel (sw_wr),
            .dout (sw_mux_value));
         assign nxt_sw_value = field_value & (~sw_mux_value);
      end
      else if (SW_TYPE == `SW_RW1S) begin:g_SW_RW1S
         assign sw_modify = |sw_wr;
         priority_mux #(.WIDTH(F_WIDTH), .CNT (SW_CNT)) sw_mux
           (.din (sw_wr_data), 
            .sel (sw_wr),
            .dout (sw_mux_value));
         assign nxt_sw_value = field_value | sw_mux_value;
      end
      else if (SW_TYPE == `SW_ROC) begin:g_SW_ROC
         assign sw_modify = |sw_rd;
         assign nxt_sw_value = {F_WIDTH{1'b0}};
      end
      else if (SW_TYPE == `SW_ConC) begin:g_SW_ConC
         assign sw_modify = sw_type_alter_signal ? |sw_wr : |sw_rd;
         priority_mux #(.WIDTH(F_WIDTH), .CNT (SW_CNT)) sw_mux
           (.din (sw_wr_data), 
            .sel (sw_wr),
            .dout (sw_mux_value));
         assign nxt_sw_value = sw_type_alter_signal ? 
                               field_value & (~sw_mux_value) : {F_WIDTH{1'b0}};
      end
      else if (SW_TYPE == `SW_WonC) begin:g_SW_WonC
         assign sw_modify = sw_type_alter_signal ? |sw_wr : 1'b0;
         priority_mux #(.WIDTH(F_WIDTH), .CNT (SW_CNT)) sw_mux
           (.din (sw_wr_data), 
            .sel (sw_wr),
            .dout (sw_mux_value));
         assign nxt_sw_value = sw_type_alter_signal ? sw_mux_value : field_value;
      end
      else begin:g_unknown
         initial begin
            $display("%m:Unknown SW_TYPE %d", SW_TYPE);
            $finish;
         end
      end
   endgenerate

endmodule
