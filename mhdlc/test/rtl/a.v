module a (
  aa, 
  din, 
  err, 
  sel);


output  [2   :0]  aa[3   :0]  ;
input   [2   :0]  din[5   :0]  ;
output            err;
input   [5   :0]  sel;

wire    [2   :0]  aa[3   :0]  ;
`ifdef FSDB_MDA_ENABLE
// synopsys translate_off
`FSDB_DUMP_BEGIN
  `fsdbDumpMDA(aa);
`FSDB_DUMP_END
// synopsys translate_on
`endif

wire    [2   :0]  din[5   :0]  ;
`ifdef FSDB_MDA_ENABLE
// synopsys translate_off
`FSDB_DUMP_BEGIN
  `fsdbDumpMDA(din);
`FSDB_DUMP_END
// synopsys translate_on
`endif

wire              err;
wire    [5   :0]  sel;

one_hot_mux_2d #(
                 .WIDTH( 3 ),
                 .CNT( 6 ),
                 .ONE_HOT_CHECK( 0 )	 
                ) x_one_hot_mux_2d (
                                    .din (din),
                                    .dout (aa[0]),
                                    .err (err),
                                    .sel (sel)
                                   );

endmodule
