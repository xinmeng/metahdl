//# ************************************************************************** #
//# * Copyright (C) 2014 TrustNetIC, Inc.                                    * #
//# *                                                                        * #
//# * ALL THE CONTENTS CONTAINED HEREIN ARE CONFIDENTIAL AND PROPRIETARY     * #
//# *   AND ARE NOT TO BE DISCLOSED OUTSIDE OF TRUSTNETIC (HANG ZHOU)        * #
//# *     INFORMATION EXCEPT UNDER A NON-DISCLOSURE AGREEMENT (NDA).         * #
//# *                                                                        * #
//# *                             _           _                              * #
//# *                            | | __ _  __| | ___                         * #
//# *                         _  | |/ _` |/ _` |/ _ \                        * #
//# *                        | |_| | (_| | (_| |  __/                        * #
//# *                         \___/ \__,_|\__,_|\___|                        * #
//# *                                                                        * #
//# *                                                                        * #
//# *                                                                        * #
//# *    Author :  Liguo Qian                                                * #
//# ************************************************************************** #

module shifter (
  data_in,
  data_in_sbcnt_hdr,
  data_in_bcnt,
  data_in_eop,
  data_in_vld,
  data_in_rdy,
  data_out,
  data_out_eop,
  data_out_vld,
  data_out_accept_bytes,
  data_out_bcnt,
  data_out_rdy,
  clk,
  rst_n
);

