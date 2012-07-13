parameter WIDTH = 32;
parameter SW_MASTER_CNT = 5;


input  [SW_MASTER_CNT*WIDTH-1:0] wr_data;
input  [SW_MASTER_CNT-1:0]       wr_en;

output [WIDTH-1:0] wr_data_winner;

wire  [SW_MASTER_CNT*WIDTH-1:0] wr_data;
wire  [SW_MASTER_CNT-1:0]       wr_en;

wire  [WIDTH-1:0] wr_data_winner;


assign wr_en_m1[MASTER_CNT-1:0]     = wr_en[MASTER_CNT-1:0] - 1'b1;
assign wr_en_xor[MASTER_CNT-1:0]    = wr_en[MASTER_CNT-1:0] ^ wr_en_m1[MASTER_CNT-1:0];
assign wr_en_winner[MASTER_CNT-1:0] = wr_en[MASTER_CNT-1:0] & wr_en_xor[MASTER_CNT-1:0];

one_hot_mux #(.WIDTH (WIDTH), .CNT (SW_MASTER_CNT)) 
x_mux (.din  (wr_data), 
       .sel  (wr_en_winner),
       .dout (wr_data_winner), 
       .err ());


