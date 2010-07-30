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

#ifndef __YACC_STUFF_H__
#define __YACC_STUFF_H__

extern FILE *yyin;
extern char *yytext;
extern int yyerror_count;
extern void yyerror(char *str); /* Our version. */
extern "C" int yywrap(void); /* Our version. */
extern int yylex(void); /* Lexical analyzer function. */
extern int yyparse(void); /* Parser function. */

/* vpp.l */
extern int nl_count;
extern char old_line[MAXNAME];
extern char current_line[MAXNAME];
extern char *current_file;
extern int output_line_directive;
extern int output_ifdef_directive;

typedef void ll_generic;

#define DELTA 0.0001

#define INTEGER 0
#define REAL 1
#define STRING 3
#define QUOTED_STRING 98
#define NMBR 99

#define ADD 4
#define SUB 5
#define MULT 6
#define DIV 7
#define MOD 8
#define EQ 9
#define NEQ 10
#define CASEEQ 11
#define CASENEQ 12
#define AND 13
#define OR 14
#define LT 15
#define LEQ 16
#define GT 17
#define GEQ 18
#define BITAND 19
#define BITOR 20
#define BITXOR 21
#define BITXNOR 22
#define SHIFTR 23
#define SHIFTL 24

#define UPLUS 25
#define UMINUS 26
#define UNOT 27
#define UTILDA 28
#define UAND 29
#define UNAND 30
#define UNOR 31
#define UPIPE 32
#define UCARAT 33
#define UXNOR 34

#define TRINARY 35

#define ID_SINGLE_EXPR 36
#define ID_DOUBLE_EXPR 37
#define CONCATENATION 38
#define MULTIPLE_CONCATENATION 39
#define FUNCTION 40

#define MINTYPMAX 41
#define POWER 42
#define LOG2 43
#define ROUND 44
#define CEIL 45
#define FLOOR 46
#define MAX 47
#define MIN 48
#define ABS 49
#define STOI 50
#define ITOS 51
#define SUBSTR 52
#define SYSTEM 53
#define EVEN 54
#define ODD 55

#define IDENT_REF_IDENT 0
#define IDENT_REF_ONE_EXPR 1
#define IDENT_REF_TWO_EXPR 2
#define IDENT_REF_CONCAT 3

#define STMT_BLOCKING 0
#define STMT_NON_BLOCKING 1
#define STMT_IF 2
#define STMT_CASE 3
#define STMT_CASEZ 4
#define STMT_CASEX 5
#define STMT_FOREVER 6
#define STMT_REPEAT 7
#define STMT_WHILE 8
#define STMT_FOR 9
#define STMT_WAIT 10
#define STMT_EVENT_TRIGGER 11

typedef struct expr {
    short ident;
    union {
	int val_int;
	double val_real;
	char *strg;
    } u;
    struct expr *ep1;
    struct expr *ep2;
    struct expr *ep3;
    struct expr_list *elp;
    struct var_values *vvp;
    int precision;
} expr;

typedef struct expr_list {
    expr *ep;
    struct expr_list *next;
} expr_list;

typedef struct t_ident_ref {
    short ident;
    char *strg;
    struct expr *ep1;
    struct expr *ep2;
} t_ident_ref;

typedef struct stmt {
    short ident;
    struct expr *ep;
    struct stmt *sp1;
    struct stmt *sp2;
    struct t_ident_ref *lp;
} stmt;

typedef struct t_module {
    char *name;
    struct t_port_list *port_list;
    struct t_mod_item *mod_item;
} t_module;

typedef struct varp {
    char *name;
    expr *ep;
    struct var_values *vvp;
    char *strg;
} varp;

typedef struct var_list {
    varp *vp;
    struct var_list *next;
} var_list;

#define EV_EXP_LIST 0
#define F_OR_S_LIST 1
#define GENERIC_LIST 2
#define PRESET_LIST 3
#define RESET_LIST 4
#define EXCLUDE_LIST 5
#define NAMES_LIST 6
#define PARAM_LIST 7

#define CODE_POINTER 8
#define FOR_STRUCTURE 9
#define IF_STRUCTURE 10
#define IFDEF_STRUCTURE 11
#define IFNDEF_STRUCTURE 12
#define WHILE_STRUCTURE 13
#define ENDIF_STRUCTURE 14
#define ELSE_STRUCTURE 15
#define COLLAPSED_STRUCTURE 16
#define CODE_POINTER2 17
#define ENDFOR_STRUCTURE 18
#define LET_STRUCTURE 19
#define ENDWHILE_STRUCTURE 20
#define SWITCH_STRUCTURE 21
#define CASE_STRUCTURE 22
#define DEFAULT_STRUCTURE 23
#define ENDSWITCH_STRUCTURE 24
#define DEFINE_STRUCTURE 25
#define BREAKSW_STRUCTURE 26

typedef struct gen_ll {
    int ll_type;
    int line_count;
    ll_generic *item;
    struct gen_ll *prev;
    struct gen_ll *next;
} gen_ll;

/*
 * the following stucture points to the head and tail of a
 * generic linked list.
 */
typedef struct gen_ll_mgr {
    struct gen_ll *head;
    struct gen_ll *tail;
} gen_ll_mgr;

/*
 * for structure...
 */
typedef struct for_struct {
    varp *vp1;
    expr *ep_eval;
    char *name2;
    expr *ep2;
    int eval_first;
} for_struct;

/*
 * while structure...
 */
typedef struct while_struct {
    expr *ep;
    int eval_first;
} while_struct;

/*
 * switch structure...
 */
typedef struct switch_struct {
    expr *ep;
    int done_a_case;
    int status_on_entry;
    int ignore_more_matches;
    int value;
} switch_struct;

typedef struct var_values {
    char *name;
    int value;
    double dval;
    int vtype;
    char *strg;
    struct var_values *next;
} var_values;

typedef struct loop_stack
{
    int ll_type;
    int active;
    int region_active;
    gen_ll *mate;
    expr *ep;
    struct loop_stack *next;
} loop_stack;

#endif /* __YACC_STUFF_H__ */
