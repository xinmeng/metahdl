%output = "vpp.bison.cc"
%defines

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

/*
 * $Header: /cvsroot/mhdlc/src/vpp.y,v 1.1.1.1 2008-03-11 06:46:47 mengx Exp $
 * Program :
 * Author : Himanshu M. Thaker
 * Date : Apr. 18, 1995
 * Description :
 * $Log: vpp.y,v $
 * Revision 1.1.1.1  2008-03-11 06:46:47  mengx
 * all in one
 *
 * Revision 1.1.1.1  2008-02-17 15:05:46  mengx
 *  Create entire repository for MetaHDL
 *
 * Revision 1.1.1.1  2008-02-14 03:23:11  mengx
 * create
 *
 * Revision 1.1.1.1  2008-02-14 02:31:06  mengx
 * Create
 *
 *
 * Revision 1.5  2004-02-15 08:25:42  jching
 * Detect missing end declaration statements at EOF.
 *
 * Revision 1.4  2002/01/28 10:04:43  jching
 * Stop parsing after 100 parse errors.
 *
 * Revision 1.3  2002/01/27 09:51:25  jching
 * Do not output comment starters.  That is done in lexor.
 *
 * Revision 1.2  2001/01/25 07:38:03  jching
 * Return non-zero when parsing error detected.
 *
 * Revision 1.1.1.1  2000/02/21 04:05:37  ahvezda
 * Import of vbpp
 *
 * Revision 1.8  1996/07/18  02:53:03  hmthaker
 * Initial revision
 *
 * Revision 1.7  1995/04/23  17:18:12  hemi
 * All features except string handling.
 */

#include <stdio.h>
#include "common.h"
#include "yacc_stuff.h"
#include "proto.h"

char ttid[MAXNAME];
var_list *head_table = NULL;
var_values *head_variable_list = NULL;
gen_ll *cstack = NULL;
extern gen_ll_mgr *code_pointer;
extern FILE *yyout;
int loop_struct_count = 0;
int yyerror_count;

varp *vp1;

%}

%union {
    int   ival;			/* integer value */
    char  *cp;			/* character pointer */
    expr  *ep;			/* expression pointer */
    varp  *vp;			/* variable identifier pointer */
}


%token TTIF
%token TTIFDEF
%token TTIFNDEF
%token TTELSE
%token TTENDIF
%token TTFOR
%token TTENDFOR
%token TTLET
%token TTWHILE
%token TTENDWHILE
%token TTSWITCH
%token TTCASE
%token TTDEFAULT
%token TTBREAKSW
%token TTENDSWITCH
%token TTID
%token TTNUM
%token TTREALNUM
%token TTQS
%token TTNAME
%token TTWHITE
%token TTL_EQ
%token TTL_NEQ
%token TTL_AND
%token TTL_OR
%token TTL_LEQ
%token TTL_SHIFTR
%token TTL_SHIFTL
%token TT_POWER
%token TT_UNKNOWN
%token TTLOG2
%token TTROUND
%token TTCEIL
%token TTFLOOR
%token TTEVEN
%token TTODD
%token TTMAX
%token TTMIN
%token TTABS
%token TTSTOI
%token TTITOS
%token TTSUBSTR
%token TTSYSTEM
%token TTCOMMENT
%token TTCOMMENT2

%nonassoc '<' '>'
%left TTL_EQ TTL_GEQ TTL_LEQ TTL_NEQ
%left TTL_OR
%left TTL_AND
%left TTL_XNOR
%left TTL_NAND
%left TTL_NOR
%left TTL_XOR
%left '+' '-'
%left '*' '/' '%'
%left TT_POWER
%left TTL_SHIFTL TTL_SHIFTR
%left '|' '&' '^'
%left '(' ')'
%right  '~' '!'
%right UNARY

%type <ep> expression primary
%type <cp> identifier

