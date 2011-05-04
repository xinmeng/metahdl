%p 6000
%e 2000
%option debug
%option outfile="vpp.flex.cc"
%{

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


#include <string>
#include <iostream>
#include <sstream>
using namespace std;
#include "common.h"
#include "yacc_stuff.h"
#include "proto.h"
#include "vpp.bison.hh"
#include <ctype.h>
#include <math.h>

extern int fileno(FILE *);
extern char ttid[]; /* From vpp.y */

typedef struct macro_parms
   {
   char name[MAXSTR];
   char *value;
   struct macro_parms *next;
   } macro_parms;

typedef struct names
   {
	char *macro_name;
	char *macro;
	int is_number;
	double value;
	struct macro_parms *parms;
	struct names *next;
   } names;

void store_it(char *str, int subst, int expand_define);
int hash(char *text);
int delete_entry(names *table[], char *macro_name, int hashval);
void add_macro(names *table[], char *macro_name, int hashval, char *text, char *parms);
void store_lines();
void do_post_command(char *txt, int post_type);
int is_keyword(char *name);
void undef_macro(char *def_text);
char *SearchFile(const char *name);

gen_ll_mgr *code_pointer = NULL;
char line[MAXNAME];
names *Defines_Table[BASE];
int nl_count = 1;

string get_macro_value(char *name);
names *lookup_define(names *table[], char *macro_name, int hashval);
#define MAX_INCLUDE_DEPTH 64
YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];
int include_nl_count[MAX_INCLUDE_DEPTH];
char *include_fname[MAX_INCLUDE_DEPTH];
int last_mode = 0; /* INITIAL */ 
int include_stack_ptr = 0;

#define YY_USER_ACTION store_lines();
char old_line[MAXNAME];
char current_line[MAXNAME];
#define COMMENT_EVERY 100

int RecursiveMacroLevel =0;
char *current_file;
int output_line_directive;
int cmnt_saved_state;
int tick_saved_state = -1;
int incl_saved_state = -1;
int include_state[MAX_INCLUDE_DEPTH];

#define PP 0
#define MM 1
#define PE 2
#define ME 3

%}

%x DEFINE
%x MACRO
%x CMNT
%x CCMNT
%x MPP
%x COPY
%x INCL
%x SKIP_TO_EOL

WHITE		[ \t]
NEWLINE		[\n]
DIGIT10		[0-9_]
NMBR10		{DIGIT10}+
NAME		[a-zA-Z_][a-zA-Z0-9_\$]*
MEM		\[[^;\n\]]*\]

%%

<INITIAL>"/*"		{cmnt_saved_state = YYSTATE;fprintf(yyout, "%s",yytext);BEGIN(CMNT);}
<COPY>"/*"		{cmnt_saved_state = YYSTATE;store_it(yytext,FALSE,FALSE);BEGIN(CCMNT);}
<MPP>"/*"		{cmnt_saved_state = YYSTATE;store_it(yytext,FALSE,FALSE);BEGIN(CCMNT);return TTCOMMENT2;}

<CMNT>{NEWLINE} 	{fprintf(yyout, "%s",yytext);nl_count++;}
<CMNT>"/*" 		{fprintf(yyout, "%s",yytext);/* fprintf(stderr,"WARNING : `/\*' within comment\n"); */}
<CMNT>"*/" 		{fprintf(yyout, "%s",yytext);BEGIN(cmnt_saved_state);}
<CMNT>. 		{fprintf(yyout, "%s",yytext);}
<CCMNT>{NEWLINE}	{store_it(yytext,FALSE,FALSE);nl_count++;}
<CCMNT>"/*" 		{store_it(yytext,FALSE,FALSE);/* fprintf(stderr,"WARNING : `/\*' within comment\n"); */}
<CCMNT>"*/" 		{store_it(yytext,FALSE,FALSE);BEGIN(cmnt_saved_state);}
<CCMNT>. 		{store_it(yytext,FALSE,FALSE);}

<INITIAL>"//".*$	{fprintf(yyout, "%s",yytext);}
<COPY>"//".*$		{store_it(yytext,FALSE,FALSE);}
<MPP>"//".*$		{store_it(yytext,FALSE,FALSE);return TTCOMMENT;}

<COPY>`accelerate		{store_it(yytext,FALSE,FALSE);}
<COPY>`noaccelerate		{store_it(yytext,FALSE,FALSE);}
<COPY>`autoexpand_vectornets	{store_it(yytext,FALSE,FALSE);}
<COPY>`celldefine		{store_it(yytext,FALSE,FALSE);}
<COPY>`endcelldefine		{store_it(yytext,FALSE,FALSE);}
<COPY>`default_decay_time	{store_it(yytext,FALSE,FALSE);}
<COPY>`default_nettype		{store_it(yytext,FALSE,FALSE);}
<COPY>`default_rswitch_strength	{store_it(yytext,FALSE,FALSE);}
<COPY>`default_switch_strength	{store_it(yytext,FALSE,FALSE);}
<COPY>`default_trireg_strength	{store_it(yytext,FALSE,FALSE);}
<COPY>`delay_mode_distributed	{store_it(yytext,FALSE,FALSE);}
<COPY>`delay_mode_path		{store_it(yytext,FALSE,FALSE);}
<COPY>`delay_mode_unit		{store_it(yytext,FALSE,FALSE);}
<COPY>`delay_mode_zero		{store_it(yytext,FALSE,FALSE);}
<COPY>`expand_vetornets		{store_it(yytext,FALSE,FALSE);}
<COPY>`noexpand_vectornets	{store_it(yytext,FALSE,FALSE);}
<COPY>`protect			{store_it(yytext,FALSE,FALSE);}
<COPY>`endprotect		{store_it(yytext,FALSE,FALSE);}
<COPY>`pre_16a_paths		{store_it(yytext,FALSE,FALSE);}
<COPY>`end_pre_16a_paths	{store_it(yytext,FALSE,FALSE);}
<COPY>`protected		{store_it(yytext,FALSE,FALSE);}
<COPY>`unprotected		{store_it(yytext,FALSE,FALSE);}
<COPY>`remove_gatenames		{store_it(yytext,FALSE,FALSE);}
<COPY>`noremove_gatenames	{store_it(yytext,FALSE,FALSE);}
<COPY>`resetall			{store_it(yytext,FALSE,FALSE);}
<COPY>`rs_technology		{store_it(yytext,FALSE,FALSE);}
<COPY>"`switch default"		{store_it(yytext,FALSE,FALSE);}
<COPY>"`switch resisitive"	{store_it(yytext,FALSE,FALSE);}
<COPY>"`switch XL"		{store_it(yytext,FALSE,FALSE);}
<COPY>`timescale		{store_it(yytext,FALSE,FALSE);}
<COPY>`unconnected_drive	{store_it(yytext,FALSE,FALSE);}
<COPY>`nounconnected_drive	{store_it(yytext,FALSE,FALSE);}
<COPY>`uselib			{store_it(yytext,FALSE,FALSE);}
<COPY>`FSDB_DUMP_BEGIN		{store_it(yytext,FALSE,FALSE);}
<COPY>`FSDB_DUMP_END            {store_it(yytext,FALSE,FALSE);}

