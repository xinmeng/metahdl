module ram_2p(clka, addra, dina, ena, wr, 
              clkb, addrb, doutb, enb);

`include "common_funcs.vh"

   parameter WIDTH      = 64;
   parameter DEPTH      = 32;
   parameter ADDR_WIDTH = log2(DEPTH);

   input     clka, ena, wr, clkb, enb;
   input [ADDR_WIDTH-1:0] addra, addrb;
   input [WIDTH-1:0]      dina;
   output [WIDTH-1:0]     doutb;

`ifdef USE_MDA
   reg [WIDTH-1:0] data [DEPTH-1:0];
   reg [WIDTH-1:0] douta, doutb;
   always @(posedge clka) begin
     if (ena & wr) data[addra] <= dina;
   end

   always @(posedge clkb) begin
     if (enb) doutb <= data[addrb];
   end
`else // !`ifdef USE_MDA
   generate
      case ({DEPTH, WIDTH})
        {16384, 128}:
          ram_16384x128_2p ram_16384x128_2p
            (
             .clka (clka), .ena (ena), .wea (wr), .addra (addra), .dina (dina),
             .clkb (clkb), .enb (enb),            .addrb (addrb), .doutb (doutb)
             );

        {512, 128}:
          ram_512x128_2p ram_512x128_2p
            (
             .clka (clka), .ena (ena), .wea (wr), .addra (addra), .dina (dina),
             .clkb (clkb), .enb (enb),            .addrb (addrb), .doutb (doutb)
             );

        {192, 128}:
          ram_192x128_2p ram_192x128_2p
            (
             .clka (clka), .ena (ena), .wea (wr), .addra (addra), .dina (dina),
             .clkb (clkb), .enb (enb),            .addrb (addrb), .doutb (doutb)
             );

        {256, 262}:
          ram_256x262_2p ram_256x262_2p
            (
             .clka (clka), .ena (ena), .wea (wr), .addra (addra), .dina (dina),
             .clkb (clkb), .enb (enb),            .addrb (addrb), .doutb (doutb)
             );

        {32768, 128}:
          ram_32768x128_2p ram_32768x128_2p
            (
             .clka (clka), .ena (ena), .wea (wr), .addra (addra), .dina (dina),
             .clkb (clkb), .enb (enb),            .addrb (addrb), .doutb (doutb)
             );

        {64, 128}:
          ram_64x128_2p ram_64x128_2p
            (
             .clka (clka), .ena (ena), .wea (wr), .addra (addra), .dina (dina),
             .clkb (clkb), .enb (enb),            .addrb (addrb), .doutb (doutb)
             );

        default: 
          initial begin
             $display("**Error:%m, 2-port memory for DEPTH=%d WIDTH=%d is not generated.", DEPTH, WIDTH);
             $finish;
          end
      endcase // case ({DEPTH, WIDTH})
   endgenerate
`endif

endmodule
