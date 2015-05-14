module a (
  din, 
  dout, 
  err, 
  sel);


input   [2   :0]  din[5   :0]  ;
output  [2   :0]  dout;
output            err;
input   [5   :0]  sel;

wire    [2   :0]  din[5   :0]  ;
`ifdef FSDB_MDA_ENABLE
// synopsys translate_off
`FSDB_DUMP_BEGIN
  `fsdbDumpMDA(din);
`FSDB_DUMP_END
// synopsys translate_on
`endif

wire    [2   :0]  dout;
wire              err;
wire    [5   :0]  sel;

one_hot_mux_2d #(
                 .WIDTH( 3 ),
                 .CNT( 6 ),
                 .ONE_HOT_CHECK( 0 )	 
                ) x_one_hot_mux_2d (
                                    .din (din),
                                    .dout (dout),
                                    .err (err),
                                    .sel (sel)
                                   );

endmodule