<INITIAL>`accelerate		{fprintf(yyout, "%s",yytext);}
<INITIAL>`noaccelerate		{fprintf(yyout, "%s",yytext);}
<INITIAL>`autoexpand_vectornets	{fprintf(yyout, "%s",yytext);}
<INITIAL>`celldefine		{fprintf(yyout, "%s",yytext);}
<INITIAL>`endcelldefine		{fprintf(yyout, "%s",yytext);}
<INITIAL>`default_decay_time	{fprintf(yyout, "%s",yytext);}
<INITIAL>`default_nettype	{fprintf(yyout, "%s",yytext);}
<INITIAL>`default_rswitch_strength	{fprintf(yyout, "%s",yytext);}
<INITIAL>`default_switch_strength	{fprintf(yyout, "%s",yytext);}
<INITIAL>`default_trireg_strength	{fprintf(yyout, "%s",yytext);}
<INITIAL>`delay_mode_distributed	{fprintf(yyout, "%s",yytext);}
<INITIAL>`delay_mode_path	{fprintf(yyout, "%s",yytext);}
<INITIAL>`delay_mode_unit	{fprintf(yyout, "%s",yytext);}
<INITIAL>`delay_mode_zero	{fprintf(yyout, "%s",yytext);}
<INITIAL>`expand_vetornets	{fprintf(yyout, "%s",yytext);}
<INITIAL>`noexpand_vectornets	{fprintf(yyout, "%s",yytext);}
<INITIAL>`protect		{fprintf(yyout, "%s",yytext);}
<INITIAL>`endprotect		{fprintf(yyout, "%s",yytext);}
<INITIAL>`pre_16a_paths		{fprintf(yyout, "%s",yytext);}
<INITIAL>`end_pre_16a_paths	{fprintf(yyout, "%s",yytext);}
<INITIAL>`protected		{fprintf(yyout, "%s",yytext);}
<INITIAL>`unprotected		{fprintf(yyout, "%s",yytext);}
<INITIAL>`remove_gatenames	{fprintf(yyout, "%s",yytext);}
<INITIAL>`noremove_gatenames	{fprintf(yyout, "%s",yytext);}
<INITIAL>`resetall		{fprintf(yyout, "%s",yytext);}
<INITIAL>`rs_technology		{fprintf(yyout, "%s",yytext);}
<INITIAL>"`switch default"	{fprintf(yyout, "%s",yytext);}
<INITIAL>"`switch resisitive"	{fprintf(yyout, "%s",yytext);}
<INITIAL>"`switch XL"		{fprintf(yyout, "%s",yytext);}
<INITIAL>`timescale		{fprintf(yyout, "%s",yytext);}
<INITIAL>`unconnected_drive	{fprintf(yyout, "%s",yytext);}
<INITIAL>`nounconnected_drive	{fprintf(yyout, "%s",yytext);}
<INITIAL>`uselib		{fprintf(yyout, "%s",yytext);}
<INITIAL>`FSDB_DUMP_BEGIN	{store_it(yytext,FALSE,FALSE);}
<INITIAL>`FSDB_DUMP_END         {store_it(yytext,FALSE,FALSE);}


<INITIAL,DEFINE,MACRO,CMNT,CCMNT,MPP,COPY,INCL,SKIP_TO_EOL>`line.*\n {
  fprintf(stderr, 
	  "**PP Lexer Error:%s:%d:`line does not supported\n", 
	  current_file, yylineno); 
  exit(1);
}



<INITIAL,COPY>^{WHITE}*"`ifdef"		{return TTIFDEF;}
<INITIAL,COPY>^{WHITE}*"`ifndef"	{return TTIFNDEF;}
<INITIAL,COPY>^{WHITE}*"`if"		{return TTIF;}
<INITIAL,COPY>^{WHITE}*"`let"		{return TTLET;}
<INITIAL,COPY>^{WHITE}*"`for"		{return TTFOR;}
<INITIAL,COPY>^{WHITE}*"`while"		{return TTWHILE;}
<INITIAL,COPY>^{WHITE}*"`switch"	{return TTSWITCH;}
<INITIAL,COPY>^{WHITE}*"`case"		{return TTCASE;}
<INITIAL,COPY>^{WHITE}*"`default"	{return TTDEFAULT;}
<INITIAL,COPY>^{WHITE}*`breaksw[^\n]*	{return TTBREAKSW;}
<INITIAL,COPY>^{WHITE}*`else[^\n]*	{return TTELSE;}
<INITIAL,COPY>^{WHITE}*`endif[^\n]*	{return TTENDIF;}
<INITIAL,COPY>^{WHITE}*`endfor[^\n]*	{return TTENDFOR;}
<INITIAL,COPY>^{WHITE}*`endwhile[^\n]*	{return TTENDWHILE;}
<INITIAL,COPY>^{WHITE}*`endswitch[^\n]*	{return TTENDSWITCH;}

