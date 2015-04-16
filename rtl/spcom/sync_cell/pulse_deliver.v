module pulse_deliver (
  clk_a, 
  clk_b, 
  pulse_in, 
  pulse_out, 
  rst_a_n, 
  rst_b_n);


input             clk_a;
input             clk_b;
input             pulse_in;
output            pulse_out;
input             rst_a_n;
input             rst_b_n;

parameter RX_IDLE = 2'b01;
parameter RX_WAIT_A_LOW = 2'b10;
parameter TX_IDLE = 3'b001;
parameter TX_WAIT_B_HIGH = 3'b010;
parameter TX_WAIT_B_LOW = 3'b100;
parameter _RX_IDLE_ = 0;
parameter _RX_WAIT_A_LOW_ = 1;
parameter _TX_IDLE_ = 0;
parameter _TX_WAIT_B_HIGH_ = 1;
parameter _TX_WAIT_B_LOW_ = 2;
reg               a_to_b;
wire              a_to_b_ff;
wire              a_to_b_ff2;
reg              a_to_b_ff3;
reg               b_to_a;
wire              b_to_a_ff;
wire              b_to_a_ff2;
wire              clk_a;
wire              clk_b;
wire              pulse_in;
reg               pulse_out;
wire              rst_a_n;
wire              rst_b_n;
reg     [1   :0]  rx_cs;
reg     [1   :0]  rx_ns;
reg     [2   :0]  tx_cs;
reg     [2   :0]  tx_ns;

cdc_synczr b2a
  (.clk (clk_a), 
   .sync_in (b_to_a), 
   .sync_out (b_to_a_ff2)
   );
   
// SDFFYQ_X2M_A12TH50 pulse_deliver_metastable_b2a_0 (
//                                                       .CK (clk_a),
//                                                       .D (b_to_a),
//                                                       .Q (b_to_a_ff),
//                                                       .SE (1'b0),
//                                                       .SI (1'b0)
//                                                   );

// SDFFYQ_X2M_A12TH50 pulse_deliver_metastable_b2a_1 (
//                                                       .CK (clk_a),
//                                                       .D (b_to_a_ff),
//                                                       .Q (b_to_a_ff2),
//                                                       .SE (1'b0),
//                                                       .SI (1'b0)
//                                                   );

// Sequential part of FSM "tx" 
always @(posedge clk_a or negedge rst_a_n)
  if (~rst_a_n) begin
    tx_cs <= TX_IDLE;
  end
  else begin
    tx_cs <= tx_ns;
  end

// Combinational part of FSM "tx" 
always @(*) 
  begin
    begin
      a_to_b = 1'b0;
    end
`ifdef USE_UNIQUE
    unique case (1'b1 ) 
`else
    case (1'b1 ) // sysnthesis parallel_case
`endif
      tx_cs[_TX_IDLE_] : 
        if ( pulse_in )
          begin
            a_to_b = 1'b1;
            tx_ns = TX_WAIT_B_HIGH;
          end
        else
          begin
            tx_ns = TX_IDLE;
          end

      tx_cs[_TX_WAIT_B_HIGH_] : 
        if ( b_to_a_ff2 )
          begin
            a_to_b = 1'b0;
            tx_ns = TX_WAIT_B_LOW;
          end
        else
          begin
            a_to_b = 1'b1;
            tx_ns = TX_WAIT_B_HIGH;
          end

      tx_cs[_TX_WAIT_B_LOW_] : 
        if ( !b_to_a_ff2 )
          begin
            tx_ns = TX_IDLE;
          end
        else
          begin
            tx_ns = TX_WAIT_B_LOW;
          end

      default: begin
        tx_ns = TX_IDLE;
      end
    endcase

  end


cdc_synczr a2b
  (.clk (clk_b),
   .sync_in (a_to_b),
   .sync_out (a_to_b_ff2)
   );
// SDFFYQ_X2M_A12TH50 pulse_deliver_metastable_a2b_0 (
//                                                       .CK (clk_b),
//                                                       .D (a_to_b),
//                                                       .Q (a_to_b_ff),
//                                                       .SE (1'b0),
//                                                       .SI (1'b0)
//                                                   );

// SDFFYQ_X2M_A12TH50 pulse_deliver_metastable_a2b_1 (
//                                                       .CK (clk_b),
//                                                       .D (a_to_b_ff),
//                                                       .Q (a_to_b_ff2),
//                                                       .SE (1'b0),
//                                                       .SI (1'b0)
//                                                   );

// SDFFYQ_X2M_A12TH50 pulse_deliver_metastable_a2b_2 (
//                                                       .CK (clk_b),
//                                                       .D (a_to_b_ff2),
//                                                       .Q (a_to_b_ff3),
//                                                       .SE (1'b0),
//                                                       .SI (1'b0)
//                                                   );
always @(posedge clk_b or negedge rst_b_n)
	if (!rst_b_n)
		a_to_b_ff3 <= 1'b0;
	else 
		a_to_b_ff3 <= a_to_b_ff2;
	
// Sequential part of FSM "rx" 
always @(posedge clk_b or negedge rst_b_n)
  if (~rst_b_n) begin
    rx_cs <= RX_IDLE;
  end
  else begin
    rx_cs <= rx_ns;
  end

// Combinational part of FSM "rx" 
always @(*) 
  begin
    begin
      b_to_a = 1'b0;
    end
`ifdef USE_UNIQUE
    unique case (1'b1 ) 
`else
    case (1'b1 ) // sysnthesis parallel_case
`endif
      rx_cs[_RX_IDLE_] : 
        if ( a_to_b_ff2 )
          begin
            b_to_a = 1'b1;
            rx_ns = RX_WAIT_A_LOW;
          end
        else
          begin
            rx_ns = RX_IDLE;
          end

      rx_cs[_RX_WAIT_A_LOW_] : 
        if ( !a_to_b_ff2 )
          begin
            b_to_a = 1'b0;
            rx_ns = RX_IDLE;
          end
        else
          begin
            b_to_a = 1'b1;
            rx_ns = RX_WAIT_A_LOW;
          end

      default: begin
        rx_ns = RX_IDLE;
      end
    endcase

  end


always @(posedge clk_b or negedge rst_b_n)
  if (~rst_b_n) begin
    pulse_out <= 1'b0;
  end
  else begin
    pulse_out <= (a_to_b_ff2 ^ a_to_b_ff3) & ~a_to_b_ff3;
  end

endmodule
