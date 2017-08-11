#! /usr/bin/perl

my $conn_rule = "";

my $state = "normal";

foreach $file (@ARGV) {
    open VP, $file or die "Error: Cannot open $file for read.\n" ;
    print "Transforming $file...\n";

    my $mfile = $file;
    $mfile =~ s/\.vp$/.mhdl/;
    open MHDL, "> $mfile" or die "Error: Cannot open $mfile for write.\n";

    while (<VP>) {
	if ( $state eq "vperl_off" ) {
	    if ( /csky +vperl_on/i ) {
		print MHDL "endrawcode\n";
		$state = "normal";
		next;
	    }
	    else {
		print MHDL $_;
		next;
	    }
	}
	
	if ( $state eq "look_for_connect" ) {
	    if ( /^ *&Connect *\((.*)/ ) {
		if ( $conn_rule ) {
		    print MHDL "($conn_rule,\n $1\n";
		    $conn_rule = "";
		}
		else {
		    print MHDL "($1\n";
		}
		$state = "normal";
		next;
	    }
	    else {
		if ( $conn_rule ) {
		    print MHDL "($conn_rule)";
		    $conn_rule = "";
		}
		print MHDL ";\n";

		$state = "normal";
	    }
	}

	# Normal
	if ($state eq "normal") { 
	    if ( /^ *&(ModuleBeg|Ports.*|Regs|Wires|ModuleEnd)/ ) {
		print MHDL "// $_\n";
	    }
	    elsif ( /^ *&ConnRule *\( *(s.*) *\);$/ )  {
		if ( $conn_rule eq "" ) {
		    $conn_rule = '"'. $1 . '"';
		}
		else {
		    $conn_rule = $conn_rule . ",\n" . '"'. $1 . '"';
		}
		print MHDL "// $_";
	    }
	    elsif ( /^ *&Instance *\((.*)\)/ ) {
		my $t = $1;
		$t =~ s/ |\t|\"//g;
		my @a;

		if ( $t =~ /\'(.*)\'/ ) {
		    my $param = $1; 
		    $t =~ s/\'.*\',(.*)/$1/;
		    @a = split /, */, $t;

		    print MHDL "$a[0] $param $a[1]";
		}
		else {
		    @a = split /, */, $t;

		    print MHDL "$a[0] $a[1]";
		}	    

		$state = "look_for_connect";
	    }
	    elsif ( /^ *&Force *\((.*)\)/ ) {
		my @a = split /, */, $1;
		foreach (@a) {
		    $_ =~ s/\"//g;
		}
		if ( $a[0] =~ "bus" ) {
		    print MHDL "logic [$a[2]:$a[3]] $a[1];\n";
		}
		elsif ( $a[0] =~ "mem" ) {
		    print MHDL "logic [$a[2]:$a[3]] $a[1] [$a[4]:$a[5]];\n";
		}
		elsif ( $a[0] =~ "reg" ) {
		    print MHDL "// $_\n" ;
		}
		else {
		    $a[0] =~ s/nonports/nonport/;
		    print MHDL "$a[0] $a[1];\n";
		}
	    }
	    elsif ( /^ *&Depend.+(\".*\")/ ) {
		print MHDL "// $_\n";
	    }
	    elsif ( /^ *&CombBeg.*$/ ) {
		print MHDL "always_comb begin\n";
	    }
	    elsif ( /^ *&CombEnd.*$/ ) {
		print MHDL "end\n";
	    }
	    elsif ( /^ *&ChkOneHot/ ) {
		print MHDL "// $_\n";
	    }
	    elsif ( /csky +vperl_off/i ) {
		print MHDL "rawcode\n";
		$state = "vperl_off";
	    }
	    elsif ( /always *\@/ && ! /posedge/ ) {
		print MHDL "always_comb ";
		if ( /\bbegin\b/ ) {
		    print MHDL "begin\n";
		}
		else {
		    print MHDL "\n";
		}
	    }
	    elsif ( /^ *\`timescale/ ) {
		print MHDL "// $_";
	    }
	    else {
		print MHDL "$_";
	    }
	}
    }
    close VP;
    close MHDL;
}
    
