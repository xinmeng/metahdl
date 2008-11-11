#! /usr/bin/perl

use Getopt::Long;

my ($width, $depth, $th_af, $th_ae);

GetOptions('width=i' => \$width, 
	   'depth=i' => \$depth, 
	   'almost_full=i' => \$th_af,
	   'almost_empty=i' => \$th_ae);

# validating arguments
die "Depth must be an postive even number!\n" if $depth <= 0 || $depth % 2 != 0 ;
die "Width must be an postive number!\n" if $width <= 0 ;
die "(Almost full threshold) must less than (depth - 1)!\n" if $depth - $th_af <= 1;
die "(Almost empty threshold) must less than (depth -1)!\n" if $depth - $th_ae <= 1;

# basic values
my %gray_code = &gray($depth);

my $awidth = $gray_code{'bits'};
my $extra  = $gray_code{'full_depth'} - $depth;
my @gcodes = @{$gray_code{'code'}};

my $amsb = $awidth - 1;
my $dmsb = $width - 1;

my $module_name = "afifo_" . $depth . "x" . $width;
my $file_name = $module_name . ".sv";

open SVFILE, "> $file_name " or die "Cannot open $file_name for write!\n";
select SVFILE;

&module_begin();
&ports();
&var_declarations();
&write_domain();
&read_domain();
&module_end();



sub module_begin { 
    print << 'EOF';
// This asynchronous FIFO is automatically generated by script
// 'gen_afifo.pl' which was developped by mengxin@vlsi.zju.edu.cn
// Use this module at you own risk.
// 
EOF
; 

    print << "EOF" ;
//   Depth : $depth
//   Width : $width
EOF
;

    print "//   Almost Full Threshold  : $th_af\n" if $th_af ;
    print "//   Almost Empty Threshold : $th_ae\n" if $th_ae ;
    print "// \n\n\n";



    print "module $module_name (\n";
    print "  almost_empty,\n" if $th_ae;
    print "  almost_full,\n"  if $th_af;
    print "  din,\n";
    print "  dout, \n";
    print "  empty, \n";
    print "  full, \n";
    print "  rclk, \n";
    print "  rd, \n";
    print "  rrst_n, \n";
    print "  wclk, \n";
    print "  wr, \n";
    print "  wrst_n);\n";

    print "\n\n";
}


sub ports {
    print "output almost_empty;\n" if $th_ae;
    print "output almost_full;\n" if $th_af;
    print "input [$dmsb:0] din;\n";
    print "output [$dmsb:0] dout;\n";
    print "output empty;\n";
    print "output full;\n";
    print "input rclk;\n";
    print "input rd;\n";
    print "input rrst_n;\n";
    print "input wclk;\n";
    print "input wr;\n";
    print "input wrst_n;\n";

    print "\n\n";
}


sub var_declarations {
    my $depth_msb = $depth - 1;

    print "logic almost_empty;\n" if $th_ae;
    print "logic almost_full;\n"  if $th_af;
    print "logic [$dmsb:0] data[$depth_msb:0] ;\n";
    print "logic [$dmsb:0] din;\n";
    print "logic [$dmsb:0] dout;\n";
    print "logic empty;\n";
    print "logic full;\n";
    print "logic [$amsb:0] rbptr;\n";
    print "logic [$amsb:0] rbptr_at_wr;\n";
    print "logic rclk;\n";
    print "logic rd;\n";
    print "logic [$amsb:0] rgptr;\n";
    print "logic [$amsb:0] rgptr_at_wr;\n";
    print "logic [$amsb:0] rgptr_to_wr;\n";
    print "logic [$amsb:0] rgptr_to_wr_ff;\n";
    print "logic rrst_n;\n";
    print "logic [$amsb:0] wbptr;\n";
    print "logic [$amsb:0] wbptr_at_rd;\n";
    print "logic wclk;\n";
    print "logic [$amsb:0] wgptr;\n";
    print "logic [$amsb:0] wgptr_at_rd;\n";
    print "logic [$amsb:0] wgptr_to_rd;\n";
    print "logic [$amsb:0] wgptr_to_rd_ff;\n";
    print "logic wr;\n";
    print "logic wrst_n;\n";

    print "\n\n";
}


