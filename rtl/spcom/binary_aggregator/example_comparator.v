module example_comparator (
                           key_a, data_a, vld_a,
                           key_b, data_b, vld_b,
                           key_w, data_w, vld_w
                           );


   parameter KEY_WIDTH  = 3;
   parameter DATA_WIDTH = 4;


   input [KEY_WIDTH-1:0]  key_a, key_b;
   input [DATA_WIDTH-1:0] data_a, data_b;
   input                  vld_a, vld_b;

   output reg [KEY_WIDTH-1:0]  key_w;
   output reg [DATA_WIDTH-1:0] data_w;
   output reg                  vld_w;
   
   always @(*) begin
      if (key_a < key_b || !vld_a) begin
         key_w  = key_b;
         data_w = data_b;
         vld_w  = vld_b;
      end
      else begin
         key_w  = key_a;
         data_w = data_a;
         vld_w  = vld_a;
      end
   end // always @ (*)

endmodule // example_comparator

   
