module tag_mng (clk,
  rst_n,
  push,
  tag_in,
  pop,
  tag_out,
  tag_vld,
  ext_tag,
  last_tag
);

`include "common_funcs.vh"

parameter  TAG_NUM  = 8;
localparam WIDTH    = log2(TAG_NUM);  

input        clk;
input        rst_n;
input        ext_tag;

input        push;    // tag recycle valid
input  [7:0] tag_in;  // recycled tag id

input        pop; // pop a valid tag
output [7:0] tag_out; // available tag id 
output       tag_vld; // tag_out[7:0] is valid

output       last_tag;

wire [7        :0] push_tag;
reg  [TAG_NUM-1:0] tag_bitmap_r;
wire               tag_vld;
wire [TAG_NUM-1:0] tag_bitmap;


wire  [7:0] pop_tag [0:TAG_NUM-1];
wire  [7:0] pop_tag_r;
wire [WIDTH-1:0] selected_tag;
wire [TAG_NUM-1:0] tag_bitmap_onehot;

//assign tag_vld = |tag_bitmap[TAG_NUM-1:0];

assign push_tag[7:0] = tag_in[7:0];

wire [TAG_NUM-1:0] onehot_sig;
wire [TAG_NUM-1:0] onehot_sig_s1;
wire [TAG_NUM-1:0] onehot_sig_msk;

assign onehot_sig[TAG_NUM-1:0] = tag_bitmap[TAG_NUM-1:0];
assign onehot_sig_s1[TAG_NUM-1:0] = onehot_sig[TAG_NUM-1:0] - 1'b1;
assign onehot_sig_msk[TAG_NUM-1:0] = ~(onehot_sig_s1[TAG_NUM-1:0] ^ onehot_sig[TAG_NUM-1:0]);
assign last_tag = ~(|(onehot_sig_msk[TAG_NUM-1:0] & onehot_sig[TAG_NUM-1:0]));


assign tag_bitmap[TAG_NUM-1:0] = ext_tag ? tag_bitmap_r[TAG_NUM-1:0] : 
                                           {{(TAG_NUM/2){1'b0}}, {(TAG_NUM/2){1'b1}}} & tag_bitmap_r[TAG_NUM-1:0]; 

// tag_bitmap[IDX]=1'b1 mean the tag of IDX is available
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    tag_bitmap_r[TAG_NUM-1: 0] <= {TAG_NUM{1'b1}};
  else begin
    if (push)
      tag_bitmap_r[push_tag[WIDTH-1:0]] <= 1'b1;
    if (pop && tag_vld)
      tag_bitmap_r[tag_out[WIDTH-1:0]]  <= 1'b0;
  end
end

assign tag_out[7:0] = pop_tag_r[7:0];

genvar i;
generate 
  for(i=0; i<TAG_NUM; i=i+1) begin: tag
    assign pop_tag[i] = tag_bitmap[i] ? i: 8'd0;
  end 
endgenerate

right_find_1st_one #(.WIDTH(TAG_NUM)) x_right_find_1st_one(
  .din(tag_bitmap[TAG_NUM-1:0]),
  .dout(tag_bitmap_onehot[TAG_NUM-1:0])
);

onehot_to_binary #(.DIN_WIDTH(TAG_NUM), .DOUT_WIDTH(WIDTH)) x_onehot_to_binary (
  .onehot_in(tag_bitmap_onehot[TAG_NUM-1:0]),
  .binary_out(selected_tag[WIDTH-1:0])
);

assign pop_tag_r[7:0] = pop_tag[selected_tag[WIDTH-1:0]];
assign tag_vld = |tag_bitmap[TAG_NUM-1:0];

/*
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pop_tag_r[7:0] <= 8'h0;
    tag_vld <= 1'b0;
  end
  else begin   
    pop_tag_r[7:0] <= pop_tag[selected_tag[WIDTH-1:0]];
    tag_vld <= |tag_bitmap[TAG_NUM-1:0];
  end
end
*/
endmodule
