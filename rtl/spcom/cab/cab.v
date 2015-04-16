module cab (
  clk,
  rst_n,
  mclk,
  sclk,
  maddr,
  mwdata,
  mreq,
  mwr,
  mdn,
  mrdata,
  srdy,
  sack,
  sackdata,
  sreq,
  sreqdata
);

parameter MST_CNT = 2;
parameter SLV_CNT = 2;
parameter [31:0] MST_ASYNC[MST_CNT-1:0] = '{1, 1};
parameter [31:0] SLV_ASYNC[SLV_CNT-1:0] = '{1, 1};
parameter CAB_SIZE = 13'h1000;
parameter [15:0] SLV_BASE_ADDR[SLV_CNT-1:0] = '{16'h1000, 16'h0};

parameter SEND_ADDR    = 3'b001;
parameter SEND_WDATA_0 = 3'b010;
parameter SEND_WDATA_1 = 3'b100;
parameter __SEND_ADDR__    = 0;
parameter __SEND_WDATA_0__ = 1;
parameter __SEND_WDATA_1__ = 2;

// clk & reset
input clk;
input rst_n;
input [MST_CNT-1:0] mclk;
input [SLV_CNT-1:0] sclk;

// master interface
input  [15       :0] maddr  [MST_CNT-1:0]; 
input  [31       :0] mwdata [MST_CNT-1:0];
input  [MST_CNT-1:0] mreq;
input  [MST_CNT-1:0] mwr ;
output [MST_CNT-1:0] mdn ;
output [31       :0] mrdata [MST_CNT-1:0];

// CAB slave interface
input  [SLV_CNT-1:0] srdy;
input  [SLV_CNT-1:0] sack;
input  [15       :0] sackdata [SLV_CNT-1:0];
output [SLV_CNT-1:0] sreq;
output [15       :0] sreqdata [SLV_CNT-1:0];

wire [MST_CNT-1 :0] mrst_n;
wire [SLV_CNT-1 :0] srst_n;
wire [SLV_CNT+48:0] mst_req_din     [MST_CNT-1:0];  
wire [SLV_CNT+48:0] mst_req_dout    [MST_CNT-1:0]; 
wire [MST_CNT-1:0]  mst_req_empty_n; 
wire [MST_CNT-1:0]  mst_req_full_n ; 
wire [MST_CNT-1:0]  mst_req_pop_q  ;  
wire [MST_CNT-1:0]  mst_req_push   ; 
wire [31        :0] mst_ack_din     [MST_CNT-1:0];  
wire [31        :0] mst_ack_dout    [MST_CNT-1:0]; 
wire [MST_CNT-1:0]  mst_ack_empty_n; 
wire [MST_CNT-1:0]  mst_ack_full_n ; 
wire [MST_CNT-1:0]  mst_ack_push_q ;  
wire [MST_CNT-1:0]  mst_ack_pop ;  
wire [15        :0] slv_req_din     [SLV_CNT-1:0];  
wire [15        :0] slv_req_dout    [SLV_CNT-1:0]; 
wire [SLV_CNT-1:0]  slv_req_empty_n ; 
wire [SLV_CNT-1:0]  slv_req_full_n  ; 
wire [SLV_CNT-1:0]  slv_req_push_q   ;  
wire [SLV_CNT-1:0]  slv_req_pop   ;  
wire [15        :0] slv_ack_din     [SLV_CNT-1:0];  
wire [15        :0] slv_ack_dout    [SLV_CNT-1:0]; 
wire [SLV_CNT-1:0]  slv_ack_empty_n ; 
wire [SLV_CNT-1:0]  slv_ack_full_n  ; 
wire [SLV_CNT-1:0]  slv_ack_pop_q   ;  
wire [SLV_CNT-1:0]  slv_ack_push    ; 
wire [SLV_CNT-1:0]  slv_ack_pop    ; 
wire [SLV_CNT-1 :0] slv_id          [MST_CNT-1:0];
wire [15        :0] slv_offset_arr  [MST_CNT-1:0] [SLV_CNT-1:0];
wire [15        :0] slv_offset      [MST_CNT-1:0];
wire [SLV_CNT+48:0] mst_req;
wire [MST_CNT-1:0]  mid;
wire                wr;
wire [SLV_CNT-1 :0] sid;
wire [15        :0] offset;
wire [31        :0] wdata;
wire                slv_req_rdy;
wire [7         :0] ack_buf_info_sel [7:0];
wire [7         :0] ack_buf_vld_by_rptr;
wire [SLV_CNT-1 :0] ack_buf_sid_by_rptr [7:0];
wire [SLV_CNT-1 :0] wbptr_t [7:0];
wire [7         :0] ack_buf_wbvld;
wire [15        :0] ack_buf_wbdata [7:0];
wire [31        :0] ack_buf_data_by_rptr;
wire [MST_CNT-1 :0] ack_buf_mid_by_rptr;
wire                ack_buf_pop;
wire [MST_CNT-1 :0] mst_ack_push;
wire                tx_timeout;
wire                rx_timeout;
wire                rx_timeout_rst;
wire                ack_buf_rdy;
wire                ack_buf_vld_by_wptr;