<INITIAL,COPY>{WHITE}*"`define"	{
			 yyless(yyleng);
			 current_line[strlen(current_line)-yyleng] = '\0';
			 yymore();
			 tick_saved_state=YYSTATE;
			 BEGIN(MACRO);
			}
<MACRO>{NEWLINE}	{
			 if (yytext[yyleng-2] != '\\') {
			   yyless(yyleng-1);
			   if (tick_saved_state == INITIAL) {
			     /* fprintf(yyout, "%s",yytext); */
			     store_define(yytext);
			   }
			   else if (tick_saved_state == COPY) {
			      string s = yytext;
			      s = s.substr(s.find_first_not_of(" \t"));
			      char *cp = (char*) calloc(1, s.length()+1);
			      strcpy(cp, s.c_str());
			     store_it(cp,FALSE,FALSE);
			   }
			   BEGIN(tick_saved_state);
			   tick_saved_state = -1;
			 }
			 else {
			   yyless(yyleng);
			   current_line[strlen(current_line)-yyleng] = '\0';
			   yymore();
			 }
			}
<MACRO>[^\n]*		{
			 yyless(yyleng);
			 current_line[strlen(current_line)-yyleng] = '\0';
			 yymore();
			}

<INITIAL>`undef[^\n]*	{undef_macro(yytext);fprintf(yyout, "%s",yytext);}
<COPY>`undef[^\n]*	{undef_macro(yytext);store_it(yytext,FALSE, FALSE);}

<INITIAL,COPY>`include	{incl_saved_state=YYSTATE;BEGIN(INCL);}

<INITIAL,COPY>\"[^\"]*\"	{
				 /* Check for an escaped close qoute. */
				 if (yytext[yyleng-2] == '\\') {
				   yyless(yyleng-1); /* Return last qoute. */
				   yymore(); /* Append next string. */
				 }
				 else {
				   if (YYSTATE == INITIAL) {
				     fprintf(yyout, "%s", yytext);
				   }
				   else if (YYSTATE == COPY) {
				     store_it(yytext,FALSE,FALSE);
				   }
				 }
				}

<INITIAL,COPY,MPP>{NAME}{WHITE}*{MEM}?{WHITE}*"++" {do_post_command(yytext,PP);}
<INITIAL,COPY,MPP>{NAME}{WHITE}*{MEM}?{WHITE}*"--" {do_post_command(yytext,MM);}
<INITIAL,COPY,MPP>{NAME}{WHITE}*{MEM}?{WHITE}*"+=" {do_post_command(yytext,PE);}
<INITIAL,COPY,MPP>{NAME}{WHITE}*{MEM}?{WHITE}*"-=" {do_post_command(yytext,ME);}

<INCL>.*	   {
  char *s, *e, *inc_file_name;
  s = index(yytext, '"');
  e = index(s+1, '"');

  if ( s < e ) {
    inc_file_name = (char *) malloc(e-s);
    strncpy(inc_file_name, s+1, e-s-1);
    inc_file_name[e-s-1] = '\0';
  }
  else {
    fprintf(stderr, "** `include file name should be quoted by double-quote: \".\n");
    exit(1);
  }


  FILE *fp;
  if (include_stack_ptr >= MAX_INCLUDE_DEPTH) {
    fprintf(stderr, "ERROR : `include nesting limit reached\n");
    exit (1);
  }
  char * full_inc_file_name;

  full_inc_file_name = SearchFile(inc_file_name);
  if (!full_inc_file_name) {
    fprintf(stderr, "ERROR : `%s' : file not found\n", inc_file_name);
    exit(1);
    BEGIN(SKIP_TO_EOL);
  }
  else {
    include_state[include_stack_ptr] = incl_saved_state;
    include_nl_count[include_stack_ptr] = nl_count;
    include_fname[include_stack_ptr] = NMALLOC(strlen(current_file)+1, char);
    strcpy(include_fname[include_stack_ptr], current_file);
    free(current_file);
    current_file = NMALLOC(strlen(full_inc_file_name)+1,char);
    strcpy(current_file, full_inc_file_name);

    include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;

    nl_count = 1;
    yyin = fopen(full_inc_file_name, "r");
    if ( !yyin ) {
      fprintf(stderr, "ERROR: %s exists, but cannot open for read!\n", full_inc_file_name);
      exit(1);
    }
    else {
      yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE)); 
      do_comment_count(TRUE,nl_count);
      BEGIN(incl_saved_state);
      free(inc_file_name);
    }
  }
 }
<SKIP_TO_EOL>.*$	{BEGIN(incl_saved_state);incl_saved_state = -1;}

<<EOF>>		{
		  if (!include_stack_ptr) yyterminate();
		  else {
		    --include_stack_ptr;
		    yy_delete_buffer(YY_CURRENT_BUFFER);
		    yy_switch_to_buffer(include_stack[include_stack_ptr]);
		    nl_count = include_nl_count[include_stack_ptr];
		    free(current_file);
		    current_file = include_fname[include_stack_ptr];
		    incl_saved_state = include_state[include_stack_ptr];
		    do_comment_count(TRUE, nl_count);
		    BEGIN(SKIP_TO_EOL);
		  }
		}

