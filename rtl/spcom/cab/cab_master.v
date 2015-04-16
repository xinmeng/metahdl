module cab_master(
  //System interface
  input   wire        clk              //Clock for CAB Master
  ,input  wire        rst_n            //Reset for CAB Master, low active   

  //CAB Master Out Interface 
  ,output wire        xxo_cab_mreq     //Output CAB Master request.
  ,output wire [15:0] xxo_cab_mwdata   //Output CAB Master Write data.
  ,input  wire        cab_xxo_mreq_rdy //Output CAB Master request ready.
  ,input  wire        cab_xxo_mdn      //Input CAB data is valid.
  ,input  wire [15:0] cab_xxo_mrdata   //Input CAB read data.

  //CAB Master In Interface
  ,input  wire        xxi_cab_mreq     //Input CAB Master request.
  ,input  wire        xxi_cab_mlan     //Input CAB Master LAN port (1: lan1, 0: lan0).
  ,input  wire [15:0] xxi_cab_maddr    //Input CAB Master byte address (4-bytes align).
  ,input  wire [31:0] xxi_cab_mwdata   //Input CAB Master Write data.
  ,input  wire        xxi_cab_mwr      //Input CAB Master Write (1: write, 0: read).
  ,output wire        cab_xxi_mreq_rdy //Input CAB Master request ready.
  ,output wire        cab_xxi_mdn      //Output CAB data is valid.
  ,output wire [31:0] cab_xxi_mrdata   //Output CAB read data.
);


//
// Local parameters
//
//State Machine parameters
localparam M_IDLE  = 6'h1 , MB_IDLE  = 0; //Idle state
localparam M_ADDR  = 6'h2 , MB_ADDR  = 1; //Send address/LAN/RW state 
localparam M_WDAT0 = 6'h4 , MB_WDAT0 = 2; //Write data 0 state 
localparam M_WDAT1 = 6'h8 , MB_WDAT1 = 3; //Write data 1 state 
localparam M_RDAT0 = 6'h10, MB_RDAT0 = 4; //Read data 0 state 
localparam M_RDAT1 = 6'h20, MB_RDAT1 = 5; //Read data 1 state 


//
// Reg and wires
//
(* fsm_encoding = "one-hot" *)
reg [5 :0] mcs         , mns;
reg [13:0] cab_maddr   , cab_maddr_nxt;
reg [31:0] cab_mwdata  , cab_mwdata_nxt;
reg        cab_mlan    , cab_mlan_nxt;
reg        cab_mwr     , cab_mwr_nxt;
reg        cab_mreq_rdy, cab_mreq_rdy_nxt;
reg        cab_mdn     , cab_mdn_nxt;
reg [31:0] cab_mrdata  , cab_mrdata_nxt;


////////////////////////////////////////////////////////////////////////////////////////
// CAB Master Transaction Handling
// Translate the input 32bits register access interface to 16bits CAB transaction based
// register access interface. 
// For Master In: 
// - Deassert the request ready till the transaction is done.
// For Master Out Write: 
// - 1st address phase, 2nd data0 phase, final data1 phase, qulify with request
// - Need to check the request ready for each phase
// For Master Out Read: 
// - 1st address phase, qulify with request
// - 2nd wait the read data0/data1 phases, check with the read done
////////////////////////////////////////////////////////////////////////////////////////
//
// Output port assignment
//
//To CAB Master Out Interface 
assign xxo_cab_mreq         = mcs[MB_ADDR] | mcs[MB_WDAT0] | mcs[MB_WDAT1];
assign xxo_cab_mwdata[15:0] = mcs[MB_ADDR]  ? {cab_maddr[13:0], cab_mlan, cab_mwr} :
                              mcs[MB_WDAT0] ? cab_mwdata[15:0] :
                              mcs[MB_WDAT1] ? cab_mwdata[31:16] : 16'h0;

//To CAB Master In Interface
assign cab_xxi_mreq_rdy     = cab_mreq_rdy;
assign cab_xxi_mdn          = cab_mdn;
assign cab_xxi_mrdata[31:0] = cab_mrdata[31:0];


