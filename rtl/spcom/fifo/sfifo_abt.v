module sfifo_abt (clk, rst_n, 
                  full, full_n, 
                  wr_en, data_in, eot, abort, 
                  empty, empty_n, 
                  rd_en, data_out);

`include "common_funcs.vh"


   parameter DEPTH = 4;
   parameter WIDTH = 8;

   localparam ADDR_W = log2(DEPTH);
   localparam CNT_W  = ADDR_W + 1;

   input      clk, rst_n;

   output     full, full_n;
   input      wr_en, eot, abort;
   input [WIDTH-1:0] data_in;

   output            empty, empty_n;
   input             rd_en;
   output [WIDTH-1:0] data_out;

   reg [CNT_W-1:0]    cnt, cnt_nxt;
   reg [WIDTH-1:0]    stack [DEPTH-1:0];
   reg                full, full_n,  empty, empty_n;
   wire               overflow;

   reg [ADDR_W-1:0]   wr_ptr, nxt_wr_ptr, 
                      rd_ptr, nxt_rd_ptr, 
                      tmp_wr_ptr, nxt_tmp_wr_ptr;
   

   // - * Internal Storage
   always @(posedge clk or negedge rst_n) begin
      integer i;
      if (!rst_n)
        for (i=0; i<DEPTH; i=i+1)
          stack[i] <= {WIDTH{1'b0}};
      else if(wr_en)
        for (i=0; i<DEPTH; i=i+1)
          if (tmp_wr_ptr == i )
            stack[i] <= data_in;
          else
            stack[i] <= stack[i];
      else
        for (i=0; i<DEPTH; i=i+1)
          stack[i] <= stack[i];
   end

   // - * Read Port
   assign data_out[WIDTH-1:0] = stack[rd_ptr];

   
   // - * Flags
   // - If abort occurs, all flags roll back to
   // - last flag status. 
   reg        full_int, full_n_int;
   always @(posedge clk or negedge rst_n)
     if (!rst_n) begin
        full    <= 1'b0;
        full_n  <= 1'b1;
        empty   <= 1'b1;
        empty_n <= 1'b0;
     end
     else if (abort) begin
        full    <= full_int;
        full_n  <= full_n_int;
        empty   <= empty;
        empty_n <= empty_n;
     end
     else begin
        case ({wr_en, rd_en})
          2'b01: begin
             full    <= 1'b0;
             full_n  <= 1'b1;
             empty   <= nxt_rd_ptr == wr_ptr;
             empty_n <= nxt_rd_ptr != wr_ptr;
          end

          2'b10: begin
             full    <= nxt_tmp_wr_ptr == rd_ptr;
             full_n  <= nxt_tmp_wr_ptr != rd_ptr;
             if (eot && !abort)  begin
                empty   <= 1'b0;
                empty_n <= 1'b1;
             end
             else begin
                empty   <= empty;
                empty_n <= empty_n;
             end
          end

          2'b11: begin
             full   <= full;
             full_n <= full_n;
             if (eot && !abort) begin
                empty   <= empty;
                empty_n <= empty_n;
             end
             else begin
                empty   <= nxt_rd_ptr == wr_ptr;
                empty_n <= nxt_rd_ptr != wr_ptr;
             end
          end

          default: begin
             full    <= full;
             full_n  <= full_n;
             empty   <= empty;
             empty_n <= empty_n;
          end
        endcase // case ({good_eot, rd_en})
      end 
   // - * Pointer
   assign nxt_rd_ptr     = (rd_ptr == DEPTH-1) ? {ADDR_W{1'b0}} : (rd_ptr + 1'b1);
   assign nxt_tmp_wr_ptr = (tmp_wr_ptr == DEPTH-1) ? {ADDR_W{1'b0}} : (tmp_wr_ptr + 1'b1);
   assign nxt_wr_ptr     = nxt_tmp_wr_ptr;
   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       wr_ptr <= {ADDR_W{1'b0}};
     else if(wr_en && eot && !abort)
       wr_ptr <= nxt_wr_ptr;
     else
       wr_ptr <= wr_ptr;

   always @(posedge clk or negedge rst_n)
     if(!rst_n)
       rd_ptr <= {ADDR_W{1'b0}};
     else if(rd_en)
       rd_ptr <= nxt_rd_ptr;
     else
       rd_ptr <= rd_ptr;

   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       tmp_wr_ptr <= {ADDR_W{1'b0}};
     else if (abort)
       tmp_wr_ptr <= wr_ptr;
     else if (wr_en)
       tmp_wr_ptr <= nxt_tmp_wr_ptr;
     else
       tmp_wr_ptr <= tmp_wr_ptr;


     // - * Internal Flags for roll back
     // - If EOT occurs and no abort, flags are
     // - committed.
     always @(posedge clk or negedge rst_n)
       if (!rst_n) begin
          full_int    <= 1'b0;
          full_n_int  <= 1'b1;
       end
       else if (wr_en && eot && !abort) begin
          full_int    <= full;
          full_n_int  <= full_n;
       end
       else begin
          full_int    <= full_int;
          full_n_int  <= full_n_int;
       end

endmodule // sfifo_abt

