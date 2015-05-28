module a (
  aa, 
  b, 
  c, 
  clk, 
  d, 
  dcbarb_grant, 
  dcbarb_pop, 
  dcbarb_tcqs_pop, 
  dd, 
  dout, 
  err, 
  rst_n, 
  sel);


input   [2   :0]  aa[5   :0]  ;
input   [3   :0]  b;
output            c;
input             clk;
output            d;
input   [7   :0]  dcbarb_grant;
output            dcbarb_pop;
output  [7   :0]  dcbarb_tcqs_pop;
input   [5   :0]  dd;
output  [2   :0]  dout;
output            err;
input             rst_n;
input   [5   :0]  sel;

reg               a;
wire    [2   :0]  aa[5   :0]  ;
`ifdef FSDB_MDA_ENABLE
// synopsys translate_off
`FSDB_DUMP_BEGIN
  `fsdbDumpMDA(aa);
`FSDB_DUMP_END
// synopsys translate_on
`endif

wire    [3   :0]  b;
reg               c;
wire              clk;
reg               d;
wire    [7   :0]  dcbarb_grant;
wire              dcbarb_pop;
wire    [7   :0]  dcbarb_tcqs_pop;
wire    [5   :0]  dd;
wire    [2   :0]  dout;
wire              err;
wire              rst_n;
wire    [5   :0]  sel;

always @(*) 
  a = b[3:0];

always @(posedge clk or negedge rst_n)
  {c, d} <= dd[5:0];

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