<MPP>"LOG2"	{return TTLOG2;}
<MPP>"ROUND"	{return TTROUND;}
<MPP>"CEIL"	{return TTCEIL;}
<MPP>"FLOOR"	{return TTFLOOR;}
<MPP>"MAX"	{return TTMAX;}
<MPP>"MIN"	{return TTMIN;}
<MPP>"ABS"	{return TTABS;}
<MPP>"STOI"	{return TTSTOI;}
<MPP>"ITOS"	{return TTITOS;}
<MPP>"SUBSTR"	{return TTSUBSTR;}
<MPP>"SYSTEM"	{return TTSYSTEM;}
<MPP>"EVEN"	{return TTEVEN;}
<MPP>"ODD"	{return TTODD;}

<INITIAL,COPY>`{NAME}	{
   int hashval = hash(yytext+1);
   names *np = lookup_define(Defines_Table,yytext+1,hashval);
   if (np != 0 && np->parms != 0) {
      yyless(yyleng);
      current_line[strlen(current_line)-yyleng] = '\0';
      yymore();
      tick_saved_state=YYSTATE;
      BEGIN(DEFINE);
   }
   else {
      if ( YYSTATE == INITIAL ) {
	 string val = get_macro_value(yytext+1);
	 for ( int i = val.length()-1; i>=0; i-- ) 
	    unput(val[i]);

	 if ( val[0] == '`' ) {
	    if ( RecursiveMacroLevel >= 20 ) {
	       fprintf(stderr, "**VPP Error:%s:\"%s\":20 levels of reference detected on macro \"%s\", most probably caused by macro definition loop.\n", current_file, current_line, val.c_str());
	       exit(1);
	    }
	    else {
	       ++RecursiveMacroLevel;
	    }
	 }
	 else {
	    RecursiveMacroLevel = 0;
	 }
      }
      else { // YYSTATE == COPY 
	 store_it(yytext,TRUE,!output_ifdef_directive);
      }

// 			   if (YYSTATE == INITIAL) {
// 			     print_variable(yytext+1,!output_ifdef_directive);
// 			   }
// 			   else if (YYSTATE == COPY) {
// 			     store_it(yytext,TRUE,!output_ifdef_directive);
// 			   }
   }
}
<DEFINE>"(".*")"	{
			 if (tick_saved_state == INITIAL) {
			   print_variable(yytext+1,!output_ifdef_directive);
			 }
			 else if (tick_saved_state == COPY) {
			   store_it(yytext,TRUE,!output_ifdef_directive);
			 }
			 BEGIN(tick_saved_state);
			 tick_saved_state = -1;
			}
<DEFINE>.		{
			 yyless(yyleng-1);
			 if (tick_saved_state == INITIAL) {
			   print_variable(yytext+1, !output_ifdef_directive);
			 }
			 else if (tick_saved_state == COPY) {
			   store_it(yytext,TRUE,!output_ifdef_directive);
			 }
			 BEGIN(tick_saved_state);
			 tick_saved_state = -1;
			}

<INITIAL>{WHITE}+	{strcpy(ttid, yytext);return TTWHITE;}
<INITIAL,MPP>{NAME}	{
			 if (strchr(yytext,'`') != 0) {
			   fprintf(stderr,
				   "WARNING : invalid identifier %s\n",
				   yytext);
			 }
			 strcpy(ttid, yytext);
			 return TTNAME;
			}

<INITIAL>\\::		{fprintf(yyout, "::");}
<COPY>\\::		{store_it("::",FALSE,FALSE);}

<*>::			{}

<INITIAL,MPP>{NMBR10}			{strcpy(ttid, yytext);return TTNUM;}
<INITIAL,MPP>{DIGIT10}*\.{DIGIT10}+	{strcpy(ttid, yytext);return TTREALNUM;}
<INITIAL,MPP>{DIGIT10}+\.{DIGIT10}*	{strcpy(ttid, yytext);return TTREALNUM;}

<MPP>\"[^\"\n]*[\"]?  {strcpy(ttid,yytext);return TTQS;}
<MPP>{WHITE}+	{}
<MPP>{NEWLINE}	{nl_count++;return '\n';}
<MPP>"`"	{}
<MPP>":"	{return ':';}
<MPP>"("	{return '(';}
<MPP>")"	{return ')';}
<MPP>"+"	{return '+';}
<MPP>"-"	{return '-';}
<MPP>"*"	{return '*';}
<MPP>"/"	{return '/';}
<MPP>"%"	{return '%';}
<MPP>"**"	{return TT_POWER;}
<MPP>"=="	{return TTL_EQ;}
<MPP>"!="	{return TTL_NEQ;}
<MPP>"&&"	{return TTL_AND;}
<MPP>"||"	{return TTL_OR;}
<MPP>"<"	{return '<';}
<MPP>"<="	{return TTL_LEQ;}
<MPP>">"	{return '>';}
<MPP>">="	{return TTL_GEQ;}
<MPP>"&"	{return '&';}
<MPP>"|"	{return '|';}
<MPP>"^"	{return '^';}
<MPP>"<<"	{return TTL_SHIFTL;}
<MPP>">>"	{return TTL_SHIFTR;}
<MPP>"!"	{return '!';}
<MPP>"="	{return '=';}
<MPP>";"	{return ';';}
<MPP>"~"	{return '~';}
<MPP>","	{return ',';}
<MPP>.		{return TT_UNKNOWN;}

<COPY>{NEWLINE}	{store_it(yytext,FALSE,FALSE);nl_count++;}
<COPY>\\{NEWLINE} {store_it("",FALSE,FALSE);nl_count++;}
<COPY>.		{store_it(yytext,FALSE,FALSE);}
<INITIAL>{NEWLINE} {fprintf(yyout, "\n");do_comment_count(FALSE,nl_count);nl_count++;}
<INITIAL>\\{NEWLINE} {do_comment_count(FALSE,nl_count);nl_count++;}
<INITIAL>.	{fprintf(yyout, "%c",yytext[0]);}

%%

