%require "2.5"
%skeleton "lalr1.cc"
%glr-parser
%verbose
%error-verbose
%debug
%locations
%initial-action
{
  // Initialize the initial location.
  @$.begin.filename = @$.end.filename = &mwrapper.filename;
};
%defines
%define "parser_class_name" "mppParser"
 // %name-prefix="mhdl"
%output="mppParser.bison.cc"



%code requires{
#include <string>
   using namespace std;
}


%union {
  string *str;
}


%parse-param {CWrapper &wrapper}
%lex-param   {CWrapper &wrapper}

%{
  extern yy::mppParser::token::yytokentype mpplex(yy::mppParser::semantic_type *yylval, 
						  yy::mppParser::semantic_type *yylloc,
						  CWrapper &wrapper);
#define yylex mpplex
%}



 /* MPP keywords */
%token K_DEFINE       "`define"
%token K_LET          "`let"
%token K_IFDEF        "`ifdef"
%token K_IFNDEF       "`ifndef"
%token K_IF           "`if"
%token K_ELSIF        "`elsif"
%token K_ENDIF        "`endif"
%token K_FOR          "`for"
%token K_FOREACH      "`foreach"
%token K_ENDFOR       "`endfor"
%token K_SWITCH       "`switch"
%token K_CASE         "`case"
%token K_DEFAULT      "`default"
%token K_ENDSWITCH    "`endswitch"
%token K_MPP_LOOP_END "`__mpp_loop_end__"


 /* MPP operators*/
%token OR  "|"
%token AND "&" 
%token XOR "^"

%token UNARY_NOT    "~"

%token UNARY_ADD    "++"
%token UNARY_SUB    "--"

%token BINARY_PLUS  "+"
%token BINARY_MINUS "-"
%token BINARY_MULT  "*"
%token BINARY_DIV   "/"
%token BINARY_MOD   "%"
%token BINARY_LSH   "<<"
%token BINARY_RSH   ">>"

%token COND_NOT     "!"
%token COND_AND     "&&"
%token COND_OR      "||"
%token COND_LT      "<"
%token COND_GT      ">"
%token COND_EQ      "=="
%token COND_NE      "!="
%token COND_LE      "<="
%token COND_GE      ">="


%token TRI_QUESTION  "?"
%token TRI_COLON     ":"


 /* punctuations */
%token PUNC_EQUAL     "="
%token PUNC_COMMA     ","
%token PUNC_SEMICOLON ";"
%token PUNC_LPAREN    "("
%token PUNC_RPAREN    ")"
%token PUNC_DOTS      "..."

 /* control directives */
%token CTRL_LINE "`line"

 /* other tokens */
%token       NL
%token <str> ID
%token <str> ID_OPEN_PARANTHES
%token <str> PURE_ID
%token <str> PURE_ID_DOTS
%token <str> PURE_ID_OPEN_PARANTHES
%token <str> STRING
%token <str> NUM
%token <str> BIN_BASED_NUM
%token <str> DEC_BASED_NUM
%token <str> HEX_BASED_NUM
%token <str> VERBATIM
%token       LITERAL
%token       FUNC_MACRO_BODY

%token       OPT_COMMA_CONCAT ",[ \t]*``"


%token       END 0 "end of file"


%right "=" 
%right "?" ":"
%left  "||"
%left  "&&" 
%left  "|"
%left  "^"
%left  "&" 
%left  "==" "!=" 
%left  "<" "<=" ">" ">="
%left  "<<" ">>"
%left  "+" "-"
%left  "*" "/" "%"
%right "!" "~" UNARY_AND UNARY_OR UNARY_XOR
%left  "++" "--"

%% 

balanced_block : 
| balanced_block line_block
| balanced_block for_block
| balanced_block foreach_block
| balanced_block mpp_loop_block
| balanced_block if_block
| balanced_block define_block
| balanced_block let_statement
| balanced_block switch_block
;

line_block : "`line" NUM STRING 
;

for_block : "`for" "(" expression ";" expression ";" post_ops ")" balanced_block "`endfor"
;

post_ops :
| post_ops "," statement
;

foreach_block : "`foreach" ID "(" literal_list ")" balanced_block "`endfor"
;

literal_list : LITERAL
| literal_list "," LITERAL
;


mpp_loop_block : "`__mpp_loop_end__"
;

if_block : "`ifdef" PURE_ID balanced_block "`endif" 
| "`ifdef"  PURE_ID balanced_block "`else" balanced_block "`endif"
| "`ifndef" PURE_ID balanced_block "`endif"
| "`ifndef" PURE_ID balanced_block "`else" balanced_block "`endif"
| "`if" expression NL balanced_block else_lists "`endif"
| "`if" expression NL balanced_block else_lists "`else" balanced_block "`endif"
;

else_lists : 
| else_lists "`elsif" expression NL balanced_block
;

verbatims : VERBATIM
| verbatims VERBATIM
;


define_block : "`define" PURE_ID verbatims NL
| "`define" PURE_ID_OPEN_PARANTHES arg_list ")" mix_pure_id_verbatim NL
| "`define" PURE_ID_OPEN_PARANTHES arg_list opt_arg ")" mix_pure_id_verbatim NL
;

arg_list :
| PURE_ID
| arg_list "," PURE_ID
;

opt_arg : "..."
| PURE_ID_DOTS
;

mix_pure_id_verbatim : 
| mix_pure_id_verbatim PURE_ID
| mix_pure_id_verbatim VERBATIM
| mix_pure_id_verbatim OPT_COMMA_CONCAT
;

let_statement : "`let" statement NL
;

constant : NUM
| BIN_BASED_NUM
| DEC_BASED_NUM
| HEX_BASED_NUM
;

func_call : ID_OPEN_PARANTHES literal_list ")"
;



expression : constant
| ID
| func_call
| "(" expression ")" 
| "|" expression %prec UNARY_OR
| "&" expression %prec UNARY_AND
| "^" expression %prec UNARY_XOR
| "~" expression
| expression "|" expression 
| expression "&" expression 
| expression "^" expression
| expression "+" expression
| expression "-" expression 
| expression "*" expression
| expression "/" expression
| expression "%" expression
| expression "<<" expression 
| expression ">>" expression 
| expression "?" expression ":" expression 
| "!" expression 
| expression "||" expression 
| expression "&&" expression
| expression "<" expression
| expression ">" expression
| expression "==" expression 
| expression "!=" expression
| expression ">=" expression
| expression "<=" expression
;

statement :
| ID "++"
| ID "--"
| ID "=" expression
| ID "=" statement 


switch_block : "`switch" "(" expression ")" case_list opt_default "`endswitch"
;

case_list : case_exps ":" balanced_block 
;

case_exps : "`case" expression
| case_exps "," "`case" expression
;

opt_default : 
| "`default" ":" balanced_block
;
