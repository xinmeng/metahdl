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

 /* arithematic function name*/
%token K_LOG2  "`log2"
%token K_FLOOR "`floor"
%token K_CEIL  "`ceil"
%token K_HEX   "`hex"
%token K_BIN   "`bin"
%token K_DEC   "`dec"
%token K_MAX   "`max"
%token K_MIN   "`min"
%token K_ABS   "`abs"
%token K_EVEN  "`even"
%token K_ODD   "`odd"



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
%token       NL "\n"
%token <str> ID
%token <str> PURE_ID
%token <str> PURE_ID_OPEN_PARANTHES
%token <str> STRING
%token <str> NUM
%token <str> BIN_BASED_NUM
%token <str> DEC_BASED_NUM
%token <str> HEX_BASED_NUM
%token <str> VERBATIM

%token       OPT_COMMA ",[ \t]*``"


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

line_block : "`line" NUM STRING // strip `"' at both ends
;

// Enter <deep_expression> 
// don't expand arithmetic macro, so expression are preserved in a
// `deep' form with references to CArithMacro, which allows parser
// to evalue it again and again with latest CArithMacro value. 
// Lexer returns ID when encounter arithmetic macro
for_block : "`for" "(" statements ";" expression ";" statements ")" balanced_block "`endfor"
;

statements : 
| statements "," statement
;

foreach_block : "`foreach" ID "(" foreach_val_list ")" balanced_block "`endfor"
;

// Enter <verbatim_expression> 
// Each expression is recursively expanded.  object macro and
// arithmetic macro are expanded in lexer, function call macro are
// expanded in parser. Eventally, `foreach_val_list' is an array of
// `verbatims' separated by comma.
foreach_val_list : expression	// only accept verbatims
| foreach_val_list "," expression

mpp_loop_block : "`__mpp_loop_end__"
;



// Enter <const_expression>
// `expression' here is only evaluated once, so it is not neccessary
// to preserve it in data structure. So each expression is recursively
// expanded. All expression variants are parsed. Expression used here
// are constructed from constants. 
if_block : "`ifdef" PURE_ID balanced_block "`endif" 
| "`ifdef"  PURE_ID balanced_block "`else"  balanced_block "`endif" 
| "`ifndef" PURE_ID balanced_block "`endif" 
| "`ifndef" PURE_ID balanced_block "`else"  balanced_block "`endif" 
| "`if" expression "\n" balanced_block else_lists "`endif" 
| "`if" expression "\n" balanced_block else_lists "`else" balanced_block "`endif" 
;

else_lists : 
| else_lists "`elsif" expression "\n" balanced_block
;

verbatims : VERBATIM
| verbatims VERBATIM
;


define_block : "`define" PURE_ID verbatims "\n"
| "`define" PURE_ID_OPEN_PARANTHES arg_name_list ")" mix_pure_id_verbatim "\n"
| "`define" PURE_ID_OPEN_PARANTHES arg_name_list opt_arg ")" mix_pure_id_verbatim "\n"
;

arg_name_list : PURE_ID
| arg_name_list "," PURE_ID
;


opt_arg : "..."
| PURE_ID "..."
;

mix_pure_id_verbatim : 
| mix_pure_id_verbatim PURE_ID	// mark argument replace point
| mix_pure_id_verbatim VERBATIM	      // save macro definition literally
| mix_pure_id_verbatim opt_arg_concat // remove ',' if optional arg is nil
| mix_pure_id_verbatim ID	// stringfication
;

opt_arg_concat : OPT_COMMA PURE_ID // PURE_ID must be existing arg or '__VA_ARGS__'
;

// Enter <const_expression> to reduce value before assignment
let_statement : "`let" statement "\n"
;

constant : NUM
| BIN_BASED_NUM
| DEC_BASED_NUM
| HEX_BASED_NUM
;

// Enter <verbatim_expression> to produce verbatims list
macro_func_call : ID "(" macro_func_arg_val_list ")"
;

macro_func_arg_val_list : opt_macro_func_arg_val
|  macro_func_arg_val_list "," opt_macro_func_arg_val
;

opt_macro_func_arg_val : 
| expression			
;

// Enter <const_expression>
// because arith_func_call only accept numbers as arguments
arith_func_call : single_arg_func_call 
| two_arg_func_call 
| multi_arg_func_call
;

single_arg_func_call : single_arg_func_name "(" expression ")"
;

single_arg_func_name : K_LOG2  
| K_FLOOR 
| K_CEIL
| K_ABS   
| K_EVEN  
| K_ODD   
;

two_arg_func_call : two_arg_func_name "(" expression ")"
| two_arg_func_name "(" expression "," expression ")"
;

two_arg_func_name : K_HEX   
| K_DEC
| K_BIN   
;

multi_arg_func_call : multi_arg_func_name "(" arith_func_arg_list ")"
;

multi_arg_func_name : K_MAX   
| K_MIN   
;

arith_func_arg_list : expression 
| arith_func_arg_list "," expression
;



expression : constant
| verbatims
| ID
| macro_func_call
| arith_func_call
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
;


// Enter <deep_expression> to extract expression
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