void
store_it(char *str1, int subst, int expand_define)
{
    int len;
    names *np;

    char *str = (char*)calloc(1, strlen(str1)+1);
    if ( ! *str1 ) {
      strcpy(str, "\n");
    }
    else {
      strcpy(str, str1);
    }
/*     char *str = (! *str1) ? "\n": str1; /\* Deleting newline from formating. *\/ */

    if ((strcmp(str,"\n") != 0) && (!subst)) {
	len = strlen(line) + strlen(str);
	if (len > MAXNAME)
	    yyerror("line too long");
	else
	    sprintf(line, "%s%s", line, str);
    }
    else {
	if ((is_keyword(str+1) && subst)) fprintf(yyout, "%s",str);
	else if (!subst && ! *str1) /* Void, deleting this newline. */;
	else if (!subst) sprintf(line, "%s\n",line);
	if (code_pointer == NULL) {
	    code_pointer = MALLOC(gen_ll_mgr);
	    code_pointer->head = NULL;
	    code_pointer->tail = NULL;
	}
	if (code_pointer->head == NULL) {
	    code_pointer->head = MALLOC(gen_ll);
	    code_pointer->head->next = NULL;
	    code_pointer->head->prev = NULL;
	    code_pointer->tail = code_pointer->head;
	}
	else {
	    code_pointer->tail->next = MALLOC(gen_ll);
	    code_pointer->tail->next->prev = code_pointer->tail;
	    code_pointer->tail = code_pointer->tail->next;
	}
	
	code_pointer->tail->ll_type = CODE_POINTER;
	code_pointer->tail->item = (ll_generic *)NMALLOC(strlen(line)+1,char);
	strcpy(((char *)code_pointer->tail->item), line);
	code_pointer->tail->line_count = nl_count;
	
	code_pointer->tail->next = NULL;
	sprintf(line,"%s", "");

	if (subst) {
	    code_pointer->tail->next = MALLOC(gen_ll);
	    code_pointer->tail->next->prev = code_pointer->tail;
	    code_pointer->tail = code_pointer->tail->next;

	    len = strlen(str);
	    /*
	     * First check to see if it is a `define.  If it is,
	     * then we DON'T convert it.  Otherwise, we do convert it.
	     */
	    if ((np = lookup_define(Defines_Table, str+1,hash(str+1)))) {
		if (expand_define) {
		    code_pointer->tail->ll_type = CODE_POINTER;
		    code_pointer->tail->item =
		      (ll_generic *)NMALLOC(strlen(np->macro)+1,char);
		    strcpy(((char *)code_pointer->tail->item),np->macro);
		}
		else {
		    code_pointer->tail->ll_type = CODE_POINTER;
		    code_pointer->tail->item =
		      (ll_generic *)NMALLOC(len+1,char);
		    strcpy(((char*)code_pointer->tail->item), str);
		}
	    }
	    else {
		code_pointer->tail->ll_type = CODE_POINTER2;
		code_pointer->tail->item =
		  (ll_generic *)NMALLOC(len,char); /* note no +1 */
		strcpy(((char *)code_pointer->tail->item), str+1);
	    }
	    code_pointer->tail->line_count = nl_count;
	    code_pointer->tail->next = NULL;
	}
    }
}


/**************************************************************************
 *
 * Function Name : int store_define()
 * Parameters :
 *	char *def_text - text of the define statement
 * Purpose :
 *    To add a "`define" into the table.  Note that if a previous entry
 * already exists, it is first removed, and then the new entry superceeds
 * the old one.
 *
 **************************************************************************/
void
store_define(char *def_text)
{
    char *txt_ptr, *ptr, *end;
    char macro_name[MAXSTR], parms[MAXSTR];
    int i, hashval;

    string s = def_text;
    strcpy(def_text, s.substr(s.find_first_not_of(" \t")).c_str() );

    ptr = def_text + 7; /* There is no white space before the directive. */
    ptr += strspn(ptr, " \t");
    end = def_text + strlen(def_text);
    i = 0;
    while (ptr < end) {
	if (*ptr == ' ' || *ptr == '\t' || *ptr == '\n' || *ptr == '(')
	    break;
	macro_name[i++] = *ptr++;
    }
    macro_name[i] = '\0';
    i = 0;
    if (*ptr == '(') {
	while (*ptr != ')')
	    parms[i++] = *ptr++;
	parms[i++] = *ptr++; /* Copy close parenthesis too. */
    }
    parms[i] = '\0';
    txt_ptr = ptr;
    while (*txt_ptr == ' ' || *txt_ptr == '\t') ++txt_ptr;

    hashval = hash(macro_name);

    /*
     * First, see if the name has previously been stored.
     */
    if (lookup_define(Defines_Table, macro_name, hashval) != NULL) {
	fprintf(stderr, "WARNING : `%s' redefined\n", macro_name);
	delete_entry(Defines_Table, macro_name, hashval);
    }
    /*
     * Now, store the name and macro into the table.
     */
    add_macro(Defines_Table, macro_name, hashval, txt_ptr, parms);
}


/**************************************************************************
 *
 * Function Name : int hash()
 * Parameters :
 *	char *text - text you wish to get hash value of
 * Purpose :
 *	This routine sums up the ascii value of the text, mod a BASE value,
 * and returns this value as the hash value.
 *
 **************************************************************************/
int
hash(char *text)
{
    int i, sum = 0;
    for(i=0; text[i] != '\0'; i++) sum += text[i];
    
    return (sum % BASE);

}

/**************************************************************************
 *
 * Function Name : names *lookup_define()
 * Parameters :
 *	names *table[] - table where names are to be stored in
 *	char *macro_name - name to lookup
 *	int hashval - computed hash value;
 * Return Value :
 *	names * -  NULL if not found, address of a 'names' if found
 * Purpose :
 *    See if the name given is defined in the table.  To make for quick
 * searches, the entries are hashed into a linked list table.
 *
 **************************************************************************/