reg [2                 :0] cs;
reg [2                 :0] ns;
reg                        mst_req_pop;
reg                        tx_timeout_rst;
reg                        ack_buf_push;
reg [MST_CNT+SLV_CNT+32:0] ack_buf_din;
reg [SLV_CNT-1         :0] slv_req_push;
reg [15                :0] slv_req_din_src;
reg [7                 :0] ack_buf_rdata_blk_sel;
reg [7                 :0] ack_buf_vld;
reg [MST_CNT-1         :0] ack_buf_mid [7:0];
reg [SLV_CNT-1         :0] ack_buf_sid [7:0];
reg [31                :0] ack_buf_data [7:0];
reg [7                 :0] ack_buf_wptr;
reg [7                 :0] ack_buf_rptr;
reg [7                 :0] wbptr [SLV_CNT-1:0];
reg [17                :0] tx_cnt;
reg [17                :0] rx_cnt;

// slave id one-hot encoding for each master
genvar i, j;

generate
  for(i=0; i<MST_CNT; i++) begin: slave_id_enc_mloop
    for(j=0; j<SLV_CNT; j++) begin: slave_id_enc_sloop
      assign slv_id[i][j] = (maddr[i] >= SLV_BASE_ADDR[j]) && (maddr[i] < (SLV_BASE_ADDR[j] + CAB_SIZE));
      assign slv_offset_arr[i][j] = maddr[i] - SLV_BASE_ADDR[j];
    end
  end
endgenerate

// CAB address offset for each slave
generate
  for(i=0; i<MST_CNT; i++) begin: slave_offset_gen
    one_hot_mux_2d #(.WIDTH(16), .CNT(SLV_CNT))
      x_slv_offset_mux (
      .din(slv_offset_arr[i]),
      .sel(slv_id[i]),
      .dout(slv_offset[i]),
      .err()
      );
  end
endgenerate

// master interface CDC
generate
  for(i=0; i<MST_CNT; i++) begin: mst_cdc_gen
    assign mst_req_din[i] = {mwr[i], slv_id[i], slv_offset[i], mwdata[i]};
    assign mst_req_push[i] = mreq[i] && mst_req_full_n[i];
    assign mst_req_pop_q[i] = mst_req_empty_n[i] & mst_req_pop;

    if(MST_ASYNC[i]) begin
      rst_synczr x_mst_rst_synczr (
        .async_in_rst_n  (rst_n),
        .async_out_rst_n (mrst_n[i]),
        .clk             (mclk[i])
      );

      afifo #(.DEPTH(8), .WIDTH(49+SLV_CNT))
        x_mst_req_afifo (
        .din     (mst_req_din[i]),
        .dout    (mst_req_dout[i]),
        .empty_n (mst_req_empty_n[i]),
        .full_n  (mst_req_full_n[i]),
        .pop     (mst_req_pop_q[i]),
        .push    (mst_req_push[i]),
        .rclk    (clk),
        .rrst_n  (rst_n),
        .wclk    (mclk[i]),
        .wrst_n  (mrst_n[i])
      );

      assign mst_ack_pop[i] = mst_ack_empty_n[i];
      assign mst_ack_push_q[i] = mst_req_full_n[i] && mst_ack_push[i];
      assign mdn[i] = mst_ack_empty_n[i];
      assign mrdata[i] = mst_ack_dout[i];

      afifo #(.DEPTH(4), .WIDTH(32))
        x_mst_ack_afifo (
        .din     (mst_ack_din[i]),
        .dout    (mst_ack_dout[i]),
        .empty_n (mst_ack_empty_n[i]),
        .full_n  (mst_ack_full_n[i]),
        .pop     (mst_ack_pop[i]),
        .push    (mst_ack_push_q[i]),
        .rclk    (mclk[i]),
        .rrst_n  (mrst_n[i]),
        .wclk    (clk),
        .wrst_n  (rst_n)
      );
    end else begin
      sfifo #(.DEPTH(8), .WIDTH(49+SLV_CNT))
        x_mst_req_sfifo (
        .clk     (clk),
        .data_in (mst_req_din[i]),
        .data_out(mst_req_dout[i]),
        .empty_n (mst_req_empty_n[i]),
        .empty   (),
        .full_n  (mst_req_full_n[i]),
        .full    (),
        .rd_en   (mst_req_pop_q[i]),
        .rst_n   (rst_n),
        .wr_en   (mst_req_push[i]) 
      );

      assign mdn[i] = mst_ack_push[i];
      assign mrdata[i] = mst_ack_din[i];
    end
  end
