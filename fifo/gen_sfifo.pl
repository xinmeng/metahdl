#! /usr/local/bin/perl

use Getopt::Long;
use strict;

=pod

=head1 NAME

Generate synchronous FIFO implemented using register file.

=head1 SYNOPSIS

gen_sfifo.pl B<--length|-l> I<length of FIFO> 
    B<--width|-w> I<width of FIFO>
    [B<--register|-r>]
    [B<--almost_full|-f> I<Almost full threshold>]
    [B<--almost_empty|-e> I<almost empty threshold>]
    [B<--sverilog|-s>]
    [B<--checker|-c>]
    [B<--macro|-m> I<Macro Name that enables checker>]
    B<[--help|-h]>

=head1 DESCRIPTION

Generate Synchronous I<show ahead> FIFO sfifo_I<LENGTH>xI<WIDTH>.v 
specified by --length and --width. Length must be power of 2, 
otherwise, error is reported and script exits.  Since it is a show
ahead FIFO, I<empty> flag can be used as I<valid> signal.  That is
when it is deasserted, data on I<'dout'> is valid.

User can specify I<almost full> or I<almost empty> threshold, which
will result in generation of B<almost_full> or B<almost_empty> output
port.

User can specify the source code use Veriog I<case> with I<parallel_case> 
directive, or use SystemVerilog I<unique case> by B<--sverilog> option. 

FIFO supports a internal overflow/underflow checker. The checker is
not implmented in source code in default mode. User should use
B<--checker> option to command script to generate it. Once it is
implemented, it is in B<SFIFO_INTERNAL_CHECKER> ifdef block. User can 
change the macro by B<--macro> option. When B<--sverilog> option is 
presented, internal checker is implemented in SystemVerilog Assertion. 


=head1 OPTIONS

I<gen_sfifo.pl> uses following options:

=head2 B<-l, --length>

Sepcify length of FIFO, must be power of 2, otherwise, error is reported
and script exits.


=head2 B<-w, --width>

Specify width of FIFO.


=head2 B<-r, --register>

Flop out I<dout> if this option is presented, otherwise, I<dout> is a 
Combinational output. 

=head2 B<-f, --almost_full>

Specify almost full threshold. If free entries in FIFO is less than or equal to 
this value, I<almost_full> output is asserted.


=head2 B<-e, --almost_empty>

Specify almost empty threshold. If valid entries in FIFO is less than or equal to 
this value, I<almost_empty> output is asserted.


=head2 B<-c, --checker>

If presented, an internal overflow/underflow checker will be included in
the generated source code.


=head2 B<-m, --macro>

Specify the macro name used for switch off internal checker through ifdef 
pre-compile directive. It applies on the internal checker, so must be used
with B<--checker> option. 


=head2 B<-s, --sverilog> 

If presented, the generated source code is in SystemVerilog dialect, otherwise, 
in traditional Verilog dialect. Currently, SystemVerilog dialect includes I<unique case>
and Assertions based internal checker. Further version might implement more 
SystemVerilog features, such as Interface. 


=head2 B<-h, --help>

Show this help information.

=head1 Author

Written by Xin Meng (xin_meng@hifn.com).


=cut


my $l;				# length, 2^n
my $w;				# width
my $fth;			# almost full threshold
my $eth;			# almost empty threshold
my $sv;	
my $macro = "SFIFO_INTERNAL_CHECKER"; # macro name to enable reporting
my $reg; 			# Register output on dout
my $chk;			# Enable reporting
my $help;

GetOptions( "length|l=i"       => \$l,
	    "width|w=i"        => \$w,
	    "almost_full|f=i"  => \$fth,
	    "almost_empty|e=i" => \$eth,
	    "sverilog|s!"      => \$sv,
	    "macro|m=s"        => \$macro,
	    "register|r!"      => \$reg,
	    "checker|c!"       => \$chk,
	    "help|h!"          => \$help);

if ( $help ) {
    my $perldoc = `which perldoc`;
    chomp $perldoc;
    system "$perldoc \"$0\"";
    exit 0;
}

if ( log($l)/log(2) - int(log($l)/log(2)) ) {
    die "Error: Length must be 2's power.";
}

# ------------------------------
#   case and DC directive
# ------------------------------
my ($case, $directive);
if ( $sv ) {
    $case = "unique case";
    $directive = "";
}
else {
    $case = "case";
    $directive = "// synthesis parallel_case";
}

# ------------------------------
#   contant calculation
# ------------------------------
my $lmsb = $l - 1; # length MSB
my $wmsb = $w - 1; # Width MSB

my $pwidth = log($l)/log(2);
my $pmsb   = $pwidth - 1; # Pointer MSB

my $fth_s = $fth - 1;
my $fth_p = $fth + 1;
my $eth_s = $eth - 1;
my $eth_p = $eth + 1; 

open FH, "> sfifo_${l}x${w}.v" or die "Can not open file for write: $!";