sub write_domain {
    print << "EOF";
// ------------------------------
//   Write domain
// ------------------------------
always_ff @(posedge wclk or negedge wrst_n)
  if (~wrst_n) begin
    wbptr[$amsb:0] <= $awidth\'d0;
  end
  else begin
    wbptr[$amsb:0] <= wr ? wbptr[$amsb:0] == $depth - 1 ? $awidth\'d0 : wbptr[$amsb:0] + 1\'b1 : wbptr[$amsb:0];
  end

always_ff @(posedge wclk) begin
    data[wbptr[$amsb:0]] <= wr ? din[$dmsb:0] : data[wbptr[$amsb:0]];
end

EOF
;
    &gen_gray_encoder('wbptr', 'wgptr');

    print << "EOF";
always_ff @(posedge wclk or negedge wrst_n)
  if (~wrst_n) begin
    wgptr_to_rd[$amsb:0] <= $awidth\'d0;
    rgptr_to_wr_ff[$amsb:0] <= $awidth\'d0;
    rgptr_at_wr[$amsb:0] <= $awidth\'d0;
  end
  else begin
    wgptr_to_rd[$amsb:0] <= wgptr[$amsb:0];
    rgptr_to_wr_ff[$amsb:0] <= rgptr_to_wr[$amsb:0];
    rgptr_at_wr[$amsb:0] <= rgptr_to_wr_ff[$amsb:0];
  end

EOF
;

    &gen_gray_decoder('rbptr_at_wr', 'rgptr_at_wr', 'wclk', 'wrst_n');

    print << "EOF";
logic [$awidth:0] wdiff_tmp;
logic [$amsb:0] wdiff;


assign wdiff_tmp[$awidth:0] = {1\'b0, rbptr_at_wr[$amsb:0]} - {1\'b0, wbptr[$amsb:0]};
assign wdiff[$amsb:0] = wdiff_tmp[$awidth] ? wdiff_tmp[$amsb:0] - $awidth\'d$extra : wdiff_tmp[$amsb:0];

always_ff @(posedge wclk or negedge wrst_n)
  if (~wrst_n) begin
    full <= 1\'b0;
  end
  else begin
    full <= wr ? (wdiff[$amsb:0] == $awidth\'d1 ? 1\'b1 : 1\'b0) : 
                 (wdiff[$amsb:0] == $awidth\'d0 ? full : 1\'b0);
  end

EOF
;

    if ( $th_af ) {
	print << "EOF";
always_ff @(posedge wclk or negedge wrst_n)
  if (~wrst_n) begin
    almost_full <= 1\'b0;
  end
  else begin
    almost_full <= wr ? (wdiff[$amsb:0] > 0 && wdiff[$amsb:0] <= $awidth\'d1 + $awidth\'d$th_af ? 1\'b1 : 1\'b0) : 
                        (wdiff[$amsb:0] <= $awidth\'d0 + $awidth\'d$th_af ? almost_full : 1\'b0);
  end

EOF
;
    }

    print "\n\n";
}


sub read_domain {
    print << "EOF";
// ------------------------------
//   Read domain
// ------------------------------
always_ff @(posedge rclk or negedge rrst_n)
  if (~rrst_n) begin
    rbptr[$amsb:0] <= $awidth\'d0;
  end
  else begin
    rbptr[$amsb:0] <= rd ? rbptr[$amsb:0] == $depth - 1 ? $awidth\'d0 : rbptr[$amsb:0] + 1\'b1 : rbptr[$amsb:0];
  end

assign dout[$dmsb:0] = data[rbptr[$amsb:0]];

EOF
;

    &gen_gray_encoder('rbptr', 'rgptr');

    print << "EOF";
always_ff @(posedge rclk or negedge rrst_n)
  if (~rrst_n) begin
    rgptr_to_wr[$amsb:0] <= $awidth\'d0;
    wgptr_to_rd_ff[$amsb:0] <= $awidth\'d0;
    wgptr_at_rd[$amsb:0] <= $awidth\'d0;
  end
  else begin
    rgptr_to_wr[$amsb:0] <= rgptr[$amsb:0];
    wgptr_to_rd_ff[$amsb:0] <= wgptr_to_rd[$amsb:0];
    wgptr_at_rd[$amsb:0] <= wgptr_to_rd_ff[$amsb:0];
  end

EOF
;

    &gen_gray_decoder('wbptr_at_rd', 'wgptr_at_rd', 'rclk', 'rrst_n');

    print << "EOF";
logic [$awidth:0] rdiff_tmp;
logic [$amsb:0] rdiff;


assign rdiff_tmp[$awidth:0] = {1\'b0, wbptr_at_rd[$amsb:0]} - {1\'b0, rbptr[$amsb:0]};
assign rdiff[$amsb:0] = rdiff_tmp[$awidth] ? rdiff_tmp[$amsb:0] - $awidth\'d$extra : rdiff_tmp[$amsb:0];

always_ff @(posedge rclk or negedge rrst_n)
  if (~rrst_n) begin
    empty <= 1\'b1;
  end
  else begin
    empty <= rd ? (rdiff[$amsb:0] == $awidth\'d1 ? 1\'b1 : 1\'b0) : 
                  (rdiff[$amsb:0] == $awidth\'d0 ? empty : 1\'b0);
  end

EOF
;

    if ( $th_ae ) {
	print << "EOF"; 
always_ff @(posedge rclk or negedge rrst_n)
  if (~rrst_n) begin
    almost_empty <= 1\'b1;
  end
  else begin
    almost_empty <= rd ? (rdiff[$amsb:0] > 0 && rdiff[$amsb:0] <= $awidth\'d1 + $awidth\'d$th_ae ? 1\'b1 : 1\'b0) : 
                         (rdiff[$amsb:0] <= $awidth\'d0 + $awidth\'d$th_ae ? almost_empty : 1\'b0);
  end

EOF
;
    }

    print "\n";

}



sub module_end {
    print "endmodule\n";
}




sub gen_gray_encoder {
    my ($b, $g) = @_;

    print "always_comb begin\n";
    print "  unique case ( $b\[$amsb:0] ) \n";
    for (my $i=0; $i<=$#gcodes; $i++) {
	printf('    %d\'d%-4d: ' . "$g". '[%4$d:0] = %1$d\'b%0*1$b;' . "\n", 
	   $awidth, $i, $gcodes[$i], $amsb);
    }
    print "    default: $g\[$amsb:0] = $awidth\'b" . 'X' x $awidth . ";\n";
    print "  endcase\n";
    print "end\n";
    print "\n";
}

sub gen_gray_decoder {
    my ($b, $g, $clk, $rst) = @_;

    print << "EOF";
always_ff @(posedge $clk or negedge $rst) begin
  if ( ~$rst ) begin
    $b\[$amsb:0] <= $awidth\'d0;
  end
  else begin
    unique case ( $g\[$amsb:0] )
EOF
;

    for ( my $i=0; $i<=$#gcodes; $i++) {
    printf('      %d\'b%0*1$b:'. " $b" . '[%4$d:0] <= %1$d\'d%3$d;' . "\n", 
	   $awidth, $gcodes[$i], $i, $amsb);
    }
    print "      default: $b\[$amsb:0] <= $awidth\'b". 'X' x $awidth . ";\n";
    print "    endcase\n";
    print "  end\n";
    print "end\n";
    print "\n";
}



sub gray {
    my ($depth) = @_;

    my $full_gray_code_count = 2;
    while ( $depth > $full_gray_code_count ) {
	$full_gray_code_count *= 2;
    }

    my $bits;
    if ( int(log2($depth)) < log2($depth) ) {
	$bits = int(log2($depth)) + 1;
    }
    else {
	$bits = int(log2($depth));
    }

    my @gray_code = (0, 1);
    my $count = 2;
    while ( $count != $full_gray_code_count ) {
	my $msk = 1 << log2($count);
	for ( $i = $count-1; $i>=0; $i-- ) {
	    push @gray_code, ($msk | $gray_code[$i]);
	}
	$count *= 2;
    }


    my @ultimate_gray_code ;
    if ( $depth < $full_gray_code_count ) {
	my $lo_boundary = $full_gray_code_count / 2 - ($full_gray_code_count - $depth) / 2 - 1;
	my $hi_boundary = $full_gray_code_count / 2 + ($full_gray_code_count - $depth) / 2;

	push @ultimate_gray_code, @gray_code[0..$lo_boundary];
	push @ultimate_gray_code, @gray_code[$hi_boundary..$#gray_code];
    }
    else {
	@ultimate_gray_code = @gray_code;
    }

    my %h = ('bits' => $bits, 'full_depth' => $full_gray_code_count);
    push @{$h{'code'}}, @ultimate_gray_code;

    return %h;

#     foreach ( @ultimate_gray_code ) {
# 	printf("%.*b\n", $bits, $_);
#     }

}

sub log2 {
    my $n = shift;
    return log($n)/log(2);
}