%%
source_text : /* empty */
	| source_text if_declaration
	| source_text ifdef_declaration
	| source_text ifndef_declaration
	| source_text else_declaration
	| source_text endif_declaration
	| source_text for_declaration
	| source_text endfor_declaration
	| source_text while_declaration
	| source_text endwhile_declaration
	| source_text switch_declaration
	| source_text case_declaration
	| source_text breaksw_declaration
	| source_text default_declaration
	| source_text endswitch_declaration
	| source_text let_declaration
	| source_text other_stuff
	| source_text error {
	    set_to_last_mode();
	    yyclearin;
	    yyerrok;
	  }
	;

other_stuff : TTNAME {fprintf(yyout, "%s", ttid);}
	| TTNUM {fprintf(yyout, "%s", ttid);}
	| TTREALNUM {fprintf(yyout, "%s", ttid);}
	| TTWHITE {fprintf(yyout, "%s", ttid);}
	;

switch_declaration : TTSWITCH {set_to_vpp_mode();} expression '\n'
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    cstack = push(cstack,
				  create_generic_ll(SWITCH_STRUCTURE, NULL,
						    create_switch_structure($3)
						    )
				  );
		    loop_struct_count++;
		    set_to_copy();
		}
	;

case_declaration : TTCASE {set_to_vpp_mode();} expression optional_colon '\n'
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    if (cstack != NULL) {
		      cstack = push(cstack, create_generic_ll(CASE_STRUCTURE,NULL,
							    create_case_structure($3))
				  );
		      set_to_last_mode();
		    }
 		    else {
		      fprintf(stderr,"ERROR : got default without matching switch!!!\n");
		      exit(1);
		      set_to_initial_mode();
		    }
		}
	;

optional_colon : /* empty */
	| ':'
	;

default_declaration : TTDEFAULT {set_to_vpp_mode();} optional_colon vpp_line_termination
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    if (cstack != NULL) {
		      cstack = push(cstack, create_generic_ll(DEFAULT_STRUCTURE,NULL,
							    NULL)
				  );
		      set_to_last_mode();
		    }
 		    else {
		      fprintf(stderr,"ERROR : got default without matching switch!!!\n");
		      exit(1);
		      set_to_initial_mode();
		    }
		}
	;

breaksw_declaration : TTBREAKSW {set_to_vpp_mode();} vpp_line_termination
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    if (cstack != NULL) {
		      cstack = push(cstack, create_generic_ll(BREAKSW_STRUCTURE,NULL,
							    NULL)
				  );
		      set_to_last_mode();
		    }
 		    else {
		      fprintf(stderr,"ERROR : got breaksw without matching switch!!!\n");
		      exit(1);
		      set_to_initial_mode();
		    }
		}
	;

endswitch_declaration : TTENDSWITCH {set_to_vpp_mode();} vpp_line_termination_opt
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    if (cstack != NULL)
		      cstack = push(cstack, create_generic_ll(ENDSWITCH_STRUCTURE,NULL,
							    NULL)
				  );
 		    else {
		      fprintf(stderr,"ERROR : got an endswitch without matching switch!!!\n");
		      exit(1);
		    }
		    if (loop_struct_count != 0) {
			loop_struct_count--;
			if (loop_struct_count == 0) {
			  eval_stack(cstack);
			  cstack = NULL;
			  set_to_initial_mode();
		        }
		    else set_to_last_mode();
		    }
		    if (cstack == NULL) set_to_initial_mode();
		}
        ;

while_declaration : TTWHILE {set_to_vpp_mode();} expression vpp_line_termination
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    cstack = push(cstack,
				  create_generic_ll(WHILE_STRUCTURE, NULL,
						    create_while_structure($3)
						    )
				  );
		    loop_struct_count++;
		    set_to_copy();
		}
	;

for_declaration : TTFOR {set_to_vpp_mode();}
		   '(' identifier '=' expression
		{
		    vp1 = create_variable_ref($4,$6,TRUE);
		    free($4); /* create_variable_ref duplicates the name */
		}
		   ';' expression ';' identifier '=' expression ')' vpp_line_termination
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;

		    cstack = push(cstack,
				  create_generic_ll(FOR_STRUCTURE, NULL,
						    create_for_structure(vp1,$9,$11,$13)
						    )
				  );
		    loop_struct_count++;
		    set_to_copy();
		}
	;

