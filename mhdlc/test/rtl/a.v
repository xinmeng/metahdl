module a (
  a, 
  aa, 
  b, 
  dcbarb_grant, 
  dcbarb_pop, 
  dcbarb_tcqs_pop, 
  dout, 
  err, 
  sel);


input             a;
input   [2   :0]  aa[5   :0]  ;
input             b;
input   [7   :0]  dcbarb_grant;
output            dcbarb_pop;
output  [7   :0]  dcbarb_tcqs_pop;
output  [2   :0]  dout;
output            err;
input   [5   :0]  sel;

wire              a;
wire    [2   :0]  aa[5   :0]  ;
`ifdef FSDB_MDA_ENABLE
// synopsys translate_off
`FSDB_DUMP_BEGIN
  `fsdbDumpMDA(aa);
`FSDB_DUMP_END
// synopsys translate_on
`endif

wire              b;
wire    [7   :0]  dcbarb_grant;
wire              dcbarb_pop;
wire    [7   :0]  dcbarb_tcqs_pop;
wire    [2   :0]  dout;
wire              err;
wire    [5   :0]  sel;

assign dcbarb_tcqs_pop[7:0] = a && b ? dcbarb_grant[7:0] : 8'd0;

assign dcbarb_pop = (|dcbarb_grant[7:0]);

one_hot_mux_2d #(
                 .WIDTH( 3 ),
                 .CNT( 6 ),
                 .ONE_HOT_CHECK( 0 )	 
                ) x_one_hot_mux_2d_1 (
                                      .din (aa),
                                      .dout (dout),
                                      .err (err),
                                      .sel (sel)
                                     );

endmodule
