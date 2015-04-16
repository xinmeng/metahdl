// - \insertfigure{Field block diagram}{field}{fig:field}

`include "xregister.vh"

module field (clk, rst_n,

              // synchronous reset is not mandatory
              // It can be float because it is not used internally 
              sync_rst,
   
              sw_wr, sw_rd, sw_wr_data, 
              sw_type_alter_signal,

              hw_pulse, hw_value,

              field_value);

   parameter F_WIDTH     = 4;
   parameter SW_CNT      = 1;
   parameter SRST_CNT    = 0;
   parameter WR_PRIORITY = `SW;
   parameter SW_TYPE     = `SW_RW;
   parameter HW_TYPE     = `HW_RO;
   parameter SRST_WIDTH  = SRST_CNT ? SRST_CNT : 1;

   parameter [F_WIDTH-1:0] ARST_VALUE = {F_WIDTH{1'b0}};
   parameter [F_WIDTH-1:0] SRST_VALUE  = ARST_VALUE;



   input [F_WIDTH*SW_CNT-1:0] sw_wr_data;
   input [SW_CNT-1:0]         sw_rd, sw_wr;
   input                      sw_type_alter_signal;
   input [F_WIDTH-1:0]        hw_value;
   input                      hw_pulse;
   output [F_WIDTH-1:0]       field_value;
   input                      clk, rst_n;
   input [SRST_WIDTH-1:0]     sync_rst;

   logic [F_WIDTH*SW_CNT-1:0] sw_wr_data;
   logic [SW_CNT-1:0]         sw_rd, sw_wr;
   logic                      sw_type_alter_signal;
   logic [F_WIDTH-1:0]        hw_value;
   logic                      hw_pulse;
   logic [F_WIDTH-1:0]        field_value;
   logic                      clk, rst_n;
   logic [SRST_WIDTH-1:0]     sync_rst;


   logic                      sw_modify, hw_modify;
   logic [F_WIDTH-1:0]        nxt_sw_value, nxt_hw_value, 
                              nxt_field_value;
   logic [F_WIDTH*2-1:0]      field_mux_din_pre;
   logic [2-1:0]              field_mux_sel_pre;
   logic [F_WIDTH*(2+SRST_CNT)-1:0] field_mux_din;
   logic [(2+SRST_CNT)-1:0]         field_mux_sel;


   wire [F_WIDTH-1:0]               sync_rst_value, async_rst_value;
   assign sync_rst_value  = SRST_VALUE; // For TB force 
   assign async_rst_value = ARST_VALUE; // For TB force

   // - * SW control
   sw_ctrl #(.F_WIDTH (F_WIDTH), .SW_CNT (SW_CNT), .SW_TYPE (SW_TYPE)) sw_ctrl
     (.sw_wr (sw_wr), 
      .sw_rd (sw_rd), 
      .sw_wr_data (sw_wr_data),
      .sw_type_alter_signal (sw_type_alter_signal),
      .field_value (field_value),
      .nxt_sw_value (nxt_sw_value), 
      .sw_modify (sw_modify));


   // - * Hardware control
   hw_ctrl #(.F_WIDTH (F_WIDTH), .HW_TYPE (HW_TYPE)) hw_ctrl
     (.hw_pulse (hw_pulse), 
      .hw_value (hw_value), 
      .field_value (field_value), 
      .nxt_hw_value (nxt_hw_value), 
      .hw_modify (hw_modify));


   // - * Ultimate mux
   generate
      if (WR_PRIORITY == `SW) begin: g_fmux_sw_dominant
         assign field_mux_din_pre = {nxt_hw_value, nxt_sw_value};
         assign field_mux_sel_pre = {hw_modify,    sw_modify};
      end
      else begin: g_fmux_hw_dominant
         assign field_mux_din_pre = {nxt_sw_value, nxt_hw_value};
         assign field_mux_sel_pre = {sw_modify,    hw_modify};
      end
   endgenerate

   generate
      if (SRST_CNT == 0) begin: g_no_sync_reset
         assign field_mux_din = field_mux_din_pre;
         assign field_mux_sel = field_mux_sel_pre;
      end
      else begin: g_has_sync_reset
         assign field_mux_din = {field_mux_din_pre, {SRST_CNT{sync_rst_value}}};
         assign field_mux_sel = {field_mux_sel_pre, sync_rst};
      end
   endgenerate

   priority_mux #(.WIDTH (F_WIDTH), .CNT (2+SRST_CNT))
     field_mux (.din (field_mux_din), 
                .sel (field_mux_sel), 
                .dout (nxt_field_value));

   // - *DFF
   wire         field_value_modify;
   assign field_value_modify = |field_mux_sel;
   always_ff @(posedge clk or negedge rst_n)
     if (!rst_n)
       field_value <= async_rst_value;
     else if (field_value_modify)
       field_value <= nxt_field_value;
     else
       field_value <= field_value;
   
endmodule