endgenerate

// slave interface CDC
generate
  for(i=0; i<SLV_CNT; i++) begin: slv_cdc_gen
    if(SLV_ASYNC[i]) begin
      rst_synczr x_slv_rst_synczr (
        .async_in_rst_n  (rst_n),
        .async_out_rst_n (srst_n[i]),
        .clk             (sclk[i])
      );

      assign slv_req_push_q[i] = slv_req_push[i] && slv_req_full_n[i];
      assign slv_req_pop[i] = slv_req_empty_n[i] && srdy[i];
      assign sreq[i] = slv_req_empty_n[i];
      assign sreqdata[i] = slv_req_dout[i];

      afifo #(.DEPTH(4), .WIDTH(16))
        x_slv_req_afifo (
        .din     (slv_req_din[i]),
        .dout    (slv_req_dout[i]),
        .empty_n (slv_req_empty_n[i]),
        .full_n  (slv_req_full_n[i]),
        .empty   (),
        .full    (),
        .pop     (slv_req_pop[i]),
        .push    (slv_req_push_q[i]),
        .rclk    (sclk[i]),
        .rrst_n  (srst_n[i]),
        .wclk    (clk),
        .wrst_n  (rst_n)
      );

      assign slv_ack_din[i] = sackdata[i];
      assign slv_ack_push[i] = slv_ack_full_n[i] && sack[i];
      assign slv_ack_pop[i] = slv_ack_empty_n[i];

      afifo #(.DEPTH(4), .WIDTH(16))
        x_slv_ack_afifo (
        .din     (slv_ack_din[i]),
        .dout    (slv_ack_dout[i]),
        .empty_n (slv_ack_empty_n[i]),
        .full_n  (slv_ack_full_n[i]),
        .empty   (),
        .full    (),
        .pop     (slv_ack_pop[i]),
        .push    (slv_ack_push[i]),
        .rclk    (clk),
        .rrst_n  (rst_n),
        .wclk    (sclk[i]),
        .wrst_n  (srst_n[i])
      );
    end else begin
      assign srst_n[i] = 1'b1;
      assign sreq[i] = slv_req_push[i];
      assign sreqdata[i] = slv_req_din[i];
      assign slv_req_full_n[i] = srdy[i];
      assign slv_ack_empty_n[i] = sack[i];
      assign slv_ack_dout[i] = sackdata[i];
    end
  end
endgenerate

// All the CAB master accesses are mutually exclusive. Thus, their request bus is natively one-hot.
one_hot_mux_2d #(.WIDTH(49+SLV_CNT), .CNT(MST_CNT))
  x_mst_req_mux (
  .din(mst_req_dout),
  .sel(mst_req_empty_n),
  .dout(mst_req),
  .err()
  );

assign mid[MST_CNT-1:0] = mst_req_empty_n[MST_CNT-1:0];
assign wr = mst_req[SLV_CNT+48];
assign sid[SLV_CNT-1:0] = mst_req[47+SLV_CNT:48];
assign offset[15:0] = mst_req[47:32];
assign wdata[31:0] = mst_req[31:0];

// Slave afifo interface signals mux/demux
one_hot_demux_2d #(.WIDTH(16), .CNT(SLV_CNT))
  x_slv_req_din_demux (
  .din(slv_req_din_src),
  .sel(sid),
  .dout(slv_req_din)
  );