endfor_declaration : TTENDFOR {set_to_last_mode();} vpp_line_termination_opt
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    if (cstack != NULL)
		      cstack = push(cstack, create_generic_ll(ENDFOR_STRUCTURE,NULL,
							    NULL)
				  );
 		    else {
                        yyerror("Error: got an endfor without matching for!!!\n");
                        // fprintf(stderr, "Error: got an endfor without matching for!!!\n");
		      exit(1);
		    }
		    

		    if (loop_struct_count != 0) {
			loop_struct_count--;
			if (loop_struct_count == 0) {
			  eval_stack(cstack);
			  cstack = NULL;
			  set_to_initial_mode();
		        }
		    else set_to_last_mode();
		    }
		    if (cstack == NULL) set_to_initial_mode();
		}
	;

endwhile_declaration : TTENDWHILE {set_to_vpp_mode();} vpp_line_termination_opt
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    if (cstack != NULL)
		      cstack = push(cstack, create_generic_ll(ENDWHILE_STRUCTURE,NULL,
							    NULL)
				  );
		    else {
		      fprintf(stderr,"ERROR : got an endwhile without matching while!!!\n");
		      exit(1);
		    }

		    if (loop_struct_count != 0) {
			loop_struct_count--;
			if (loop_struct_count == 0) {
			  eval_stack(cstack);
			  cstack = NULL;
			  set_to_initial_mode();
		        }
		    else set_to_last_mode();
		    }
		    if (cstack == NULL) set_to_initial_mode();
		}
	;

if_declaration : TTIF {set_to_vpp_mode();} expression vpp_line_termination
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    cstack = push(cstack,
				  create_generic_ll(IF_STRUCTURE, NULL,
						    create_if_structure($3)
						    )
				  );
		    loop_struct_count++;
		    set_to_copy();
		}
	;

ifdef_declaration : TTIFDEF {set_to_vpp_mode();} expression vpp_line_termination
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    cstack = push(cstack,
				  create_generic_ll(IFDEF_STRUCTURE, NULL,
						    create_if_structure($3)
						    )
				  );
		    loop_struct_count++;
		    set_to_copy();
		}
	;

ifndef_declaration : TTIFNDEF {set_to_vpp_mode();} expression vpp_line_termination
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    cstack = push(cstack,
				  create_generic_ll(IFNDEF_STRUCTURE, NULL,
						    create_if_structure($3)
						    )
				  );
		    loop_struct_count++;
		    set_to_copy();
		}
	;

else_declaration : TTELSE {set_to_vpp_mode();} vpp_line_termination
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    if (cstack != NULL)
		      cstack = push(cstack, create_generic_ll(ELSE_STRUCTURE,NULL,
							    NULL)
				  );
		    else {
		      fprintf(stderr,"ERROR : got an else without matching if!!!\n");
		      exit(1);
		    }
		    set_to_last_mode();
		}
	;

endif_declaration : TTENDIF {set_to_vpp_mode();} vpp_line_termination_opt
		{
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
							      code_pointer)
				    );
		    code_pointer = NULL;
		    if (cstack != NULL)
		      cstack = push(cstack, create_generic_ll(ENDIF_STRUCTURE,NULL,
					    NULL)
				    );
 		    else {
		      fprintf(stderr,"ERROR : got an endif without matching if!!!\n");
		      exit(1);
		    }
		    if (loop_struct_count != 0) {
			loop_struct_count--;
			if (loop_struct_count == 0) {
			  eval_stack(cstack);
			  cstack = NULL;
			  set_to_initial_mode();
		        }
		    else set_to_last_mode();
		    }
		    if (cstack == NULL) set_to_initial_mode();
		}
        ;

vpp_line_termination_opt : /* empty */
	| vpp_line_termination
	;

vpp_line_termination : '\n'
	| TTCOMMENT
	| TTCOMMENT2
	;

let_declaration : TTLET {set_to_vpp_mode();}
		   identifier '=' expression optional_semi vpp_line_termination_opt
		{
		  if (loop_struct_count > 0) {
		    if (code_pointer != NULL)
		      cstack = push(cstack, create_generic_ll(CODE_POINTER,NULL,
			    		      code_pointer)
				   );
		    code_pointer = NULL;
		    cstack = push(cstack, create_generic_ll(LET_STRUCTURE,NULL,
							  create_variable_ref($3,$5,FALSE))
			         );
		    free($3); /* create_variable_ref duplicates the name */
		  }
		  else {
		    create_variable_ref($3,$5, TRUE);
		  }
		  set_to_last_mode();
		}
	;

