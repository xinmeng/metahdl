module ram_dp(clka, addra, dina, ena, wra, douta, 
              clkb, addrb, dinb, enb, wrb, doutb);

`include "common_funcs.vh"
   
   parameter WIDTH      = 64;
   parameter DEPTH      = 32;
   parameter ADDR_WIDTH = log2(DEPTH);

   input     clka, ena, wra, clkb, enb, wrb;
   input [ADDR_WIDTH-1:0] addra, addrb;
   input [WIDTH-1:0]      dina, dinb;
   output [WIDTH-1:0]     douta, doutb;

`ifdef USE_MDA
   reg [WIDTH-1:0] data [DEPTH-1:0];
   reg [WIDTH-1:0] douta, doutb;
   always @(posedge clka) begin
     if (ena && wra) begin
       data[addra] <= (enb & wrb) ? {WIDTH{1'bx}} : dina;
     end
     if (ena) douta <= data[addra];
   end

   always @(posedge clkb) begin
     if (enb && wrb) begin
       data[addrb] <= (ena & wra) ? {WIDTH{1'bx}} : dinb;
     end
     if (enb) doutb <= data[addrb];
   end
`else // !`ifdef USE_MDA
   generate
      case ({DEPTH, WIDTH})
        default:
          initial begin
             $display("**Error:%m, Dual-port memory for DEPTH=%d WIDTH=%d is not generated.", DEPTH, WIDTH);
             $finish;
          end
      endcase
   endgenerate


`endif

endmodule
