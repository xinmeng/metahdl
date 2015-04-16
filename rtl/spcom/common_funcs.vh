// It will be included everywhere to work around vivado
// global funciton recognition limitation.
// 
// `ifndef __common_funcs_vh__
// `define __common_funcs_vh__

function integer log2;
  input [31:0] value;
  log2 = 1;
  while(value > (2**log2))
    log2 = log2+1;
endfunction

// `endif //  `ifndef __common_funcs_vh__
