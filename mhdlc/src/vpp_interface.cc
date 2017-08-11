/* Copyright (C) 1996 Himanshu M. Thaker

   This file is part of vpp.

   Vpp is distributed in the hope that it will be useful,
   but without any warranty.  No author or distributor
   accepts responsibility to anyone for the consequences of using it
   or for whether it serves any particular purpose or works at all,
   unless he says so in writing.

   Everyone is granted permission to copy, modify and redistribute
   vpp, but only under the conditions described in the
   document "vpp copying permission notice".   An exact copy
   of the document is supposed to have been given to you along with
   vpp so that you can know how you may redistribute it all.
   It should be in a file named COPYING.  Among other things, the
   copyright notice and this notice must be preserved on all copies.  */

/*
 * Program : vpp
 * Author : Himanshu M. Thaker
 * Date : Apr. 16, 1995
 * Description :
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>

#include "common.h"
#include "yacc_stuff.h"
#include "proto.h"
#include <string.h>
#include <stdio.h>

#include <string>
using namespace std;
extern FILE *yyout;
extern char *current_file;
extern int yyerror_count;
extern int yy_flex_debug;

#include "Mfunc.hh"


int
preprocess(FILE *in, const string &f, FILE *out)
{
  yyin  =  in;
  yyout =  out;

  current_file = (char*) malloc(f.length()+1);
  strcpy(current_file, f.c_str());

  nl_count = 1;
  do_comment_count(TRUE, nl_count);

  yy_flex_debug = DebugPPLexer;
  yyparse();
  
  return yyerror_count;
}