# ------------------------------
#   File Header
# ------------------------------
print FH << "EOF";
// +----------------------------------------------------------------------
// | Copyright (2007), Hifn (Hangzhou)                                    
// |                                                                      
// | ALL THE CONTENTS CONTAINED HEREIN ARE CONFIDENTIAL AND PROPRIETARY   
// | AND ARE NOT TO BE DISCLOSED OUTSIDE OF HIFN (HANG ZHOU) EXCEPT UNDER
// | A NON-DISCLOSURE AGREEMENT (NDA).                       
// |                                                                      
// |                                                                      
// | Synchronous FIFO generated by gen_sfifo.pl
// |   - Length: $l
// |   - Width : $w
EOF
    ;

print FH "// |   - Almost Full Threshold : $fth\n" if $fth;
print FH "// |   - Almost Empty Threshold: $eth\n" if $eth;
print FH "// |   - Flop Out \'dout\'\n" if $reg;

if ( $sv ) {
    print FH "// |   - SystemVerilog Dialect\n";
}
else {
    print FH "// |   - Verilog Dialect\n";
}
if ( $chk ) {
    print FH "// |   - Internal Checker Implemented,\n";
    print FH "// |     in macro \'$macro\'\n";
}
    
print FH << 'EOF'
// |                                                                      
// +----------------------------------------------------------------------
EOF
    ;

# ------------------------------
#   Module definition
# ------------------------------
print FH << "EOF";
module sfifo_${l}x${w}
EOF
    ;
print FH << 'EOF'
  (// input
   din,
   rd_en,
   wr_en,
   clk,
   rst_n,

   // output
   empty,
   full,
EOF
   ;

if ( $fth ) {
    print FH << 'EOF';
   almost_full,
EOF
}
if ( $eth ) {
    print FH << 'EOF';
   almost_empty,
EOF
}

print FH << 'EOF';
   dout
   );
EOF
    ;


# ------------------------------
#   IO declaration
# ------------------------------
print FH << "EOF"

   input  [$wmsb:0] din;
   input 	rd_en;
   input 	wr_en;
   input 	clk;
   input 	rst_n;

   output [$wmsb:0] dout;
   output 	   empty;
   output 	   full;
EOF
    ;

if ( $fth ) {
    print FH << 'EOF'
   output almost_full;
EOF
}
if ( $eth ) { 
    print FH << 'EOF'
   output almost_empty;
EOF
}

print FH << 'EOF'


EOF
    ;

# ------------------------------
#   variable declaration
# ------------------------------
print FH << "EOF"
   reg empty;
   reg full;

   reg [$pmsb:0] wr_ptr;
   reg [$pmsb:0] rd_ptr;

   reg [$wmsb:0] data [$lmsb:0];


EOF
    ;

if ( $reg ) {
    print FH << "EOF"
   reg [$wmsb:0] dout;
   reg [$pmsb:0] next_rd_ptr;
   reg [$wmsb:0] rd_data;

   wire rd_din;
   wire rd_next;
   wire [$wmsb:0] data_cur;
   wire [$wmsb:0] data_nxt;

EOF
}
else {
    print FH << "EOF"
   wire [$wmsb:0] dout;

EOF
}


if ( $fth ) {
    print FH << 'EOF'
   reg almost_full;
EOF
}
if ( $eth ) {
    print FH << 'EOF'
   reg almost_empty;
EOF
}

print FH << 'EOF'

EOF
    ;


# ------------------------------
#   Write port
# ------------------------------
print FH << "EOF"
   // write port
   always @(posedge clk or negedge rst_n)
     if ( ~rst_n )
       wr_ptr[$pmsb:0] <= $pwidth\'d0;
     else
       wr_ptr[$pmsb:0] <= wr_en ? wr_ptr[$pmsb:0] + $pwidth\'b1 : wr_ptr[$pmsb:0];

   always @(posedge clk)
     data[wr_ptr[$pmsb:0]] <= wr_en ? din[$wmsb:0] : data[wr_ptr[$pmsb:0]];


EOF
    ;



# ------------------------------
#   Read Port
# ------------------------------
print FH << "EOF"
   // read port
   always @(posedge clk or negedge rst_n)
     if ( ~rst_n ) 
       rd_ptr[$pmsb:0] <= $pwidth\'d0;
     else
       rd_ptr[$pmsb:0] <= rd_en ? rd_ptr[$pmsb:0] + $pwidth\'b1 : rd_ptr[$pmsb:0];

EOF
    ;