//
// Sequential logic
//
always @(posedge clk, negedge rst_n) begin : SEQ
  if (!rst_n) begin
    mcs[5:0]          <= M_IDLE;
    cab_maddr[13:0]   <= 14'h0;
    cab_mwdata[31:0]  <= 32'h0;
    cab_mlan          <= 1'b0;
    cab_mwr           <= 1'b0;
    cab_mreq_rdy      <= 1'b1;
    cab_mdn           <= 1'b0;
    cab_mrdata[31:0]  <= 32'h0;
  end else begin
    mcs[5:0]          <= mns[5:0];
    cab_maddr[13:0]   <= cab_maddr_nxt[13:0];
    cab_mwdata[31:0]  <= cab_mwdata_nxt[31:0];
    cab_mlan          <= cab_mlan_nxt;
    cab_mwr           <= cab_mwr_nxt;
    cab_mreq_rdy      <= cab_mreq_rdy_nxt;
    cab_mdn           <= cab_mdn_nxt;
    cab_mrdata[31:0]  <= cab_mrdata_nxt[31:0];
  end
end


//
// Comb logic
// 
// CAB Master State Machine
always @* begin : MSM_NXT
  mns[5:0] = mcs[5:0];
  `ifndef VERILOG_ENABLE
  unique case (mcs[5:0]) 
  `else
  case (mcs[5:0]) 
  `endif //`ifndef VERILOG_ENABLE
    M_IDLE: begin //Idle state
      if(xxi_cab_mreq) begin
        mns[5:0] = M_ADDR;
      end
    end
    M_ADDR: begin //Send address/LAN/RW state 
      if(cab_xxo_mreq_rdy) begin
        if(cab_mwr) begin
          mns[5:0] = M_WDAT0;
        end
        else begin
          mns[5:0] = M_RDAT0;
        end
      end
    end
    M_WDAT0: begin //Write data 0 state
      if(cab_xxo_mreq_rdy) begin
        mns[5:0] = M_WDAT1;
      end
    end
    M_WDAT1: begin //Write data 1 state
      if(cab_xxo_mreq_rdy) begin
        mns[5:0] = M_IDLE;
      end
    end
    M_RDAT0: begin //Read data 0 state
      if(cab_xxo_mdn) begin
        mns[5:0] = M_RDAT1;
      end
    end
    M_RDAT1: begin //Read data 1 state
      if(cab_xxo_mdn) begin
        mns[5:0] = M_IDLE;
      end
    end
    default: begin
      mns[5:0] = M_IDLE;
    end
  endcase
end

// CAB Master Out 4-bytes address 
always @* begin
  cab_maddr_nxt[13:0] = cab_maddr[13:0];
  if(mcs[MB_IDLE] && xxi_cab_mreq) begin
    cab_maddr_nxt[13:0] = xxi_cab_maddr[15:2];
  end
end

// CAB Master Out write data
always @* begin
  cab_mwdata_nxt[31:0] = cab_mwdata[31:0];
  if(mcs[MB_IDLE] && xxi_cab_mreq && xxi_cab_mwr) begin
    cab_mwdata_nxt[31:0] = xxi_cab_mwdata[31:0];
  end
end

// CAB Master Out LAN port select
always @* begin
  cab_mlan_nxt = cab_mlan;
  if(mcs[MB_IDLE] && xxi_cab_mreq) begin
    cab_mlan_nxt = xxi_cab_mlan;
  end
end

// CAB Master Out write/read flag
always @* begin
  cab_mwr_nxt = cab_mwr;
  if(mcs[MB_IDLE] && xxi_cab_mreq) begin
    cab_mwr_nxt = xxi_cab_mwr;
  end
end

//
// CAB Master In request ready
always @* begin
  cab_mreq_rdy_nxt = cab_mreq_rdy;
  if(mcs[MB_IDLE] && xxi_cab_mreq) begin
    cab_mreq_rdy_nxt = 1'b0;
  end
  else if((mcs[MB_WDAT1] && cab_xxo_mreq_rdy) ||
          (mcs[MB_RDAT1] && cab_xxo_mdn)) begin
    cab_mreq_rdy_nxt = 1'b1;
  end
end

// CAB Master In read data done flag
always @* begin
  cab_mdn_nxt = cab_mdn;
  if(mcs[MB_RDAT1]) begin
    cab_mdn_nxt = cab_xxo_mdn;
  end
  else begin
    cab_mdn_nxt = 1'b0;
  end
end

// CAB Master In read data
always @* begin
  cab_mrdata_nxt[31:0] = cab_mrdata[31:0];
  if(mcs[MB_RDAT0] && cab_xxo_mdn) begin
    cab_mrdata_nxt[15:0] = cab_xxo_mrdata[15:0];
  end
  else if(mcs[MB_RDAT1] && cab_xxo_mdn) begin
    cab_mrdata_nxt[31:16] = cab_xxo_mrdata[15:0];
  end
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