names *
lookup_define(names *table[], char *macro_name, int hashval)
{
    names *np;

    for (np = table[hashval]; np != NULL; np=np->next) {
	if (strcmp(macro_name,np->macro_name) == 0) return(np);
    }
    return(NULL);
}

/**************************************************************************
 *
 * Function Name : int delete_entry()
 * Parameters :
 *	names *table[] - table where names are to be stored in
 *	char *macro_name - name to delete
 *	int hashval - computed hash value;
 * Return Value :
 *	none
 * Purpose :
 *    To delete an entry in a hash'd database.	We may wish to delete
 * a macro for example if we come across a duplicate identical macro def,
 * then the newest one replaces the current one.  Note that this routine
 * simply deletes the entry from the table.  It is up to the user to add
 * a new name, if desired.
 *
 **************************************************************************/
int
delete_entry(names *table[], char *macro_name, int hashval)
{
    names *np;
    names *last_np;

    for (last_np = np = table[hashval]; np != NULL; np=np->next) {
	if (strcmp(macro_name,np->macro_name) == 0) {
	   // if (last_np == table[hashval]) table[hashval] = np->next;
	    if (np == table[hashval] ) table[hashval] = np->next;
	    else last_np->next = np->next;
	    free(np->macro_name);
	    free(np->macro);
	    free(np);
	    return(1);
	}
	last_np = np;
    }
    return(0);
}

int
find_expr(char *word, char *text, int len, int *idx)
{
    int i, j, offset;

    offset = *idx;
    if (text[offset] == '(') ++offset;
    while (text[offset] == ' ' || text[offset] == '\t') ++offset;
    for (i = 0, j = offset; j < len; ++i, ++j) {
	if (text[j] == ',' || text[j] == ')') {
	    ++j;
	    break;
	}
	word[i] = text[j];
    }
    word[i] = '\0';

    *idx = j;
    return word[0] == '\0' ? -1 : offset;
}

/**************************************************************************
 *
 * Function Name : int add_macro()
 * Parameters :
 *	names *table[] - table where names are to be stored in
 *	char *macro_name - name to store macro as
 *	int hashval - computed hash value;
 *	char *text - pointer to an actual copy of macro corresponding to
 *		     macro_name
 * Return Value :
 *	none
 * Purpose :
 *    To add a macro definition into a hash'd database.
 *
 **************************************************************************/
void
add_macro(names *table[], char *macro_name, int hashval, char *text, char *parms)
{
    names *table_ptr;
    macro_parms *parms_ptr;
    char name[MAXSTR];
    int i, len;

    table_ptr = table[hashval];
    /*
     * First, check for "//" and "/", "*" because comments are legal in a
     * define statement, but should not be included into the expansion
     */
    for (i=0; text[i] != '\0'; i++) {
	if (text[i] == '/') {
	    if (text[i+1] != '\0') {
		if ((text[i+1] == '/') || (text[i+1] == '*')) {
		    text[i] = '\0';
		    break;
		}
	    }
	}
    }
    /*
     * Clear trailing whitespace left behind by comment(s) above.
     */
    for (i--; i >= 0; i--) {
	if (text[i] == ' ' || text[i] == '\t') {
	    text[i] = '\0';
	}
	else {
	    break;
	}
    }
    /*
     * If we are at the head of the index, insert there.
     */
    if (table_ptr == NULL) {
	table[hashval] = table_ptr = MALLOC(names);
    }
    /*
     * search to the end of the linked list and insert there
     */
    else {
	while (table_ptr->next != NULL) table_ptr = table_ptr->next;
	table_ptr->next = MALLOC(names);
	table_ptr = table_ptr->next;
    }
    table_ptr->next = NULL;
    table_ptr->macro_name = NMALLOC(strlen(macro_name)+1,char);
    strcpy(table_ptr->macro_name, macro_name);
    table_ptr->macro = NMALLOC(strlen(text)+1,char);
    strcpy(table_ptr->macro, text);
    table_ptr->parms = parms_ptr = 0;
    if (parms[0] != '\0') {
	i = 0;
	len = strlen(parms);
	while (find_expr(name, parms, len, &i) != -1) {
	    if (table_ptr->parms == 0) {
		parms_ptr = CALLOC(1,macro_parms);
		table_ptr->parms = parms_ptr;
	    }
	    else {
		parms_ptr->next = CALLOC(1,macro_parms);
		parms_ptr = parms_ptr->next;
	    }
	    strcpy(parms_ptr->name, name);
	}
    }
    table_ptr->is_number = ascii2double(table_ptr->macro,&(table_ptr->value));

}

void
print_double(double value)
{
    int tmp;
 
    if (is_an_integer(value)) {
	tmp = (int) round_int(value);
	fprintf(yyout, "%d",tmp);
    }
    else {
	fprintf(yyout, "%f",value);
    }
}

int
set_macro_values(macro_parms *pp, char *text)
{
    int i, len;
    char value[MAXSTR];

    if (pp == 0) {
	if (text != 0 && text[0] != '\0') return -1;
	return 0; /* No parameters for this macro. */
    }
    else {
	if (text == 0) return -1;
    }

    i = 0;
    len = strlen(text);
    while (find_expr(value, text, len, &i) != -1 && pp != 0) {
	pp->value = NMALLOC(strlen(value)+1, char);
	strcpy(pp->value, value);
	pp = pp->next;
    }

    if ((pp != 0 && i >= len) || (pp == 0 && i < len))
	return -1;
    return 0;
}

void
find_macro_values(macro_parms *pp, char *value)
{
    while (pp != 0) {
	if (strcmp(pp->name, value) == 0) {
	    strcpy(value, pp->value);
	    break;
	}
	pp = pp->next;
    }
}