`include "common_funcs.vh"

parameter DIN_WIDTH     = 256;
parameter DOUT_WIDTH    = 128;

parameter DIN_BCNT      = (log2(DIN_WIDTH/8)+1);
parameter DOUT_BCNT     = (log2(DOUT_WIDTH/8)+1);
//parameter DIN_BCNT      = 6;
//parameter DOUT_BCNT     = 5;
parameter SHIFTER_BCNT  = (log2(DIN_WIDTH/8+DOUT_WIDTH/8)+1);

localparam SHIFTER_WIDTH = DIN_WIDTH + DOUT_WIDTH;
//localparam SHIFTER_BCNT  = log2(SHIFTER_WIDTH/8);
localparam SHIFTER_BCNT_SUB_DOUT_BCNT = SHIFTER_BCNT - DOUT_BCNT;

input  [DIN_WIDTH-1:  0] data_in;

// the shifted bytes number in first dword
input  [1            :0] data_in_sbcnt_hdr; 

// the total byte count for data in 
input  [DIN_BCNT-1   :0] data_in_bcnt; // [5:0]
input                    data_in_eop;
input                    data_in_vld;
output                   data_in_rdy;

output [DOUT_WIDTH-1 :0] data_out;
output                   data_out_eop;
output                   data_out_vld;
output [DOUT_BCNT-1  :0] data_out_bcnt; //[4:0]
input                    data_out_rdy; // when both data_out_vld and data_out_rdy asserted means the data is accepted

// when both data_out_vld and data_out_rdy are asserted, 
input  [DOUT_BCNT-1  :0] data_out_accept_bytes; 

input                    clk;
input                    rst_n;

reg [SHIFTER_BCNT-1  :0] remain_bcnt;
reg [DIN_WIDTH-1     :0] data_in_shifted;
reg [SHIFTER_WIDTH-1 :0] remain_data;
reg [SHIFTER_WIDTH+DIN_WIDTH-1 :0] remain_data_shift_in;
reg                      eop_flag;
wire                     data_out_eop_accept;

wire [SHIFTER_WIDTH-1:0] remain_data_shifted;
wire [SHIFTER_WIDTH+DIN_WIDTH-1:0] remain_data_append_din;

//shifter byte count
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    remain_bcnt[SHIFTER_BCNT-1:0] <= {SHIFTER_BCNT{1'b0}};
  else if (data_in_vld && data_in_rdy && data_out_vld && data_out_rdy) 
    remain_bcnt[SHIFTER_BCNT-1:0] <= remain_bcnt[SHIFTER_BCNT-1:0] + data_in_bcnt[DIN_BCNT-1:0] - data_out_accept_bytes[DOUT_BCNT-1:0];
  else if (data_in_vld && data_in_rdy)
    remain_bcnt[SHIFTER_BCNT-1:0] <= remain_bcnt[SHIFTER_BCNT-1:0] + data_in_bcnt[DIN_BCNT-1:0];
  else if (data_out_vld && data_out_rdy)
    remain_bcnt[SHIFTER_BCNT-1:0] <= remain_bcnt[SHIFTER_BCNT-1:0] - data_out_accept_bytes[DOUT_BCNT-1:0];
end 

// shift the hole bytes in header
always_comb begin
  unique case (data_in_sbcnt_hdr[1:0])
    2'b11: data_in_shifted[DIN_WIDTH-1:0] = {24'h0, data_in[DIN_WIDTH-1:24]};
    2'b10: data_in_shifted[DIN_WIDTH-1:0] = {16'h0, data_in[DIN_WIDTH-1:16]};
    2'b01: data_in_shifted[DIN_WIDTH-1:0] = {8'h0, data_in[DIN_WIDTH-1:8]};
    default: data_in_shifted[DIN_WIDTH-1:0] = data_in[DIN_WIDTH-1:0];
  endcase
end 

assign remain_data_shifted[SHIFTER_WIDTH-1:0] = remain_data[SHIFTER_WIDTH-1:0] << ({(SHIFTER_WIDTH/8),3'b000} - {remain_bcnt[SHIFTER_BCNT-1:0],3'b000});
assign remain_data_append_din[SHIFTER_WIDTH+DIN_WIDTH-1:0] = {data_in_shifted[DIN_WIDTH-1:0],remain_data_shifted[SHIFTER_WIDTH-1:0]};

// combine data in to remain data shifter
always_comb begin
  if (data_in_vld && data_in_rdy)
    remain_data_shift_in[SHIFTER_WIDTH+DIN_WIDTH-1:0] = remain_data_append_din[SHIFTER_WIDTH+DIN_WIDTH-1:0] >> ({SHIFTER_WIDTH/8,3'b000} - {remain_bcnt[SHIFTER_BCNT-1:0],3'b000});
  else  
    remain_data_shift_in[SHIFTER_WIDTH+DIN_WIDTH-1:0] = {{DIN_WIDTH{1'b0}},remain_data[SHIFTER_WIDTH-1:0]};
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    remain_data[SHIFTER_WIDTH-1:0] <= {SHIFTER_WIDTH{1'b0}};
  else if (data_out_vld && data_out_rdy)
    remain_data[SHIFTER_WIDTH-1:0] <= remain_data_shift_in[SHIFTER_WIDTH+DIN_WIDTH-1:0] >> {data_out_accept_bytes[DOUT_BCNT-1:0],3'b000};
  else 
    remain_data[SHIFTER_WIDTH-1:0] <= remain_data_shift_in[SHIFTER_WIDTH+DIN_WIDTH-1:0];
end

assign data_out_eop = eop_flag & (remain_bcnt[SHIFTER_BCNT-1:0] <= DOUT_WIDTH/8);

assign data_out[DOUT_WIDTH-1:0] = remain_data[DOUT_WIDTH-1:0];

// two conditions
// 1. remain_bcnt >= DOUT BYTES;
// 2. eop flag asserted 
assign data_out_vld = (remain_bcnt[SHIFTER_BCNT-1:0] >= DOUT_WIDTH/8) | eop_flag; 

// for eop data beat, the data_out_bcnt equals to remain_bcnt
// for non eop data beat, always be all bytes valid 
assign data_out_bcnt[DOUT_BCNT-1:0] = data_out_eop ? (remain_bcnt[SHIFTER_BCNT-1:0] > DOUT_WIDTH/8 ? DOUT_WIDTH/8 : remain_bcnt[SHIFTER_BCNT-1:0]) : DOUT_WIDTH/8; 

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    eop_flag <= 1'b0;
  else if (data_in_eop && data_in_vld && data_in_rdy)
    eop_flag <= 1'b1;
  else if (data_out_eop_accept)
    eop_flag <= 1'b0; 
end

assign data_out_eop_accept = data_out_rdy & data_out_eop && data_out_vld && 
                             (SHIFTER_BCNT_SUB_DOUT_BCNT ? ({{SHIFTER_BCNT_SUB_DOUT_BCNT{1'b0}},data_out_accept_bytes[DOUT_BCNT-1:0]} == remain_bcnt[SHIFTER_BCNT-1:0]) : (data_out_accept_bytes[DOUT_BCNT-1:0] == remain_bcnt[SHIFTER_BCNT-1:0])); 
// accept incoming data when
// 1: in eop phase, block it until the eop is sent out
// 2. in non-eop phase,   
assign data_in_rdy = eop_flag ? data_out_eop_accept : 
                                ((SHIFTER_WIDTH/8 - remain_bcnt[SHIFTER_BCNT-1:0] + (data_out_vld && data_out_rdy ? data_out_accept_bytes[DOUT_BCNT-1:0] : 1'b0)) >= data_in_bcnt[DIN_BCNT-1:0]);

// remained data should be 384b
//
// in_vld = !eop_flag && (remain_bcnt <= data_in_bcnt ||
// remain_bcnt-data_out_bcnt<=data_in_bcnt)
// || (eop && remain_bcnt<=16 && data_out_rdy)
//
//out_data=remain_data[383:128]
//out_vld = remain_bcnt>=16
//
//eop flag will be set at the next cycle when input eop assert
//eop flag will be reset at the next cycle when output eop assert
//
/*
wire [DIN_WIDTH-1:0] data_in_shifted_swap;
assign data_in_shifted_swap[DIN_WIDTH-1:0] = {
                                   data_in_shifted[7:0],
                                   data_in_shifted[15:8],
				   data_in_shifted[23:16],
				   data_in_shifted[31:24],
				   data_in_shifted[39:32],
				   data_in_shifted[47:40],
				   data_in_shifted[55:48],
				   data_in_shifted[63:56],
				   data_in_shifted[71:64],
				   data_in_shifted[79:72],
				   data_in_shifted[87:80],
				   data_in_shifted[95:88],
				   data_in_shifted[103:96],
				   data_in_shifted[111:104],
				   data_in_shifted[119:112],
				   data_in_shifted[127:120],
				   data_in_shifted[135:128],
				   data_in_shifted[143:136],
				   data_in_shifted[151:144],
				   data_in_shifted[159:152],
				   data_in_shifted[167:160],
				   data_in_shifted[175:168],
				   data_in_shifted[183:176],
				   data_in_shifted[191:184],
				   data_in_shifted[199:192],
				   data_in_shifted[207:200],
				   data_in_shifted[215:208],
				   data_in_shifted[223:216],
				   data_in_shifted[231:224],
				   data_in_shifted[239:232],
				   data_in_shifted[247:240],
				   data_in_shifted[255:248]
				 };


always @(posedge clk)
  if (data_in_vld && data_in_rdy)
    $display("liguo debug: shift_din = %h, shift_bcnt = 0d%d, shift_in_eop = %h", data_in_shifted_swap[DIN_WIDTH-1:0], data_in_bcnt[DIN_BCNT-1:0], data_in_eop);

always @(posedge clk)
  if (data_out_vld && data_out_rdy)
    $display("liguo debug: shift_dout = %h, shift_bcnt = 0d%d, shift_out_eop = %h", data_out[DOUT_WIDTH-1:0], data_out_bcnt[DOUT_BCNT-1:0], data_out_eop);
*/
endmodule