optional_semi : /* empty */
	| ';'
	;

expression : primary {$$ = $1;}
	/*
	 * unary operators ...
	 *	+ - ! ~ & ~& | ^| ^  ~^
	 */
	| '+' primary %prec UNARY {$$ = create_expression(UPLUS,$2,NULL,NULL);}
	| '-' primary %prec UNARY {$$ = create_expression(UMINUS,$2,NULL,NULL);}
	| '!' primary %prec UNARY {$$ = create_expression(UNOT,$2,NULL,NULL);}
	| '~' primary %prec UNARY {$$ = create_expression(UTILDA,$2,NULL,NULL);}
	| '&' primary %prec UNARY {$$ = create_expression(UAND,$2,NULL,NULL);}
	| TTL_NAND primary %prec UNARY {$$ = create_expression(UNAND,$2,NULL,NULL);}
	| TTL_NOR primary %prec UNARY /* +++ lrm : NOTE not in lrm */ {$$ = create_expression(UNOR,$2,NULL,NULL);}
	| '|' primary %prec UNARY {$$ = create_expression(UPIPE,$2,NULL,NULL);}
	| '^' primary %prec UNARY {$$ = create_expression(UCARAT,$2,NULL,NULL);}
	| TTL_XNOR primary %prec UNARY {$$ = create_expression(UXNOR,$2,NULL,NULL);}
	/*
 	 * binary operators ...
	 *	+ - * / % == != && || < <= > >= & | ^ >> <<
 	 */
	| expression '+' expression {$$ = create_expression(ADD,$1,$3,NULL);}
	| expression '-' expression {$$ = create_expression(SUB,$1,$3,NULL);}
	| expression '*' expression {$$ = create_expression(MULT,$1,$3,NULL);}
	| expression '/' expression {$$ = create_expression(DIV,$1,$3,NULL);}
	| expression '%' expression {$$ = create_expression(MOD,$1,$3,NULL);}
	| expression TTL_EQ expression {$$ = create_expression(EQ,$1,$3,NULL);}
	| expression TTL_NEQ expression {$$ = create_expression(NEQ,$1,$3,NULL);}
	| expression TTL_AND expression {$$ = create_expression(AND,$1,$3,NULL);}
	| expression TTL_OR expression {$$ = create_expression(OR,$1,$3,NULL);}
	| expression '<' expression {$$ = create_expression(LT,$1,$3,NULL);}
	| expression TTL_LEQ expression {$$ = create_expression(LEQ,$1,$3,NULL);}
	| expression '>' expression {$$ = create_expression(GT,$1,$3,NULL);}
	| expression TTL_GEQ expression {$$ = create_expression(GEQ,$1,$3,NULL);}
	| expression '&' expression {$$ = create_expression(BITAND,$1,$3,NULL);}
	| expression '|' expression {$$ = create_expression(BITOR,$1,$3,NULL);}
	| expression '^' expression {$$ = create_expression(BITXOR,$1,$3,NULL);}
	| expression TTL_SHIFTR expression {$$ = create_expression(SHIFTR,$1,$3,NULL);}
	| expression TTL_SHIFTL expression {$$ = create_expression(SHIFTL,$1,$3,NULL);}
	| expression TT_POWER expression {$$ = create_expression(POWER,$1,$3,NULL);}
	| TTLOG2 '(' expression ')' {$$ = create_expression(LOG2,$3,NULL,NULL);}
	| TTROUND '(' expression ')' {$$ = create_expression(ROUND,$3,NULL,NULL);}
	| TTCEIL '(' expression ')' {$$ = create_expression(CEIL,$3,NULL,NULL);}
	| TTFLOOR '(' expression ')' {$$ = create_expression(FLOOR,$3,NULL,NULL);}
	| TTEVEN '(' expression ')' {$$ = create_expression(EVEN,$3,NULL,NULL);}
	| TTODD '(' expression ')' {$$ = create_expression(ODD,$3,NULL,NULL);}
	| TTMAX '(' expression ',' expression ')' {$$ = create_expression(MAX,$3,$5,NULL);}
	| TTMIN '(' expression ',' expression ')' {$$ = create_expression(MIN,$3,$5,NULL);}
	| TTABS '(' expression ')' {$$ = create_expression(ABS,$3,NULL,NULL);}
	| TTSTOI '(' expression ')' {$$ = create_expression(STOI,$3,NULL,NULL);}
	| TTITOS '(' expression ',' expression ')' {$$ = create_expression(ITOS,$3,$5,NULL);}
	| TTSUBSTR '(' expression ',' expression ',' expression ')' {$$ = create_expression(SUBSTR,$3,$5,$7);}
	| TTSYSTEM '(' expression ')' {$$ = create_expression(SYSTEM,$3,NULL,NULL);}
	;