void
clear_macro_values(macro_parms *pp)
{
    while (pp != 0) {
	free(pp->value);
	pp->value = 0;
	pp = pp->next;
    }
}

int
find_word(char *word, char *text, int len, int *idx)
{
    int i, j, offset;

    for (offset = *idx; offset < len; ++offset) {
	if (isalpha(text[offset])) break;
    }
    for (i = 0, j = offset; j < len; ++i, ++j) {
	if (isalpha(text[j])) word[i] = text[j];
	else break;
    }
    word[i] = '\0';

    *idx = j;
    return word[0] == '\0' ? -1 : offset;
}

/*************************************************************
 * get macro value
 *
 * ************************************************************/
string 
get_macro_value(char *name) 
{
   ostringstream buf; 

   // same as print_variable
   names *np;
   var_values *vvp;
   char strg[MAXSTR], *tmp;
   double dval;
   int i, j, len, offset;

   strcpy(strg, name);
   tmp = strpbrk(name, "(");
   if (tmp != 0)
      strg[tmp-name] = '\0';
   np = lookup_define(Defines_Table, strg, hash(strg));
   if (np != 0) {
      if (set_macro_values(np->parms, tmp) < 0) {
	 fprintf(stderr,"ERROR : wrong number of parameters for `%s\n",np->macro_name);
	 exit(1);
      }
      len = strlen(np->macro);
      i = j = 0;
      offset = find_word(strg, np->macro, len, &i);
      while (offset != -1) {
	 for (; j < offset; ++j) {
	    if (np->macro[j] == '\\' && np->macro[j+1] == '\n')
	       continue; /* Discard escaped newline. */
	    /* putchar(np->macro[j]); */
	    // fprintf(yyout, "%c", np->macro[j]);
	    buf << np->macro[j];
	 }
	 find_macro_values(np->parms, strg);
	 // fprintf(yyout, "%s", strg);
	 buf << strg;
	 j = i; /* Jump over values. */
	 offset = find_word(strg, np->macro, len, &i);
      }
      /* Output the rest of the macro text. */
      for (; j < len; ++j) {
	 if (np->macro[j] == '\\' && np->macro[j+1] == '\n')
	    continue; /* Discard escaped newline. */
	 /* putchar(np->macro[j]); */
	 // fprintf(yyout, "%c", np->macro[j]);
	 buf << np->macro[j];
      }
      clear_macro_values(np->parms);
   }
   else if (is_keyword(name)) {
      // fprintf(yyout, "`%s",name);
      buf << name;
   }
   else {
//       cerr << endl;
//       for ( int xx = 0; xx<BASE; xx++) 
// 	 if ( Defines_Table[xx] ) cerr << Defines_Table[xx]->macro_name << endl;
//       cerr << endl;

      vvp = get_variable_ref(STRING,name);
      if (vvp == NULL) {
	 sprintf(strg,"get_macro_value: ERROR : `%s' not defined",name);
	 yyerror(strg);
      }
      else {
	 if ((vvp->strg)[0] == '"') {
	    for (i=1;i<strlen(vvp->strg);i++) {
	       if ((vvp->strg)[i] == '"') break;
	       else {
		  // fprintf(yyout, "%c",(vvp->strg)[i]);
		  buf << (vvp->strg)[i];
	       }
	    }
	 }
	 else {
	    ascii2double(vvp->strg,&dval);
	    print_double(dval);
	 }
      }
   }

   return buf.str();
}






/**************************************************************************
 *
 * Function Name :
 * Parameters :
 * Return Value :
 * Purpose :
 *
 **************************************************************************/
void
print_variable(char *name, int expand_define)
{
    names *np;
    var_values *vvp;
    char strg[MAXSTR], *tmp;
    double dval;
    int i, j, len, offset;

    strcpy(strg, name);
    tmp = strpbrk(name, "(");
    if (tmp != 0)
	strg[tmp-name] = '\0';
    np = lookup_define(Defines_Table, strg, hash(strg));
    if (np != 0) {
	if (expand_define) {
	    if (set_macro_values(np->parms, tmp) < 0) {
		fprintf(stderr,"ERROR : wrong number of parameters for `%s\n",np->macro_name);
		exit(1);
		return;
	    }
	    len = strlen(np->macro);
	    i = j = 0;
	    offset = find_word(strg, np->macro, len, &i);
	    while (offset != -1) {
		for (; j < offset; ++j) {
		    if (np->macro[j] == '\\' && np->macro[j+1] == '\n')
			continue; /* Discard escaped newline. */
		    /* putchar(np->macro[j]); */
		    fprintf(yyout, "%c", np->macro[j]);
		}
		find_macro_values(np->parms, strg);
		fprintf(yyout, "%s", strg);
		j = i; /* Jump over values. */
		offset = find_word(strg, np->macro, len, &i);
	    }
	    /* Output the rest of the macro text. */
	    for (; j < len; ++j) {
		if (np->macro[j] == '\\' && np->macro[j+1] == '\n')
		    continue; /* Discard escaped newline. */
		/* putchar(np->macro[j]); */
		fprintf(yyout, "%c", np->macro[j]);
	    }
	    clear_macro_values(np->parms);
	}
	else fprintf(yyout, "`%s",name);
    }
    else if (is_keyword(name)) fprintf(yyout, "`%s",name);
    else {
	vvp = get_variable_ref(STRING,name);
	if (vvp == NULL) {
	    sprintf(strg,"ERROR : `%s' not defined",name);
	    yyerror(strg);
	}
	else {
	    if ((vvp->strg)[0] == '"') {
		for (i=1;i<strlen(vvp->strg);i++) {
		    if ((vvp->strg)[i] == '"') break;
		    else fprintf(yyout, "%c",(vvp->strg)[i]);
		}
	    }
	    else {
		ascii2double(vvp->strg,&dval);
		print_double(dval);
	    }
	}
    }
}

