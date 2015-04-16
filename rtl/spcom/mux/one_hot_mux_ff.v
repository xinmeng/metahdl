module one_hot_mux_ff(clk, rst_n,
	              din, sel, sel_ff, dout_ff);
   parameter WIDTH         = 32;
   parameter CNT           = 5;

   input  logic  [WIDTH*CNT-1:0]  din;
   input  logic  [CNT-1:0] 	  sel;
   input  logic                  clk, rst_n;
   output logic sel_ff;
   output logic [WIDTH-1:0] 	  dout_ff;

   logic [WIDTH-1:0] dout;

   always @(posedge clk or negedge rst_n)
     if (!rst_n) begin
        sel_ff  <= {CNT{1'b0}};
        dout_ff <= {WIDTH{1'b0}};
     end
     else begin
        sel_ff  <= |sel;
        dout_ff <= dout;
     end

   one_hot_mux #(.WIDTH (WIDTH), .CNT (CNT), .ONE_HOT_CHECK (0))
     one_hot_mux (.din (din), 
                  .sel (sel), 
                  .dout (dout), 
                  .err ());
endmodule
