module top ();


reg             clk;
reg             ext_clear_type_ctrl;
reg             ext_write_en;
reg   [3   :0]  field_value;
reg             hw_pulse;
reg   [3   :0]  hw_value;
reg             rst_n;
reg   [2   :0]  sw_rd;
reg   [2   :0]  sw_wr;
reg   [11  :0]  sw_wr_data;
reg             sync_rst;


field x_field (
                  .clk (clk),
                  .ext_clear_type_ctrl (ext_clear_type_ctrl),
                  .ext_write_en (ext_write_en),
                  .field_value (field_value),
                  .hw_pulse (hw_pulse),
                  .hw_value (hw_value),
                  .rst_n (rst_n),
                  .sw_rd (sw_rd),
                  .sw_wr (sw_wr),
                  .sw_wr_data (sw_wr_data),
                  .sync_rst (sync_rst)
              );


   initial begin
      clk = 1;
      forever clk = #5 ~clk;
   end
   
   initial begin
      hw_pulse=1'b0;
      sw_rd = 3'd0;
      sw_wr = 3'd0;
      sw_wr_data = {3'd3, 3'd3, 3'd3};
      sync_rst = 0;
      hw_value = 3'd3;
      
      rst_n = 1'b0;
      #30;
      rst_n = 1'b1;
      #20;
      hw_pulse = 1'b1;
      #12;
      hw_pulse = 1'b0;
      #100;
      $stop;
   end
      

   always @(posedge clk)
     $display("%d", field_value);


   initial begin
      $fsdbDumpfile("field.fsdb");
      $fsdbDumpMDA();
      $fsdbDumpvars();
   end



endmodule