if ( $reg ) {
    print FH << "EOF"
   always @( posedge clk or negedge rst_n)
     if ( ~rst_n ) 
       next_rd_ptr[$pmsb:0] <= $pwidth\'d1;
     else 
       next_rd_ptr[$pmsb:0] <= rd_en ? next_rd_ptr[$pmsb:0] + $pwidth\'b1 : next_rd_ptr[$pmsb:0];

   assign rd_din  = empty || ( rd_en && (next_rd_ptr[$pmsb:0] == wr_ptr[$pmsb:0]));
   assign rd_next = rd_en && (next_rd_ptr[$pmsb:0] != wr_ptr[$pmsb:0]);

   assign data_cur[$wmsb:0] = data[rd_ptr[$pmsb:0]];
   assign data_nxt[$wmsb:0] = data[next_rd_ptr[$pmsb:0]];

   always @(data_cur or data_nxt or din or next_rd_ptr or rd_din or rd_next or rd_ptr)
     $case (1\'b1)  $directive
       rd_din:
	 rd_data[$wmsb:0] = din[$wmsb:0];

       rd_next:
	 rd_data[$wmsb:0] = data_nxt[$wmsb:0];

       default:
	 rd_data[$wmsb:0] = data_cur[$wmsb:0];
     endcase 
   
   always @(posedge clk or negedge rst_n)
     if ( ~rst_n )
       dout[$wmsb:0] <= $w\'d0;
     else
       dout[$wmsb:0] <= rd_data[$wmsb:0];
 

EOF
}
else {
    print FH << "EOF"
   assign dout[$wmsb:0] = data[rd_ptr[$pmsb:0]];


EOF
}

# ------------------------------
#   full/empty Flag
# ------------------------------
print FH << "EOF"
   // flag generation
   always @(posedge clk or negedge rst_n )
     if (~rst_n) begin
	empty <= 1\'b1;
	full  <= 1\'b0;
     end
     else
       $case ({rd_en, wr_en})  $directive
	 2\'b10: begin
	    empty <= rd_ptr[$pmsb:0] + $pwidth\'b1 == wr_ptr[$pmsb:0];
	    full  <= 1\'b0;
	 end

	 2\'b01: begin
	    empty <= 1\'b0;
	    full  <= wr_ptr[$pmsb:0] + $pwidth\'b1 == rd_ptr[$pmsb:0];
	 end

	 default: begin
	    empty <= empty;
	    full  <= full;
	 end
       endcase


EOF
    ;

# ------------------------------
#   almost full flag
# ------------------------------
if ( $fth ) {
    print FH << "EOF"
   // Almost full flag generation
   always @(posedge clk or negedge rst_n )
     if (~rst_n) begin
	almost_full  <= 1\'b0;
     end
     else
       $case ({rd_en, wr_en})  $directive
	 2\'b10:   almost_full <= (rd_ptr[$pmsb:0] - wr_ptr[$pmsb:0] <= $pwidth\'d$fth_s); // Fth - 1
	 2\'b01:   almost_full <= (rd_ptr[$pmsb:0] - wr_ptr[$pmsb:0] <= $pwidth\'d$fth_p); // Fth + 1
	 default: almost_full <= almost_full;
       endcase

EOF
}


# ------------------------------
#   almost empty flag
# ------------------------------
if ( $eth ) {
    print FH << "EOF"
   // Almost empty flag generation
   always @(posedge clk or negedge rst_n )
     if (~rst_n) begin
	almost_empty  <= 1\'b1;
     end
     else
       $case ({rd_en, wr_en})  $directive
	 2\'b10:   almost_empty <= (wr_ptr[$pmsb:0] - rd_ptr[$pmsb:0] <= $pwidth\'d$eth_p); // Eth + 1
	 2\'b01:   almost_empty <= (wr_ptr[$pmsb:0] - rd_ptr[$pmsb:0] <= $pwidth\'d$eth_s); // Eth - 1 
	 default: almost_empty <= almost_empty;
       endcase

EOF
;
}


# ------------------------------
#   Report capability
# ------------------------------
if ( $chk ) {
    print FH "   // FIFO overflow/underflow Checker\n";
    print FH "\`ifdef $macro\n";

    if ( $sv ) {
	print FH << 'EOF'
     property no_overflow;
     @(posedge pclk )
        disable iff ( ~rst_n )
	   wr_en |-> ~full;
     endproperty

     property no_underflow;
     @(posedge pclk )
        disable iff ( ~rst_n )
	   rd_en |-> ~empty;
     endproperty

     assert property (no_overflow)
        else $dispaly("**SFIFO ERROR: overflow!!");

     assert property (no_underflow)
        else $dispaly("**SFIFO ERROR: underflow!!");
EOF
    ;
    }
    else {
	print FH << 'EOF'
   always @( posedge clk or negedge rst_n )
     begin 
       if ( rd_en && empty ) $dispaly("**SFIFO ERROR: underflow!! %t, %m", $time);
       if ( wr_en && full )  $dispaly("**SFIFO ERROR: overflow!! %t, %m", $time);
     end
EOF
;
    }


    print FH "\`endif\n";
}


# ------------------------------
#   Module end
# ------------------------------
print FH "\n\nendmodule\n";

close FH;
