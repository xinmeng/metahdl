// - Completion Timeout module uses a free running counter 
// - to maintain time, and uses bit toggle as timeout
// - event. For example, when configure=0010b, timeout value
// - range is (see \cite{xilinx-pcie3} p.47)
// - \begin{equation}\label{eq:specrange}
// -  [1\times 10^6, 10 \times 10^6] \simeq
// -  [0.954 \times 2^{20}, 1.193 \times 2^{23}]
// - \end{equation}
// - For a counter ([63:0] in width)
// - that is incremented every 1ns, toggle on bit [22] means $[1, 2^{22}]$
// - increments. Similarly, two consecutive toggles on bit [22] means 
// - \begin{equation}\label{eq:rtlrange}
// - [1+2^{22}, 2^{22} \times 2]
// - \end{equation}
// - increments. range in \autoref{eq:rtlrange} 
// - is a sub-range of \autoref{eq:specrange} that is timeout value range
// - defined in spec . 
// - For simplifying RTL implementation, each outstanding request just need to 
// - monitor two consecutive toggles on a single bit for timeout detection. 
// - According to Xilinx core timeout value output
// - (\cite{xilinx-pcie3} p.47), \autoref{tab:cto}
// - summarize timeout value and corresponding bit index selection. 
// - \begin{table}[hbtp]
// -   \centering
// -   \caption{Completion Timeout value and bit index}\label{tab:cto}
// -   {\footnotesize
// -     \begin{tabular}{cllclc}
// -       \tableheader{Configure} & \tableheader{Spec range (ns)} & \tableheader{Approximate Spec Range (ns)} & \tableheader{Bit (1ns)} & \tableheader{RTL Range (ns)} & \tableheader{Bit (8ns)}\\
// -       0001b & $[50 \times 10^3, 100 \times 10^3]  $ & $ [1.53 \times 2^{15}, 1.53 \times 2^{16}]$    & 16 & $[1+2^{16}, 2^{16} \times 2]$   & 13 \\
// -       0010b & $[1 \times 10^6, 10 \times 10^6]    $ & $ [0.954 \times 2^{20}, 1.193 \times 2^{23}]$  & 22 & $[1+2^{22}, 2^{22} \times 2]$   & 19 \\
// -       0101b & $[16 \times 10^6, 55 \times 10^6]   $ & $ [0.954 \times 2^{24}, 1.64 \times 2^{25}]$   & 24 & $[1+2^{24}, 2^{24} \times 2]$   & 21 \\
// -       0110b & $[65 \times 10^6, 210 \times 10^6]  $ & $ [0.969 \times 2^{26}, 1.565 \times 2^{27}]$  & 26 & $[1+2^{26}, 2^{26} \times 2]$   & 23 \\
// -       1001b & $[260 \times 10^6, 900 \times 10^6] $ & $ [0.969 \times 2^{28}, 1.677 \times 2^{29}]$  & 28 & $[1+2^{28}, 2^{28} \times 2]$   & 25 \\
// -       1010b & $[1 \times 10^9, 3.5 \times 10^9]   $ & $ [0.93 \times 2^{30}, 1.63 \times 2^{31}]$    & 30 & $[1+2^{30}, 2^{30} \times 2]$   & 27 \\
// -       1101b & $[4 \times 10^9, 13 \times 10^9]    $ & $ [0.93 \times 2^{32}, 1.51 \times 2^{33}]$    & 32 & $[1+2^{32}, 2^{32} \times 2]$   & 29 \\
// -       1110b & $[17 \times 10^9, 64 \times 10^9]   $ & $ [0.988 \times 2^{34}, 0.93 \times 2^{36}]$   & 34 & $[1+2^{34}, 2^{34} \times 2]$   & 31 \\
// -       0000b & $[50 \times 10^3, 50 \times 10^6]   $ & $ [1.53 \times 2^{15}, 1.49 \times 2^{25}]$    & 24 & $[1+2^{24}, 2^{24} \times 2]$   & 21 \\
// -     \end{tabular}
// -   }
// - \end{table}
// - 
// - Note for configure=0001b, spec range is small, 
// - which makes the approximate RTL range is larger than spec range. 
// - It should be OK in real implementation because requester will wait longer
// - before report timeout, which gives extra time to completer. 
// - 
// - In FPGA implementation, clock frequency is 125MHz (8ns cycle), 
// - which means one increment of counter is $2^3$ ns. So bit index
// - for toggle event in RTL should be minused with 3. 

module cpl_timeout (clk, rst_n, 
                    add_entry, add_entry_tag, 
                    bit_select, 
                    query_tag, entry_timeout);

   parameter ENTRY_COUNT   = 64;
   parameter COUNTER_WIDTH = 32;
   parameter MIN_INDEX     = 13;

   parameter TAG_WIDTH = log2(ENTRY_COUNT);

   input     clk, rst_n;
   input [TAG_WIDTH-1:0] add_entry_tag;
   input                 add_entry;

   // One hot selection signal used to pick up toggle bit.
   // External logic is responsible to provide the selection
   // signal according to application speicific configurations. 
   input [COUNTER_WIDTH-1:0] bit_select;

   input [TAG_WIDTH-1:0] query_tag;
   output                entry_timeout;



   genvar                  i;

   // -* Free Running Counter
   // -
   reg [COUNTER_WIDTH-1:0] cnt
   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       cnt <= {COUNTER_WIDTH{1'b0}};
     else
       cnt <= cnt + 1'b1;


   // - * Toggle to pulse
   // - Instantiate \mhdl{toggle_to_pulse}  from \mhdl{MIN_INDEX}
   // - of counter bit. Because toggle of lower bits are never
   // - used.
   // - \lstset{emph={toggle_pulse}}
   wire [COUNTER_WIDTH-1:0] toggle_pulse;
   generate
      for (i=0; i<MIN_INDEX; i=i+1) begin: lower_cnt_bits
         assign toggle_pulse[i] = 1'b0;
      end
   endgenerate
   
   generate
      for (i=MIN_INDEX; i<COUNTER_WIDTH; i=i+2) begin:toggle_to_pulse_inst
         // instantiate every two bits
         toggle_to_pulse x_toggle_to_pulse
           (.clk (clk), .rst_n (rst_n), 
            .din (cnt[i]), .pout (toggle_pulse[i]));
      end
   endgenerate
   // - \lstset{emph={}}


   // - * Select bit
   assign toggle = |(toggle_pulse & bit_select);

   // - * Entries
   // - Each entry counts toggle event,
   // - when two consecutive events occur, entry value is
   // - locked. 
   reg [1:0] entry [TAG_COUNT-1:0];
   always @(posedge clk or negedge rst_n) begin
      integer i;
      for (i=0; i<TAG_COUNT; i=i+1)
        if (!rst_n)
          entry[i] <= 2'd0;
        else if (add_entry && add_entry_tag == i)
          entry[i] <= 2'd0;
        else if (toggle)
          entry[i] <= entry[i] == 2'b10 ? entry[i] : entry[i] + 1'b1;
        else
          entry[i] <= entry[i];
   end // always @ (posedge clk or negedge rst_n)


   // -* Query
   assign entry_timeout = entry[query_tag] == 2'b10; 


endmodule
