module binary_aggregator_2d (clk, rst_n, 
                             candidate_vld, candidate_key, candidate_data, 
                             winner_vld, winner_key, winner_data);

   // - * Parameters
   parameter CANDIDATE_CNT  = 5;
   parameter KEY_WIDTH      = 6;
   parameter DATA_WIDTH     = 16;
   parameter LV_PER_STAGE   = 0; // Number of combination level per FF stages
   parameter FF_START_POINT = 0; // 0: arange FF from top node (output node) 
                                 // 1: arange FF from lowest node 
   
   localparam NODE_CNT  = CANDIDATE_CNT-1;
   localparam LEVEL_CNT = log2(CANDIDATE_CNT);
   localparam BALANCED  = CANDIDATE_CNT == (2**LEVEL_CNT);
   

   // - * Ports
   input     clk, rst_n;
   input [CANDIDATE_CNT-1:0] candidate_vld;
   input [KEY_WIDTH-1:0]  candidate_key [CANDIDATE_CNT-1:0];
   input [DATA_WIDTH-1:0] candidate_data [CANDIDATE_CNT-1:0];

   output                  winner_vld; 
   output [KEY_WIDTH-1:0]  winner_key;
   output [DATA_WIDTH-1:0] winner_data;
   
   reg [KEY_WIDTH-1:0]     key_a [NODE_CNT-1:0]; // node left input
   reg [DATA_WIDTH-1:0]    data_a [NODE_CNT-1:0];
   reg [NODE_CNT-1:0]      vld_a;

   reg [KEY_WIDTH-1:0]     key_b [NODE_CNT-1:0]; // node right input
   reg [DATA_WIDTH-1:0]    data_b [NODE_CNT-1:0];
   reg [NODE_CNT-1:0]      vld_b;

   reg [KEY_WIDTH-1:0]     key_w [NODE_CNT-1:0]; // node winner output
   reg [DATA_WIDTH-1:0]    data_w [NODE_CNT-1:0];
   reg [NODE_CNT-1:0]      vld_w;

   reg [KEY_WIDTH-1:0]     key_w_ff [NODE_CNT-1:0];
   reg [DATA_WIDTH-1:0]    data_w_ff [NODE_CNT-1:0];
   reg [NODE_CNT-1:0]      vld_w_ff;
   
   reg [CANDIDATE_CNT-1:0] candidate_vld_ff;
   reg [KEY_WIDTH-1:0]     candidate_key_ff [CANDIDATE_CNT-1:0];
   reg [DATA_WIDTH-1:0]    candidate_data_ff [CANDIDATE_CNT-1:0];


   genvar                  n, l, c;

   // - * Node instantiation
   generate
      for (n=0; n<NODE_CNT; n=n+1) begin:node_inst
         // Comparator is a pure combinational logic
         `binary_comparator #(.KEY_WIDTH (KEY_WIDTH), .DATA_WIDTH (DATA_WIDTH)) node
           (.key_a (key_a[n]), .data_a (data_a[n]), .vld_a (vld_a[n]),
            .key_b (key_b[n]), .data_b (data_b[n]), .vld_b (vld_b[n]),
            .key_w (key_w[n]), .data_w (data_w[n]), .vld_w (vld_w[n])           
            );

         // - Each candidate input and node output have an FF'ed place-holder signal.
         // - If FF is expected at that level, place-holder signal has FF RTL
         // - attached, otherwise, the signal is directly connected to the
         // - un-FF'ed signal.
         // - So nodes inteconnection is de-coupled with FF insertion. 
         always @(*) begin
            // - ** Node left-hand input 
            if (2*n+1 >= NODE_CNT) begin // input from leaf
               key_a[n]   = candidate_key_ff[(2*n+1)%NODE_CNT];
               data_a[n]  = candidate_data_ff[(2*n+1)%NODE_CNT];
               vld_a[n]   = candidate_vld_ff[(2*n+1)%NODE_CNT];
            end
            else begin         // input from next level winner
               key_a[n]   = key_w_ff[2*n+1];
               data_a[n]  = data_w_ff[2*n+1];
               vld_a[n]   = vld_w_ff[2*n+1];
            end

            // - ** Node right-hand input
            if (2*n+2 >= NODE_CNT) begin // input from leaf
               key_b[n]   = candidate_key_ff[(2*n+2)%NODE_CNT];
               data_b[n]  = candidate_data_ff[(2*n+2)%NODE_CNT];
               vld_b[n]   = candidate_vld_ff[(2*n+2)%NODE_CNT];
            end
            else begin         // input from next level winner
               key_b[n]   = key_w_ff[2*n+2];
               data_b[n]  = data_w_ff[2*n+2];
               vld_b[n]   = vld_w_ff[2*n+2];
            end
         end // always @ assign
         

      end
   endgenerate

   // - * FF Insertion
   generate
      // - ** Insert FF for candidate input
      // - For an unbalanced tree, not all candidates connect to same
      // - level nodes. If lower level node has FF attached, candidates
      // - connecting to higher level node should be flopped to maintain
      // - input data alignment.
      // - Node ID ($n$) and candidate ID ($c$) has following relationship:
      // - \begin{equation}
      // - n = \frac{c_{even} + \text{NODE\_CNT} - 2}{2}
      // - \end{equation}
      // - \begin{equation}
      // - n = \frac{c_{odd} + \text{NODE\_CNT} - 1}{2}
      // - \end{equation}
      for (c=0; c<CANDIDATE_CNT; c=c+1) begin
         // Check Lowest level have FF: (a) Insert FF from leaf, or (b) inert to top
         if ( (LV_PER_STAGE && (FF_START_POINT || (!(LEVEL_CNT-1)%LV_PER_STAGE))) &&
              // odd candidate connect to higher level
              ( (  c%2  && (c+NODE_CNT-1)/2 != (LEVEL_CNT-1)) ||
                // even candidate connect to higher level
                (!(c%2) && (c+NODE_CNT-2)/2 != (LEVEL_CNT-1)))
              ) begin 
            always @(posedge clk or negedge rst_n)
              if (!rst_n) begin
                 candidate_vld_ff[c]  <= 1'b0;
                 candidate_key_ff[c]  <= {KEY_WIDTH{1'b0}};
                 candidate_data_ff[c] <= {DATA_WIDTH{1'b0}};
              end
              else begin
                 candidate_vld_ff[c]  <= candidate_vld[c];
                 candidate_key_ff[c]  <= candidate_key[c];
                 candidate_data_ff[c] <= candidate_data[c];
              end
         end
         else begin
            always @(*) begin
               candidate_vld_ff[c]  = candidate_vld[c];
               candidate_key_ff[c]  = candidate_key[c];
               candidate_data_ff[c] = candidate_data[c];
            end
         end // else: !if( (c+NODE_CNT-1)/2 != (LEVEL_CNT-1) )
      end // for (c=0; c<CANDIDATE_CNT; c=c+1)
         
      // - ** Insert FF at node output
      // - Let $l_{FF}$ be the level with FF inserted, if
      // - insert FF from lowest level, we have
      // - \begin{equation}
      // - l_{FF} = \text{LEVEL\_CNT} - 1 - n\times \text{LV\_PER\_STAGE}, (n=0,1,2,\cdots)
      // - \end{equation}
      // - If insert FF from top level, we have
      // - \begin{equation}
      // - l_{FF} = n\times\text{LV\_PER\_STAGE}, (n=0,1,2,\cdots)
      // - \end{equation}
      for (l=LEVEL_CNT-1; l>=0; l=l-1) begin
         if ( LV_PER_STAGE && 
                 // insert FF from lowest level, l doesn't need FF
              ( (FF_START_POINT && (LEVEL_CNT-1-l)%LV_PER_STAGE) ||
                 // insert FF from top level, l doesn't need FF
                (!FF_START_POINT && l%LV_PER_STAGE)
                ) 
              )begin
            always @(*) begin
               vld_w_ff[n]  = vld_w[n];
               key_w_ff[n]  = key_w[n];
               data_w_ff[n] = data_w[n];
            end
         end
         else begin
            // - For all nodes at $l_{FF}$ that needs FF, interation at level plane.
            // - For level $l$, first node ID
            // - at this level is $2^l-1$, total number of nodes at this
            // - level is $2^l$, so last node ID at this level is
            // - \begin{equation}
            // - N_{start} + count - 1 = (2^l-1)+ 2^l - 1 = 2^{l+1} - 2
            // - \end{equation}
            for (n=2**l-1; n<=2**(l+1)-2; n=n+1) begin
               // node ID is bounded at NODE_CNT. 
               // This check can also be put into 'for' statement (n<=2**(l+1)-2 && n<NODE_CNT),
               // but VCS will issue warning about genvar is used at both sides
               // of condition expression. WTF.
               if (n < NODE_CNT)  begin
                  always @(posedge clk or negedge rst_n)
                    if (!rst_n) begin
                       vld_w_ff[n]  <= 1'b0;
                       key_w_ff[n]  <= {KEY_WIDTH{1'b0}};
                       data_w_ff[n] <= {DATA_WIDTH{1'b0}};
                    end
                    else begin
                       vld_w_ff[n]  <= vld_w[n];
                       key_w_ff[n]  <= key_w[n];
                       data_w_ff[n] <= data_w[n];
                    end
               end // if (n < NODE_CNT)
            end // for (n=2**l-1; n<2**(l+1)-1; n=n+1)
         end // else: !if( LV_PER_STAGE &&...
      end // for (l=LEVEL_CNT-1; l>=0; l=l-1)
      
   endgenerate

   // - * Module output
   assign winner_vld  = vld_w_ff[0];
   assign winner_key  = key_w_ff[0];
   assign winner_data = data_w_ff[0];

endmodule // binary_aggregator_2d

  
