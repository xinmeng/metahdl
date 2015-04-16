// **************************************************************************
// * Copyright (C) 2004 Hifn, Inc.                                          *
// *                                                                        *
// * ALL THE CONTENTS CONTAINED HEREIN ARE CONFIDENTIAL AND PROPRIETARY     *
// * AND ARE NOT TO BE DISCLOSED OUTSIDE OF HIFN (HANG ZHOU) INFORMATION    *
// * EXCEPT UNDER A NON-DISCLOSURE AGREEMENT (NDA).                         *
// *                                                                        *
// *         ____   _    _   _ _____ _   _ _____ ____                       *
// *        |  _ \ / \  | \ | |_   _| | | | ____|  _ \                      *
// *        | |_) / _ \ |  \| | | | | |_| |  _| | |_) |                     *
// *        |  __/ ___ \| |\  | | | |  _  | |___|  _ <                      *
// *        |_| /_/   \_\_| \_| |_| |_| |_|_____|_| \_\                     *
// *                                                                        *
// *                                                                        *
// *                                                                        *
// *    Author      : Haiping Li                                            *
// *    Date        : 2008/12/12                                            *
// *    Description : rst_synczr generate a reset signal whose deassertion  *
// *                  is synchronized with clock posedge, while assertion   *
// *                  is asynchronous.                                      *
// **************************************************************************

// &ModuleBeg; @23
module rst_synczr(
  async_in_rst_n,
  async_out_rst_n,
  clk
);

// &Ports; @24
input        async_in_rst_n; 
input        clk;            
output       async_out_rst_n;

// &Regs; @25
reg          reset_sync0     ;
reg          reset_sync1     ;

// &Wires; @26
wire         async_in_rst_n  ;
wire         async_out_rst_n ;
wire         clk             ;


always @(posedge clk or negedge async_in_rst_n)
begin
if (!async_in_rst_n)
  begin
    reset_sync0 <= 1'b0;
    reset_sync1 <= 1'b0;
  end
else
  begin
    reset_sync0 <= 1'b1;
    reset_sync1 <= reset_sync0;
  end
end

//output
assign async_out_rst_n  = reset_sync1;

endmodule
