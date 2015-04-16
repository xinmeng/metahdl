module pad_strip (
  data_in,
  data_in_bcnt,
  data_in_eop,
  data_in_vld,
  data_in_rdy,
  data_out,
  data_out_eop,
  data_out_vld,
  data_out_bcnt,
  data_out_rdy,
  data_pad_en,
  data_pad_in,
  data_pad_bcnt,
  data_pad_offset,
  //data_strip_en,
  //data_strip,
  //data_strip_bcnt,
  //data_strip_offset,
  clk,
  rst_n
)

parameter DATA_WIDTH     = 128;
parameter DATA_BCNT      = (log2(DATA_WIDTH/8)+1); // Default is 5
parameter SHIFTER_WIDTH  = DATA_WIDTH+DATA_WIDTH;
parameter SHIFTER_BCNT   = (log2(SHIFTER_WIDTH/8)+1);

input  [DATA_WIDTH-1:0] data_in;
input  [DATA_BCNT-1: 0] data_in_bcnt;
input                   data_in_vld;
input                   data_in_eop;
input                   data_in_rdy;

output [DATA_WIDTH-1:0] data_out;
output [DATA_BCNT-1: 0] data_out_bcnt;
output                  data_out_vld;
output                  data_out_eop;
input                   data_out_rdy;

input  [DATA_WIDTH-1:0] data_pad_in;
input                   data_pad_en;
input  [DATA_BCNT-1: 0] data_pad_offset;
input  [DATA_BCNT-1: 0] data_pad_bcnt;

//input  [DATA_WIDTH-1:0] data_strip_in;
//input                   data_strip_en;
//input  [DATA_BCNT-1: 0] data_strip_offset;
//input  [DATA_BCNT-1: 0] data_strip_bcnt;

reg [SHIFTER_WIDTH-1:0] shifter;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    shifter[SHIFTER_WIDTH-1:0] <= {SHIFTER_WIDTH{1'b0}};
end
