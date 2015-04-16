// *****************************************************************************
// Function Name: func_get_nxt_ptr 
// Description  : This function will return the next pointer from
//                a ring based on base pointer, ring size and the jump entry
//                number.
//                The maximum jump entry number should less than or equal to
//                64
// Author       : Liguo Qian               
// *****************************************************************************
//`ifndef __ring_op_funcs_vh__
//`define __ring_op_funcs_vh__
function [15:0] func_get_curr_ptr;
   input [15:0] ptr;
   input [2:0]  rsz;

   unique case (rsz[2:0])
     3'd1:    func_get_curr_ptr[15:0] = ptr[15:0] & 16'h03FF; // 1K
     3'd2:    func_get_curr_ptr[15:0] = ptr[15:0] & 16'h07FF; // 2K
     3'd3:    func_get_curr_ptr[15:0] = ptr[15:0] & 16'h0FFF; // 4K
     3'd4:    func_get_curr_ptr[15:0] = ptr[15:0] & 16'h1FFF; // 8K
     default: func_get_curr_ptr[15:0] = ptr[15:0] & 16'h3FFF; // 16K
   endcase
   
endfunction

function [13:0] func_get_nxt_ptr;

input [13:0] ptr;
input [6:0] jmp_num;
input [2:0]  ring_sz;
  
reg [14:0] ptr_plus_jmp_num;

begin
   ptr_plus_jmp_num[14:0] = ptr[13:0] + jmp_num[6:0];

  unique case (ring_sz[2:0])
    3'd1: func_get_nxt_ptr[13:0] = (ptr_plus_jmp_num[10:0] == 11'h400) ? 14'h0 : ptr_plus_jmp_num[9:0]; //1k
    3'd2: func_get_nxt_ptr[13:0] = (ptr_plus_jmp_num[11:0] == 12'h800) ? 14'h0 : ptr_plus_jmp_num[10:0]; //2k
    3'd3: func_get_nxt_ptr[13:0] = (ptr_plus_jmp_num[12:0] == 13'h1000) ? 14'h0 : ptr_plus_jmp_num[11:0]; //4k
    3'd4: func_get_nxt_ptr[13:0] = (ptr_plus_jmp_num[13:0] == 14'h2000) ? 14'h0 : ptr_plus_jmp_num[12:0]; //8k
    default: func_get_nxt_ptr[13:0] = (ptr_plus_jmp_num[14:0] == 15'h4000) ? 14'h0 : ptr_plus_jmp_num[13:0]; //16k
  endcase

end

endfunction

// ****************************************************************************
// Function Name: func_get_entry_num  
// Description  : This function will return the valid entry number from
//                a ring based on ring size, write pointer and read pointer 
// Author       : Liguo Qian               
// ****************************************************************************
function [13:0] func_get_entry_num; 
  input [13:0] wptr;
  input [13:0] rptr;
  input [2:0]  ring_sz;
  input        wrap_en;

  reg [13:0] wptr_sub_rptr;
  reg        rptr_ahead;
begin
  wptr_sub_rptr[13:0] = wptr[13:0] - rptr[13:0];

  rptr_ahead = rptr[13:0] > wptr[13:0];

    if (wrap_en) begin
      unique case (ring_sz[2:0])
        3'd1: func_get_entry_num[13:0] = {4'd0,wptr_sub_rptr[9:0]}; //1k
        3'd2: func_get_entry_num[13:0] = {3'd0,wptr_sub_rptr[10:0]}; //2k
        3'd3: func_get_entry_num[13:0] = {2'd0,wptr_sub_rptr[11:0]}; //4k
        3'd4: func_get_entry_num[13:0] = {1'd0,wptr_sub_rptr[12:0]}; //8k
        default: func_get_entry_num[13:0] = wptr_sub_rptr[13:0]; //16k
      endcase
    end
    else begin
      unique case (ring_sz[2:0])
        3'd1: func_get_entry_num[13:0] = rptr_ahead ? (11'h400 - rptr[9:0]) : {4'd0, wptr_sub_rptr[9:0]}; 
        3'd2: func_get_entry_num[13:0] = rptr_ahead ? (12'h800 - rptr[10:0]) : {3'd0, wptr_sub_rptr[10:0]}; 
        3'd3: func_get_entry_num[13:0] = rptr_ahead ? (13'h1000 - rptr[11:0]) : {2'd0, wptr_sub_rptr[11:0]}; 
        3'd4: func_get_entry_num[13:0] = rptr_ahead ? (14'h2000 - rptr[12:0]) : {1'd0, wptr_sub_rptr[12:0]}; 
        default: func_get_entry_num[13:0] = rptr_ahead ? (15'h4000 - rptr[13:0]) : wptr_sub_rptr[13:0]; 
      endcase
    end
end

endfunction

// *************************************************************************
// Function Name: func_get_avail_space 
// Description  : This function will return the empty entry number from
//                a ring based on ring size, write pointer and read pointer 
// Author       : Liguo Qian               
// *************************************************************************
function [14:0] func_get_avail_space; 
  input [13:0] wptr;
  input [13:0] rptr;
  input [2:0]  ring_sz;
  input        wrap_en;

  reg [13:0] wptr_sub_rptr;
  reg wptr_ahead;
begin
  wptr_sub_rptr[13:0] = wptr[13:0] - rptr[13:0]; 

  wptr_ahead = (wptr[13:0] > rptr[13:0]); 

    if (wrap_en) begin  
      unique case (ring_sz[2:0])
        3'd1: func_get_avail_space[14:0] = 11'h400 - wptr_sub_rptr[9:0]; //1k 
        3'd2: func_get_avail_space[14:0] = 12'h800 - wptr_sub_rptr[10:0]; //2k 
        3'd3: func_get_avail_space[14:0] = 13'h1000 - wptr_sub_rptr[11:0]; //4k 
        3'd4: func_get_avail_space[14:0] = 14'h2000 - wptr_sub_rptr[12:0]; //8k 
        default: func_get_avail_space[14:0] = 15'h4000 - wptr_sub_rptr[13:0]; //16k 
      endcase
    end
    else begin 
      unique case (ring_sz[2:0])
        3'd1: func_get_avail_space[14:0] = wptr_ahead ? (11'h400 - wptr[9:0]) : (11'h400 - wptr_sub_rptr[9:0]); 
        3'd2: func_get_avail_space[14:0] = wptr_ahead ? (12'h800 - wptr[10:0]) : (12'h800 - wptr_sub_rptr[10:0]); 
        3'd3: func_get_avail_space[14:0] = wptr_ahead ? (13'h1000 - wptr[11:0]) : (13'h1000 - wptr_sub_rptr[11:0]); 
        3'd4: func_get_avail_space[14:0] = wptr_ahead ? (14'h2000 - wptr[12:0]) : (14'h2000 - wptr_sub_rptr[12:0]); 
        default: func_get_avail_space[14:0] = wptr_ahead ? (15'h4000 - wptr[13:0]) : (15'h4000 - wptr_sub_rptr[13:0]); 
      endcase
    end
end
  
endfunction
//`endif