primary : TTNUM
		{$$ = create_primary(NMBR,ttid,NULL,NULL,NULL);}
	| TTREALNUM
		{$$ = create_primary(REAL,ttid,NULL,NULL,NULL);}
	| TTNAME
		{$$ = create_primary(STRING,ttid,NULL,NULL,NULL);}
	| TTQS {
	    	  $$ = create_primary(QUOTED_STRING,ttid,NULL,NULL,NULL);
	       }
	| '(' expression ')' {$$ = $2;}
	;

identifier : TTNAME
		{
		$$ = (char *) malloc(strlen(ttid) + 1);
		strcpy($$, ttid);
		}
	;

/**********************************************************************
 *
 * end of included from previous yacc..
 *
 **********************************************************************/
%%

void
yyerror(char *s)
{
    int len_tok; /* length of yytext */
    int len_line; /* length of current line */
    int i;

    fprintf(stderr,"%5d:%s\n",nl_count-1,old_line);
    fprintf(stderr,"%5d:%s\n",nl_count,current_line);
    len_tok = strlen(yytext);
    len_line = strlen(current_line);
    if ((len_line-len_tok) > 0) {
	for (i=0; i<(len_line-len_tok-1+7); i++) fprintf(stderr," ");
	
	for (i=len_line-len_tok; i<len_line; i++) fprintf(stderr,"^");
	fprintf(stderr,"\n");
    }
    fprintf(stderr,"%s\n\tfile '%s'",s, current_file);
    fprintf(stderr," near line %d\n",nl_count);

    /* Keep track of number of errors for program exit. */
    ++yyerror_count;
    if (yyerror_count > 100) {
	fflush(stdout);
	fprintf(stderr, "\nToo many errors, giving up.\n");
	exit(yyerror_count);
    }
}

int
yywrap ()
{
    /* Detect matching end declarations. */
    const char *fmt_str = "ERROR : %s declaration at line %d not terminated!!!\n";
    char *decl_type = NULL;
    gen_ll *tmp_ll;
    int line;
    if (cstack != NULL) {
	line = cstack->line_count;
	switch (cstack->ll_type) {
	    case FOR_STRUCTURE: decl_type = "`for"; break;
	    case IF_STRUCTURE: decl_type = "`if"; break;
	    case IFDEF_STRUCTURE: decl_type = "`ifdef"; break;
	    case IFNDEF_STRUCTURE: decl_type = "`ifndef"; break;
	    case WHILE_STRUCTURE: decl_type = "`while"; break;
	    case ELSE_STRUCTURE: decl_type = "`else"; break;
	    case SWITCH_STRUCTURE:
	    case CASE_STRUCTURE:
	    case BREAKSW_STRUCTURE:
		decl_type = "`switch";
		tmp_ll = cstack->prev;
		while (tmp_ll != NULL) {
		    if (tmp_ll->ll_type == SWITCH_STRUCTURE) {
			line = cstack->line_count;
			break;
		    }
		    tmp_ll = tmp_ll->prev;
		}
		break;
	}
	if (decl_type != 0)
	    fprintf(stderr, fmt_str, decl_type, line);
    }

    return (1);
}
