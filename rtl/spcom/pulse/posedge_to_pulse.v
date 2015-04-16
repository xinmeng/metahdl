module posedge_to_pulse (clk, rst_n, din, pout);
   input clk, rst_n, din;
   output pout;

   wire   tpulse;
   toggle_to_pulse toggle_to_pulse (clk, rst_n, din, tpulse);

   assign pout = din & tpulse;
endmodule