/**************************************************************************
 *
 * Function Name :
 * Parameters :
 *    none
 * Return Value :
 * Purpose :
 *
 **************************************************************************/
void
store_lines()
{
    if (strcmp(yytext,"\n") == 0) {
	strcpy(old_line,current_line);
	strcpy(current_line, "");
    }
    else {
	int len = strlen(current_line) + strlen(yytext);
	if (len > MAXNAME)
	    yyerror("line too long");
	else
	    strcat(current_line, yytext);
    }
}

/**************************************************************************
 *
 * Function Name :
 * Parameters :
 * Return Value :
 * Purpose :
 *
 **************************************************************************/
void
do_comment_count(int force_print, int count)
{

   // if (((nl_count % COMMENT_EVERY) == 0 || force_print) &&
    if (force_print && output_line_directive) {
	fprintf(yyout, "`line %d \"%s\"\n", count, current_file);
    }
}

/**************************************************************************
 *
 * Function Name :
 * Parameters :
 * Return Value :
 * Purpose :
 *    Given a text followed by either ++ or --, we expand it to 
 * "name = name+1" or "name = name-1".	Note that we unput into the
 * parse stream, so that parsing occurs on the expanded text.
 *
 **************************************************************************/
void
do_post_command(char *txt, int post_type)
{
    int i;
    int len;
    char tmp[MAXSTR];

    strcpy(tmp, txt);

    len = strlen(tmp);

    if ((post_type == PP) || (post_type == MM)) {
	unput('1');
    }
    if ((post_type == MM) || (post_type == ME)) {
	unput('-');
    }
    else {
	unput('+');
    }
    for (i=(len-3);i>=0;i--){
	unput(tmp[i]);
    }
    unput('=');
    for (i=(len-3);i>=0;i--) {
	unput(tmp[i]);
    }
}


/**************************************************************************
 *
 * Function Name :
 * Parameters :
 * Return Value :
 * Purpose :
 *
 **************************************************************************/
int
get_define_value(char *name, double *dval)
{
    names *np;

    if ((np=lookup_define(Defines_Table,name,hash(name)))) {
	*dval = np->value;
	return 0;
    }

    return -1;
}

/**************************************************************************
 *
 * Function Name :
 * Parameters :
 * Return Value :
 * Purpose :
 *
 **************************************************************************/
int
is_keyword(char *name)
{
  if (strcmp(name,"ifdef") == 0) return (TRUE);
  else if (strcmp(name,"ifndef") == 0) return (TRUE);
  else if (strcmp(name,"if") == 0) return (TRUE);
  else if (strcmp(name,"let") == 0) return (TRUE);
  else if (strcmp(name,"for") == 0) return (TRUE);
  else if (strcmp(name,"while") == 0) return (TRUE);
  else if (strcmp(name,"switch") == 0) return (TRUE);
  else if (strcmp(name,"case") == 0) return (TRUE);
  else if (strcmp(name,"default") == 0) return (TRUE);
  else if (strcmp(name,"breaksw") == 0) return (TRUE);
  else if (strcmp(name,"else") == 0) return (TRUE);
  else if (strcmp(name,"endif") == 0) return (TRUE);
  else if (strcmp(name,"endwhile") == 0) return (TRUE);
  else if (strcmp(name,"endswitch") == 0) return (TRUE);
  else if (strcmp(name,"define") == 0) return (TRUE);

  return (FALSE);
}

/**************************************************************************
 *
 * Function Name : int undef_macro(def_text)
 * Parameters :
 *     char *def_text - text of the macro to undefine
 * Return Value :
 * Purpose :
 *     This function exists to undefine a macro, if it so exists.  Note
 * that no warning message is given if the macro does not exist.
 *
 **************************************************************************/
void
undef_macro(char *def_text)
{
    char *txt_ptr;
    char macro_name[MAXSTR];
    int hashval;

    // txt_ptr = (char *) (((int)strstr(def_text, "undef")) + ((int)strlen("undef")));
    txt_ptr = (char *) (strstr(def_text, "undef") + strlen("undef"));
    sscanf(txt_ptr, "%s", macro_name);

    hashval = hash(macro_name);

    /*
     * First, see if the name has previously been stored.
     */
    if (lookup_define(Defines_Table, macro_name, hashval) != NULL) {
	delete_entry(Defines_Table, macro_name, hashval);
    }
}

void
set_to_vpp_mode()
{
    last_mode = YY_START;
    BEGIN(MPP);
}

void
set_to_initial_mode()
{
    last_mode = YY_START;
    BEGIN(INITIAL);
}

void
set_to_copy()
{
    last_mode = YY_START;
    BEGIN(COPY);
}

void
set_to_last_mode()
{
    BEGIN(last_mode);
}

/**************************************************************************
 *
 * Function Name : ReportDefines
 * Parameters :
 * Return Value :
 * Purpose :
 *
 **************************************************************************/
void 
ReportDefines(ostream &o)
{
  o << endl
    << "===============================================" << endl
    << "   Defines Table" << endl
    << "===============================================" << endl;
  names *macro_entries;
  macro_parms *parameters;
  for (int i=0; i<BASE; i++) {
    if (macro_entries = Defines_Table[i]) {
      do { 
	o << "Macro Name: " << Defines_Table[i]->macro_name << endl
	  << "Macro Body: " << Defines_Table[i]->macro << endl
	  << " Is Number: " << Defines_Table[i]->is_number << endl
	  << "     Value: " << Defines_Table[i]->value << endl;

	if ( parameters = Defines_Table[i]->parms ) {
	  do {
	    o << "Parameters: " 
	      << parameters->name 
	      << " = "  
	      << parameters->value << endl;
	  }
	  while (parameters = parameters->next);
	}
	o << endl;
      }
      while (macro_entries = macro_entries->next);
    }
  }
}
