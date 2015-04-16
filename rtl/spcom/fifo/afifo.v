module afifo(
  din,
  dout,
  empty, empty_n,
  full, full_n,
  pop,
  push,
  rclk,
  rrst_n,
  wclk,
  wrst_n
);

`include "common_funcs.vh"

parameter DEPTH = 4;
parameter WIDTH = 4;
localparam BADDR = log2(DEPTH); 
localparam GADDR = BADDR+1;

input [WIDTH-1:0] din;
input pop;
input push;
input rclk;
input rrst_n;
input wclk;
input wrst_n;
output [WIDTH-1:0] dout;
output empty, empty_n;
output full, full_n;

reg full, full_n;
reg [GADDR-1:0] rbptr_sync;
reg [GADDR-1:0] wbptr;
reg [GADDR-1:0] wgptr;
reg empty, empty_n;
reg [GADDR-1:0] wbptr_sync;
reg [GADDR-1:0] rbptr;
reg [GADDR-1:0] rgptr;
reg [WIDTH-1:0] mem [DEPTH-1:0];
reg [BADDR-1:0] wbaddr;
reg [BADDR-1:0] rbaddr;

wire [WIDTH-1:0] din;
wire [WIDTH-1:0] dout;
wire pop;
wire push;
wire rclk;
wire rrst_n;
wire wclk;
wire wrst_n;

wire [GADDR-1:0] rgptr_sync;
wire [GADDR-1:0] wbptr_nxt;
wire [GADDR-1:0] wbptr_plus_1;
wire [GADDR-1:0] wgptr_nxt;
wire [GADDR-1:0] wsp_nxt;
wire [GADDR-1:0] wgptr_sync;
wire [GADDR-1:0] rbptr_nxt;
wire [GADDR-1:0] rbptr_plus_1;
wire [GADDR-1:0] rgptr_nxt;
wire [GADDR-1:0] rsp_nxt;
wire [BADDR-1:0] wbaddr_nxt;
wire [BADDR-1:0] rbaddr_nxt;

// FIFO Memory
// -----------
`ifdef FSDB_MDA_ENABLE
// synopsys translate_off
`FSDB_DUMP_BEGIN
  `fsdbDumpMDA(mem);
`FSDB_DUMP_END
// synopsys translate_on
`endif

generate
  if(BADDR == GADDR) begin:no_exp2_baddr
    always @(posedge wclk or negedge wrst_n) begin
      if(!wrst_n)
        wbaddr[BADDR-1:0] <= 0;
      else
        wbaddr[BADDR-1:0] <= wbaddr_nxt[BADDR-1:0];
    end

    assign wbaddr_nxt[BADDR-1:0] = push ? (wbaddr[BADDR-1:0] == (DEPTH-1)) ? 0
                                                                           : wbaddr[BADDR-1:0] + 1'b1
                                        : wbaddr[BADDR-1:0];

    always @(posedge rclk or negedge rrst_n) begin
      if(!rrst_n)
        rbaddr[BADDR-1:0] <= 0;
      else
        rbaddr[BADDR-1:0] <= rbaddr_nxt[BADDR-1:0];
    end

    assign rbaddr_nxt[BADDR-1:0] = pop ? (rbaddr[BADDR-1:0] == (DEPTH-1)) ? 0
                                                                          : rbaddr[BADDR-1:0] + 1'b1
                                       : rbaddr[BADDR-1:0];

    always @(posedge wclk) begin
      if(push) 
        mem[wbaddr[BADDR-1:0]] <= din[WIDTH-1:0];
    end
    
    assign dout[WIDTH-1:0] = mem[rbaddr[BADDR-1:0]];
  
  end else begin:exp2_baddr
    always @(posedge wclk) begin
      if(push) 
        mem[wbptr[BADDR-1:0]] <= din[WIDTH-1:0];
    end
    
    assign dout[WIDTH-1:0] = mem[rbptr[BADDR-1:0]];
  
  end
endgenerate

// binary pointer logic
// --------------------
always @(posedge wclk or negedge wrst_n) begin
  if(!wrst_n) 
    wbptr[GADDR-1:0] <= 0;
  else 
    wbptr[GADDR-1:0] <= wbptr_nxt[GADDR-1:0];
end

assign wbptr_nxt[GADDR-1:0] = push ? wbptr_plus_1[GADDR-1:0] : wbptr[GADDR-1:0];
assign wbptr_plus_1[GADDR-1:0] = wbptr[GADDR-1:0] + 1'b1;
  
// gray pointer logic
// ------------------
always @(posedge wclk or negedge wrst_n) begin
  if(!wrst_n) 
    wgptr[GADDR-1:0] <= 0;
  else 
    wgptr[GADDR-1:0] <= wgptr_nxt[GADDR-1:0];
