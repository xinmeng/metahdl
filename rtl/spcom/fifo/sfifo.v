module sfifo(
             clk,
             data_in,
             data_out,
             empty_n, empty,
             full_n,  full,
             rd_en,
             rst_n,
             wr_en
             );

`include "common_funcs.vh"

   parameter      DEPTH     = 4;
   parameter      WIDTH     = 8;

   localparam     BADDR     = log2(DEPTH);
   localparam     CNT_WIDTH = BADDR+1;

   // &Ports @10
   input          clk;     
   input [WIDTH-1:0] data_in; 
   input             rd_en;   
   input             rst_n;   
   input             wr_en;   
   output [WIDTH-1:0] data_out; 
   output             empty_n, empty; 
   output             full_n, full;  

   reg [CNT_WIDTH-1:0] cnt      ;
   reg [CNT_WIDTH-1:0] cnt_nxt  ;
   reg                 empty_n, empty  ;
   reg                 full_n,  full   ;
   reg [BADDR-1:0]     rd_ptr   ;
   reg [WIDTH-1:0]     stack  [DEPTH-1:0]; 
   reg [BADDR-1:0]     wr_ptr   ;

   wire [1:0]          act      ;
   wire                clk      ;
   wire [WIDTH-1:0]    data_in  ;
   wire [WIDTH-1:0]    data_out ;
   wire                rd_en    ;
   wire                rst_n    ;
   wire                wr_en    ;

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       full_n <= 1'b1;
     else
       full_n <= (cnt_nxt != DEPTH);

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       empty_n <= 1'b0;
     else
       empty_n <= (cnt_nxt != {CNT_WIDTH{1'b0}});

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       full <= 1'b0;
     else
       full <= (cnt_nxt == DEPTH);

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       empty <= 1'b1;
     else
       empty <= (cnt_nxt == {CNT_WIDTH{1'b0}});
   

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       wr_ptr <= {BADDR{1'b0}};
     else if(wr_en)
       wr_ptr <= (wr_ptr == DEPTH-1) ? {BADDR{1'b0}} : (wr_ptr + 1'b1);

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       rd_ptr <= {BADDR{1'b0}};
     else if(rd_en)
       rd_ptr <= (rd_ptr == DEPTH-1) ? {BADDR{1'b0}} : (rd_ptr + 1'b1);

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       cnt <= {CNT_WIDTH{1'b0}};
     else
       cnt <= cnt_nxt;

   assign act[1:0] = {wr_en,rd_en};

   always @( * ) begin
     case(act[1:0])
       2'b01:   cnt_nxt = cnt - 1'b1;
       2'b10:   cnt_nxt = cnt + 1'b1;
       default: cnt_nxt = cnt;
     endcase
   end

   always @(posedge clk or negedge rst_n) begin
      integer i;
      if (!rst_n)
        for (i=0; i<DEPTH; i=i+1)
          stack[i] <= {WIDTH{1'b0}};
      else if(wr_en)
        for (i=0; i<DEPTH; i=i+1)
          if (wr_ptr == i )
            stack[i] <= data_in;
          else
            stack[i] <= stack[i];
      else
        for (i=0; i<DEPTH; i=i+1)
          stack[i] <= stack[i];
   end

   assign data_out[WIDTH-1:0] = stack[rd_ptr];

`ifdef RTL_ASSERTION_ON
   w_ful: assert property (@(posedge clk) not (wr_en && full))
     else
   $fatal("[ERROR] FIFO write occur when FIFO is !full_n");
   r_empt: assert property (@(posedge clk) not (rd_en && empty))
     else
   $fatal("[ERROR] FIFO read occur when FIFO is !empty_n");
`endif

endmodule


