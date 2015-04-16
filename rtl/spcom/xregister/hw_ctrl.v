`include "xregister.vh"

module hw_ctrl (hw_pulse, hw_value,
                field_value,
                nxt_hw_value, hw_modify);

   parameter F_WIDTH = 4;
   parameter HW_TYPE = `HW_WIRED;

   input logic [F_WIDTH-1:0] hw_value;
   input logic               hw_pulse;
   input logic [F_WIDTH-1:0] field_value;

   output logic [F_WIDTH-1:0] nxt_hw_value;
   output logic               hw_modify;

         
   generate
      if (HW_TYPE == `HW_RO) begin:g_HW_RO
         assign nxt_hw_value = {F_WIDTH{1'b0}};
         assign hw_modify    = 1'b0;
      end
      else if (HW_TYPE == `HW_WIRED) begin:g_HW_WIRED
         assign nxt_hw_value = hw_value;
         assign hw_modify    = 1'b1;
      end
      else if (HW_TYPE == `HW_SET) begin:g_HW_SET
         assign nxt_hw_value = {F_WIDTH{1'b1}};
         assign hw_modify    = hw_pulse;
      end
      else if (HW_TYPE == `HW_CLR) begin:g_HW_CLR
         assign nxt_hw_value = {F_WIDTH{1'b0}};
         assign hw_modify    = hw_pulse;
      end
      else if (HW_TYPE == `HW_INC) begin:g_HW_INC
         assign nxt_hw_value = field_value + 1'b1;
         assign hw_modify    = hw_pulse;
      end
      else if (HW_TYPE == `HW_DEC) begin:g_HW_DEC
         assign nxt_hw_value = field_value - 1'b1;
         assign hw_modify    = hw_pulse;
      end
      else if (HW_TYPE == `HW_ADD) begin:g_HW_ADD
         assign nxt_hw_value = field_value + hw_value;
         assign hw_modify    = hw_pulse;
      end
      else if (HW_TYPE == `HW_SUB) begin:g_HW_SUB
         assign nxt_hw_value = field_value - hw_value;
         assign hw_modify    = hw_pulse;
      end
      else if (HW_TYPE == `HW_VALUE) begin:g_HW_VALUE
         assign nxt_hw_value = hw_value;
         assign hw_modify    = hw_pulse;
      end
      else begin:g_unknown
         initial begin
            $display("%m:Unknown HW_TYPE:%d",HW_TYPE);
            $finish;
         end
      end
   endgenerate


endmodule
