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

module onehot_to_binary (
  onehot_in,
  binary_out
);

parameter  DIN_WIDTH  = 16;
parameter  DOUT_WIDTH = (log2(DIN_WIDTH));

input  [DIN_WIDTH-1: 0] onehot_in;
output [DOUT_WIDTH-1:0] binary_out;

wire [DOUT_WIDTH-1:0] data [DIN_WIDTH-1:0]; 

genvar i;

generate 
  for (i=0; i<DIN_WIDTH; i=i+1) begin: value
    assign data[i] = i;
  end
endgenerate

one_hot_mux_2d #(.WIDTH(DOUT_WIDTH), .CNT(DIN_WIDTH), .ONE_HOT_CHECK(1)) x_one_hot_mux_2d (
  .din(data),
  .sel(onehot_in),
  .dout(binary_out),
  .err()
);

endmodule
