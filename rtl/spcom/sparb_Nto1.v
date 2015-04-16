module sparb_Nto1 (req, grant);
parameter REQ_NUM = 8;

input  [REQ_NUM-1:0] req;
output [REQ_NUM-1:0] grant;

generate 
genvar i;

for (i=0; i<REQ_NUM; i++) 
begin : grant_gen
  assign grant[i] = req[i] & ((|req[REQ_NUM-1:i]) == 1'b0);
end

endgenerate

endmodule
