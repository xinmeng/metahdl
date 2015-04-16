module cdc_synczr (
  clk,
  sync_in,
  sync_out
);

input   clk;
input   sync_in;
output  sync_out;

reg     sync_in_ff;
reg     sync_out;

`ifdef CDC_SIM_DLY

localparam SYNC_DLY_DEPTH = 4;

reg     sync_in_dly [SYNC_DLY_DEPTH];
genvar  i;
int unsigned  dly_idx;

// insert random routing delay
initial begin
  //  dly_idx = uve_urandom()%(SYNC_DLY_DEPTH-1);
  dly_idx = $urandom()%(SYNC_DLY_DEPTH-1);
  //$display("%m dly_idx = %0d", dly_idx);
end

always @(posedge clk) begin
  sync_in_dly[0] <= sync_in;
end

generate
  for (i=0; i<SYNC_DLY_DEPTH-1; i++) begin: sync_in_dly_block
    always @(posedge clk) begin
      sync_in_dly[i+1] <= sync_in_dly[i];
    end
  end
endgenerate

// insert random metastability delay during CDC
always @(posedge clk) begin
  if($test$plusargs("cdc_sim_dly_en")) begin
    //$display("%m dly_idx = %0d, %t", dly_idx, $realtime);
    if(uve_urandom()%2) begin
      sync_out <= sync_in_dly[dly_idx];
    end else begin
      sync_out <= sync_in_dly[dly_idx+1];
    end
  end else begin
    sync_out <= sync_in_dly[0];
  end
end

`else // Common FF for RTL

always @(posedge clk) begin
  sync_in_ff <= sync_in;
  sync_out   <= sync_in_ff;
end

`endif // `ifdef CDC_SIM_DLY
  
endmodule