one_hot_mux #(.WIDTH(1), .CNT(SLV_CNT))
  x_slv_req_full_n_mux (
  .din(slv_req_full_n),
  .sel(sid),
  .dout(slv_req_rdy),
  .err()
  );

// CAB slave request send FSM
always @(*) begin
  ns = cs;
  mst_req_pop = 1'b0;
  tx_timeout_rst = 1'b0;
  ack_buf_push = 1'b0;
  ack_buf_din[MST_CNT+SLV_CNT+32:0] = {(MST_CNT+SLV_CNT+33){1'b0}};
  slv_req_push[SLV_CNT-1:0] = {SLV_CNT{1'b0}};
  slv_req_din_src[15:0] = 16'b0;

  case(1'b1)
  cs[__SEND_ADDR__]: begin
    if(|mst_req_empty_n[MST_CNT-1:0] && slv_req_rdy && ack_buf_rdy) begin
      slv_req_push[SLV_CNT-1:0] = sid[SLV_CNT-1:0];

      // CAB write
      if(wr) begin
        slv_req_din_src[15:0] = {offset[15:2], 1'b0, 1'b1};
        ns = SEND_WDATA_0;
      // CAB read
      end else begin
        slv_req_din_src[15:0] = {offset[15:2], 1'b0, 1'b0};
        mst_req_pop = 1'b1;
        tx_timeout_rst = 1'b1;
        ack_buf_push = 1'b1;
        ack_buf_din[MST_CNT+SLV_CNT+32:0] = {1'b0, mid[MST_CNT-1:0], sid[SLV_CNT-1:0], 32'b0};
      end
    end else if(tx_timeout) begin
      mst_req_pop = 1'b1;
      tx_timeout_rst = 1'b1;
    end
  end

  cs[__SEND_WDATA_0__]: begin
    if(slv_req_rdy) begin
      slv_req_din_src[15:0] = wdata[15:0];
      slv_req_push[SLV_CNT-1:0] = sid[SLV_CNT-1:0];
      ns = SEND_WDATA_1;
    end else if(tx_timeout) begin
      mst_req_pop = 1'b1;
      tx_timeout_rst = 1'b1;
      ns = SEND_ADDR;
    end
  end

  cs[__SEND_WDATA_1__]: begin
    if(slv_req_rdy) begin
      slv_req_din_src[15:0] = wdata[31:16];
      slv_req_push[SLV_CNT-1:0] = sid[SLV_CNT-1:0];
      mst_req_pop = 1'b1;
      tx_timeout_rst = 1'b1;
      // Write transaction is acked without data. Thus, the 'vld' filed is set when the request gets pushed.
      ack_buf_push = 1'b1;
      ack_buf_din[MST_CNT+SLV_CNT+32:0] = {1'b1, mid[MST_CNT-1:0], sid[SLV_CNT-1:0], 32'b0};
      ns = SEND_ADDR;
    end else if(tx_timeout) begin
      mst_req_pop = 1'b1;
      tx_timeout_rst = 1'b1;
      ns = SEND_ADDR;
    end
  end
  endcase
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    cs <= SEND_ADDR;
  end else begin
    cs <= ns;
  end
end

// 8-entries ack buf for up to 8 outstanding requests
generate
  for(i=0; i<8; i++) begin: ack_buf_gen
    // upper/lower part selection of the 'ack data' field
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        ack_buf_rdata_blk_sel[i] <= 1'b0;
      end else if(ack_buf_wbvld[i]) begin
        ack_buf_rdata_blk_sel[i] <= ~ack_buf_rdata_blk_sel[i];
      end
    end

    // ack vld field
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        ack_buf_vld[i] <= 1'b0;
      end else if(ack_buf_wptr[i] && ack_buf_push) begin
        ack_buf_vld[i] <= ack_buf_din[MST_CNT+SLV_CNT+32];
      end else if(ack_buf_pop && ack_buf_rptr[i]) begin
        ack_buf_vld[i] <= 1'b0;
      end else if(ack_buf_wbvld[i] && ack_buf_rdata_blk_sel[i]) begin
        ack_buf_vld[i] <= 1'b1;
      end
    end

    // request master id fields
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        ack_buf_mid[i] <= {MST_CNT{1'b0}};
      end else if(ack_buf_wptr[i] && ack_buf_push) begin
        ack_buf_mid[i] <= ack_buf_din[MST_CNT+SLV_CNT+31:SLV_CNT+32];
      end else if(ack_buf_pop && ack_buf_rptr[i]) begin
        ack_buf_mid[i] <= {MST_CNT{1'b0}};
      end
    end

    // request slave id fields
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        ack_buf_sid[i] <= {SLV_CNT{1'b0}};
      end else if(ack_buf_wptr[i] && ack_buf_push) begin
        ack_buf_sid[i] <= ack_buf_din[SLV_CNT+31:32];
      end else if(ack_buf_pop && ack_buf_rptr[i]) begin
        ack_buf_sid[i] <= {SLV_CNT{1'b0}};
      end
    end

    // ack data field
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        ack_buf_data[i] <= 32'b0;
      end else if(ack_buf_wptr[i] && ack_buf_push) begin
        ack_buf_data[i] <= ack_buf_din[31:0];
      end else if(ack_buf_wbvld[i]) begin
        if(ack_buf_rdata_blk_sel[i]) 
          ack_buf_data[i][31:16] <= ack_buf_wbdata[i];
        else
          ack_buf_data[i][15: 0] <= ack_buf_wbdata[i];
      end
    end
  end
endgenerate

// ack buf onehot wptr/rptr
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    ack_buf_wptr[7:0] <= 8'b1;
  end else if(ack_buf_push) begin
    ack_buf_wptr[7:0] <= {ack_buf_wptr[6:0], ack_buf_wptr[7]};
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    ack_buf_rptr[7:0] <= 8'b1;
  end else if(ack_buf_pop) begin
    ack_buf_rptr[7:0] <= {ack_buf_rptr[6:0], ack_buf_rptr[7]};
  end
end

one_hot_mux #(.WIDTH(1), .CNT(8))
  x_ack_buf_vld_wptr_mux (
  .din(ack_buf_vld),
  .sel(ack_buf_wptr[7:0]),
  .dout(ack_buf_vld_by_wptr),
  .err()
  );

assign ack_buf_rdy = (ack_buf_wptr[7:0] != ack_buf_rptr[7:0]) || !ack_buf_vld_by_wptr;

// ack buf entry info indexed by rptr, ..., rptr+7
assign ack_buf_info_sel[0] = ack_buf_rptr[7:0];

generate
  for(i=1; i<8; i++) begin: ack_buf_info_sel_gen
    assign ack_buf_info_sel[i] = {ack_buf_rptr[7-i:0], ack_buf_rptr[7:8-i]};
  end
endgenerate

generate
  for(i=0; i<8; i++) begin: ack_buf_info_gen
    one_hot_mux #(.WIDTH(1), .CNT(8))
      x_ack_buf_vld_mux (
      .din(ack_buf_vld),
      .sel(ack_buf_info_sel[i]),
      .dout(ack_buf_vld_by_rptr[i]),
      .err()
      );

    one_hot_mux_2d #(.WIDTH(SLV_CNT), .CNT(8))
      x_ack_buf_sid_mux (
      .din(ack_buf_sid),
      .sel(ack_buf_info_sel[i]),
      .dout(ack_buf_sid_by_rptr[i]),
      .err()
      );
//    assign rptr_index[i][2:0] = ack_buf_rptr[2:0] + i;
//    assign ack_buf_vld_by_rptr[i] = ack_buf_vld[rptr_index[i]];
//    assign ack_buf_mid_by_rptr[i] = ack_buf_mid[rptr_index[i]];
//    assign ack_buf_sid_by_rptr[i] = ack_buf_sid[rptr_index[i]];
  end
endgenerate

// priority encoder for wbptr (each slave's ackdata write back entry index) generation
// the entry indexed by rptr has the highest priority
generate
  for(i=0; i<SLV_CNT; i++) begin: ack_buf_wbptr_gen
    always @(*) begin
      if(!ack_buf_vld_by_rptr[0] && ack_buf_sid_by_rptr[0][i]) begin
        wbptr[i] = ack_buf_rptr[7:0];
      end else if(!ack_buf_vld_by_rptr[1] && ack_buf_sid_by_rptr[1][i]) begin
        wbptr[i] = {ack_buf_rptr[6:0], ack_buf_rptr[7]};
      end else if(!ack_buf_vld_by_rptr[2] && ack_buf_sid_by_rptr[2][i]) begin
        wbptr[i] = {ack_buf_rptr[5:0], ack_buf_rptr[7:6]};
      end else if(!ack_buf_vld_by_rptr[3] && ack_buf_sid_by_rptr[3][i]) begin
        wbptr[i] = {ack_buf_rptr[4:0], ack_buf_rptr[7:5]};
      end else if(!ack_buf_vld_by_rptr[4] && ack_buf_sid_by_rptr[4][i]) begin
        wbptr[i] = {ack_buf_rptr[3:0], ack_buf_rptr[7:4]};
      end else if(!ack_buf_vld_by_rptr[5] && ack_buf_sid_by_rptr[5][i]) begin
        wbptr[i] = {ack_buf_rptr[2:0], ack_buf_rptr[7:3]};
      end else if(!ack_buf_vld_by_rptr[6] && ack_buf_sid_by_rptr[6][i]) begin
        wbptr[i] = {ack_buf_rptr[1:0], ack_buf_rptr[7:2]};
      end else if(!ack_buf_vld_by_rptr[7] && ack_buf_sid_by_rptr[7][i]) begin
        wbptr[i] = {ack_buf_rptr[0], ack_buf_rptr[7:1]};
      end else begin
        wbptr[i] = 8'b0;
      end
    end
  end
endgenerate

// Since the 1st pending slot matches each slave on a 1-on-1 basis, each entry in wbptr[] has different values
// Thus, the transposed array of wbptr[] contains the select for slave-to-slot mux. And wbptr_t[] are also one-hot.
generate
  for(i=0; i<SLV_CNT; i++) begin: transpose_outter
    for(j=0; j<8; j++) begin: transpose_inner
      assign wbptr_t[j][i] = wbptr[i][j];
    end
  end
endgenerate

// slave to pending slot mux
generate
  for(i=0; i<8; i++) begin: ack_buf_wb_gen
    one_hot_mux #(.WIDTH(1), .CNT(SLV_CNT))
      x_ack_buf_wbvld_mux (
      .din(slv_ack_empty_n),
      .sel(wbptr_t[i]),
      .dout(ack_buf_wbvld[i]),
      .err()
      );

    one_hot_mux_2d #(.WIDTH(16), .CNT(SLV_CNT))
      x_ack_buf_wbdata_mux (
      .din(slv_ack_dout),
      .sel(wbptr_t[i]),
      .dout(ack_buf_wbdata[i]),
      .err()
      );
  end
endgenerate

// master ack afifo demux
one_hot_mux_2d #(.WIDTH(32), .CNT(8))
  x_ack_buf_data_mux (
  .din(ack_buf_data),
  .sel(ack_buf_rptr[7:0]),
  .dout(ack_buf_data_by_rptr),
  .err()
  );

one_hot_mux_2d #(.WIDTH(MST_CNT), .CNT(8))
  x_ack_buf_mid_mux (
  .din(ack_buf_mid),
  .sel(ack_buf_rptr[7:0]),
  .dout(ack_buf_mid_by_rptr),
  .err()
  );

one_hot_demux_2d #(.WIDTH(32), .CNT(MST_CNT))
  x_mst_ack_din_demux (
  .din(ack_buf_data_by_rptr[31:0]),
  .sel(ack_buf_mid_by_rptr[MST_CNT-1:0]),
  .dout(mst_ack_din)
  );

assign ack_buf_pop = rx_timeout || ack_buf_vld_by_rptr[0];
assign mst_ack_push[MST_CNT-1:0] = ack_buf_mid_by_rptr[MST_CNT-1:0] & {MST_CNT{ack_buf_pop}};

// 1ms timeout @ 250MHz
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    tx_cnt[17:0] <= 18'h0;
  end else if(tx_timeout_rst) begin
    tx_cnt[17:0] <= 18'h0;
  end else if(tx_cnt[17:0] != 18'd25_0000) begin
    tx_cnt[17:0] <= tx_cnt[17:0] + 1'b1;
  end
end

assign tx_timeout = tx_cnt[17:0] == 18'd25_0000;

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    rx_cnt[17:0] <= 18'h0;
  end else if(rx_timeout_rst) begin
    rx_cnt[17:0] <= 18'h0;
  end else if(rx_cnt[17:0] != 18'd25_0000) begin
    rx_cnt[17:0] <= rx_cnt[17:0] + 1'b1;
  end
end

assign rx_timeout = tx_cnt[17:0] == 18'd25_0000;
assign rx_timeout_rst = ack_buf_pop;

endmodule