end

assign wgptr_nxt[GADDR-1:0] = (wbptr_nxt[GADDR-1:0]>>1) ^ wbptr_nxt[GADDR-1:0];

// sync rgptr
cdc_synczr rgptr_cdc_synczr[GADDR-1:0] (
  .clk      (wclk),
  .sync_in  (rgptr),
  .sync_out (rgptr_sync)
);

// gray to bin logic
// -----------------
integer i_rgptr_sync;
always @(rgptr_sync[GADDR-1:0]) begin
  for(i_rgptr_sync=0; i_rgptr_sync<GADDR; i_rgptr_sync=i_rgptr_sync+1)
    rbptr_sync[i_rgptr_sync] = ^(rgptr_sync[GADDR-1:0]>>i_rgptr_sync);
end

// space logic
// -----------------
assign wsp_nxt[GADDR-1:0] = DEPTH - (wbptr_nxt[GADDR-1:0] - rbptr_sync[GADDR-1:0]);

// full logic
// ----------
always @(posedge wclk or negedge wrst_n) begin
  if(!wrst_n) 
    full_n <= 1'b1;
  else 
    full_n <= (wsp_nxt[GADDR-1:0] != 0);
end
  
always @(posedge wclk or negedge wrst_n) begin
  if(!wrst_n) 
    full <= 1'b0;
  else 
    full <= (wsp_nxt[GADDR-1:0] == 0);
end

// binary pointer logic
// --------------------
always @(posedge rclk or negedge rrst_n) begin
  if(!rrst_n) 
    rbptr[GADDR-1:0] <= 0;
  else 
    rbptr[GADDR-1:0] <= rbptr_nxt[GADDR-1:0];
end

assign rbptr_nxt[GADDR-1:0] = pop ? rbptr_plus_1[GADDR-1:0] : rbptr[GADDR-1:0];
assign rbptr_plus_1[GADDR-1:0] = rbptr[GADDR-1:0] + 1'b1;
  
// gray pointer logic
// ------------------
always @(posedge rclk or negedge rrst_n) begin
  if(!rrst_n) 
    rgptr[GADDR-1:0] <= 0;
  else 
    rgptr[GADDR-1:0] <= rgptr_nxt[GADDR-1:0];
end

assign rgptr_nxt[GADDR-1:0] = (rbptr_nxt[GADDR-1:0]>>1) ^ rbptr_nxt[GADDR-1:0];

// sync wgptr
cdc_synczr wgptr_cdc_synczr[GADDR-1:0] (
  .clk      (rclk),
  .sync_in  (wgptr),
  .sync_out (wgptr_sync)
);

// gray to bin logic
// -----------------
integer i_wgptr_sync;
always @(wgptr_sync[GADDR-1:0]) begin
  for(i_wgptr_sync=0; i_wgptr_sync<GADDR; i_wgptr_sync=i_wgptr_sync+1)
    wbptr_sync[i_wgptr_sync] = ^(wgptr_sync[GADDR-1:0]>>i_wgptr_sync);
end

// space logic
// -----------------
assign rsp_nxt[GADDR-1:0] = rbptr_nxt[GADDR-1:0] - wbptr_sync[GADDR-1:0];

// empty logic
// ----------
always @(posedge rclk or negedge rrst_n) begin
  if(!rrst_n) 
    empty_n <= 1'b0;
  else 
    empty_n <= (rsp_nxt[GADDR-1:0] != 0);
end

always @(posedge rclk or negedge rrst_n) begin
  if(!rrst_n) 
    empty <= 1'b1;
  else 
    empty <= (rsp_nxt[GADDR-1:0] == 0);
end


// synopsys translate_off
push_ful: assert property (@(posedge wclk) not (push && !full_n))
       else
        $fatal("[ERROR] AFIFO PUSH occur when AFIFO is !full_n");
pop_empt: assert property (@(posedge rclk) not (pop && !empty_n))
        else
        $fatal("[ERROR] AFIFO POP occur when AFIFO is !empty_n");
// synopsys translate_on

// function integer log2;
//   input [31:0] value;
//   begin : log2block
//     if(value == 1) begin : log2block_true
//       log2 = 1;
//     end
//     else begin : log2block_false
//       integer val;
//       val = value-1;
//       for (log2=0; val>0; log2=log2+1) begin : log2block_for
//         val = val>>1;
//       end
//     end
//   end
// endfunction

// function integer gray_log2;
//   input [31:0] value;
//   begin : graylog2block
//     integer val;
//     val = log2(value);
//     if(value != (2<<(val-1))) begin : graylog2block_true
//       gray_log2 = val;
//     end else begin : graylog2block_false
//       gray_log2 = val + 1;
//     end
//   end
// endfunction
endmodule
