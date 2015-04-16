module toggle_to_pulse (clk, rst_n, din, pout);
   input clk, rst_n;
   input din;
   output pout;

   reg din_ff;

   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       din_ff <= 1'b0;
     else
       din_ff <= din;

   assign pout = din ^ din_ff;
endmodule
