module cab_slave (
  clk,
  rst_n,
  cab_xx_req_vld,
  cab_xx_req_data,
  xx_cab_ack_vld,
  xx_cab_ack_data,
  xx_cab_rdy,
  cab_req,
  cab_wr,
  cab_addr,
  cab_wdata,
  cab_ctrl,
  cab_ack,
  cab_rdata
);

parameter IDLE     = 4'b0001;
parameter WR_DAT_0 = 4'b0010;
parameter WR_DAT_1 = 4'b0100;
parameter RD_DAT   = 4'b1000;
parameter __IDLE__     = 0;
parameter __WR_DAT_0__ = 1;
parameter __WR_DAT_1__ = 2;
parameter __RD_DAT__   = 3;

// clock & reset
input        clk;
input        rst_n;

// CAB slave interface
input        cab_xx_req_vld;
input [15:0] cab_xx_req_data;
output       xx_cab_ack_vld;
output[15:0] xx_cab_ack_data;
output       xx_cab_rdy;

// local regsiter access interface
output       cab_req;
output       cab_wr;
output[13:0] cab_addr;
output[31:0] cab_wdata;
output       cab_ctrl;
input        cab_ack;
input [31:0] cab_rdata;

reg [3 :0]   cs;
reg [3 :0]   ns;
reg          cab_req;
reg          cab_wr;
reg [13:0]   cab_addr;
reg [31:0]   cab_wdata;
reg          cab_ctrl;
reg          xx_cab_rdy;
reg          nxt_cab_req;
reg          nxt_cab_wr;
reg          nxt_cab_ctrl;
reg [13:0]   nxt_cab_addr;
reg [31:0]   nxt_cab_wdata;
reg          nxt_xx_cab_rdy;
reg          ack_buf_used;
reg [15:0]   ack_buf;
reg          xx_cab_ack_vld;
reg [15:0]   xx_cab_ack_data;

// main FSM
always @(*) begin
  ns                  = cs;
  nxt_cab_req         = cab_req;
  nxt_cab_wr          = cab_wr;
  nxt_cab_addr[13:0]  = cab_addr[13:0];
  nxt_cab_ctrl        = cab_ctrl;
  nxt_cab_wdata[31:0] = cab_wdata[31:0];
  nxt_xx_cab_rdy      = xx_cab_rdy;

  case(1'b1)
  cs[__IDLE__]: begin
    nxt_cab_req = 1'b0;
    nxt_cab_wr = 1'b0;
    nxt_cab_wdata[31:0] = 32'b0;

    if(cab_xx_req_vld) begin
      nxt_cab_addr[13:0] = cab_xx_req_data[15:2];
      nxt_cab_ctrl = cab_xx_req_data[1];
      if(cab_xx_req_data[0]) begin
        ns = WR_DAT_0;
      end else begin
        nxt_xx_cab_rdy = 1'b0;
        nxt_cab_req = 1'b1;
        nxt_cab_wr = 1'b0;
        ns = RD_DAT;
      end
    end
  end

  cs[__WR_DAT_0__]: begin
    if(cab_xx_req_vld) begin
      nxt_cab_wdata[15:0] = cab_xx_req_data[15:0];
      ns = WR_DAT_1;
    end
  end

  cs[__WR_DAT_1__]: begin
    if(cab_xx_req_vld) begin
      nxt_cab_req = 1'b1;
      nxt_cab_wr = 1'b1;
      nxt_cab_wdata[31:16] = cab_xx_req_data[15:0];
      ns = IDLE;
    end
  end

  cs[__RD_DAT__]: begin
    if(cab_ack) begin
      ns = IDLE;
      nxt_xx_cab_rdy = 1'b1;
      nxt_cab_req = 1'b0;
    end
  end
  endcase
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    cs              <= IDLE;
    cab_req         <= 1'b0;
    cab_wr          <= 1'b0;
    cab_addr[13:0]  <= 14'b0;
    cab_ctrl        <= 1'b0;
    cab_wdata[31:0] <= 32'b0;
    xx_cab_rdy         <= 1'b1;
  end else begin
    cs              <= ns;
    cab_req         <= nxt_cab_req;
    cab_wr          <= nxt_cab_wr;
    cab_addr[13:0]  <= nxt_cab_addr[13:0];
    cab_ctrl        <= nxt_cab_ctrl;
    cab_wdata[31:0] <= nxt_cab_wdata[31:0];
    xx_cab_rdy      <= nxt_xx_cab_rdy;
  end
end

// 'ack_buf' is used to bridge from the interal 32-bits regsiter access to the external 16-bits CAB access
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    ack_buf_used <= 1'b0;
    ack_buf[15:0] <= 16'b0;
    xx_cab_ack_vld <= 1'b0;
    xx_cab_ack_data[15:0] <= 16'b0;
  end else if(cab_ack) begin
    ack_buf_used <= 1'b1;
    ack_buf[15:0] <= cab_rdata[31:16];
    xx_cab_ack_vld <= 1'b1;
    xx_cab_ack_data[15:0] <= cab_rdata[15:0];
  end else if(ack_buf_used) begin
    ack_buf_used <= 1'b0;
    xx_cab_ack_vld <= 1'b1;
    xx_cab_ack_data[15:0] <= ack_buf[15:0];
  end else begin
    xx_cab_ack_vld <= 1'b0;
    xx_cab_ack_data[15:0] <= 16'b0;
  end
end

endmodule
