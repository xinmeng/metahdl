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

#ifndef __PROTO_H__
#define __PROTO_H__

int ascii2double(char *name, double *nmbr);
int is_an_integer(double value);
double round_int(double i);

expr *create_identifier(int ident, char *name);
expr *create_expression(int ident, expr *ep1, expr *ep2, expr *ep3);
expr *create_primary(int ident, char *name, expr *ep1, expr *ep2, expr_list *elp);
void traverse_expression(expr *ep);
void print_operand(expr *ep);
expr_list *create_expression_list(expr_list *head, expr *ep);
stmt *create_statement(int ident, expr *ep, stmt *sp1, stmt *sp2, t_ident_ref *lp);
t_ident_ref *create_ident_ref(int ident, char *name, expr *ep1, expr *ep2);

varp *create_variable_ref(char *name, expr *ep, int do_eval);
var_values *create_variable(char *name, double dval);
void insert_variable_into_table();
var_values *get_variable_ref(int ident, char *name);

void free_expr(expr *ep);
double evaluate_expression(expr *ep);
double perform_operand(int np, double tmp1, double tmp2, expr *ep);
void eval_stack(gen_ll *ll);

gen_ll *create_generic_ll(int ll_type, gen_ll *head, ll_generic *item);
gen_ll *append_generic_ll(gen_ll *a, gen_ll *b);
gen_ll *push(gen_ll *stack, gen_ll *item);
gen_ll *pop(gen_ll *stack);
gen_ll *create_if_structure(expr *ep);
gen_ll *create_switch_structure(expr *ep);
gen_ll *create_case_structure(expr *ep);
gen_ll *create_while_structure(expr *ep);
gen_ll *create_for_structure(varp *vp1,expr *ep_eval,char *name2,expr *ep2);

/* From vpp.l */
void do_comment_count(int force_print, int count);
void print_variable(char *name, int expand_define);
int get_define_value(char *name, double *dval);
void set_to_vpp_mode();
void set_to_initial_mode();
void set_to_copy();
void set_to_last_mode();
void store_define(char *def_text);

#endif /* __PROTO_H__ */
