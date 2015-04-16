module negedge_to_pulse (clk, rst_n, din, pout);
   input clk, rst_n;
   input din;
   output pout;

   wire   tpulse;

   toggle_to_pulse toggle_to_pulse(clk, rst_n, din, tpulse);

   assign pout = (!din) & tpulse;
   
endmodule
