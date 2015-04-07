#! /usr/bin/perl

my $file = shift;

open FH, $file or die "ERROR:Can not open $file for read.$!\n";

open TEX, "> BNF.tex" or die "ERROR:Can not open BNF.tex for write.$!\n";

my $state = "other";

while ( <FH> ) {

    if ( $state eq "other" ) {
	if ( /^Grammar$/ ) {
	    $state = "grammar";
	}
    }
    elsif ( $state eq "grammar" ) {
	if ( /^Terminals, with rules where they appear$/ ) {
	    exit;
	}
	elsif ( /^ +0 \$accept/ || /^ +\d+ \@/ || /^$/) { 
	    # drop this line
	}
        elsif ( /\$\@\d: \/\* empty \*\// ) {
            # drop this line
        }
	else {
	    $_ =~ s/^ +\d+ (.*)/$1/;
	    $_ =~ s/\$\@\d //g;
	    

	    $_ =~ s/(\$|%|&|\{|\}|\#)/\\textbf{\\textcolor{red}{\\$1}}/g;
	    $_ =~ s/([A-Z_]{2,})/\\textbf{\\textcolor{red}{$1}}/g;
	    $_ =~ s/_/\\_/g;
	    $_ =~ s/(\+|-|>|<)/\$$1\$/g;
	    $_ =~ s/"(\^|~)"/\\textbf{\\textcolor{red}{\\$1\{\}}}/g;
	    $_ =~ s/"(\S+)"/\\textbf{\\textcolor{red}{$1}}/g;
	    $_ =~ s/\|/\$|\$/g; 

	    if (  /^(\S+):/ ) {
		$_ =~ s/^(\S+):/\n\\vspace{1em}\n\\noindent\n\\settowidth{\\parindent}{\\hspace{4ex}}\n$1 \$::=\$\\hspace{1ex}/;
	    }
	    else {
		$_ =~ s/^\s+(.*)/\n\\mbox{$1}/;
	    }
	    print TEX;
	}
    }
}
close FH; 
close TEX;

    
