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
  @$.begin.filename = @$.end.filename = &wrapper.filename;
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
  vector<string> *str_vector_ptr;

  CMacroBodyOptComma *macro_body_opt_comma;
  CMacroBodyOptArgRef *macro_body_opt_arg_ref;
  vector<CMacroBody*> *macro_body_vector_ptr;


  CStatement *stmt_ptr;
  CStmtSimple *assignment_stmt;
  CStmtSelfInc *self_inc_stmt;
  CStmtSelfDec *self_dec_stmt;
  vector<CStatement*> *stmt_vector_ptr;

  CConstant *constant_ptr;
  CExpression *expression_ptr;
  vector<CExpression*> *exp_vector_ptr;

  

  
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

%token <macro_body_opt_comma> OPT_COMMA ",[ \t]*``"

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


%type <str> verbatims opt_arg single_arg_func_name two_arg_func_name multi_arg_func_name
%type <str_vector_ptr> arg_name_list foreach_val_list  
%type <stmt_vector_ptr> statements
%type <stmt_ptr> statement
%type <expression_ptr> expression constant
%type <expression_ptr> single_arg_func_call two_arg_func_call multi_arg_func_call
%type <exp_vector_ptr> arith_func_arg_list
%type <macro_body_vector_ptr> mix_pure_id_verbatim opt_arg_concat


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
| balanced_block arith_func_call
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

statements : {$$ = new vector<CStatement*>;}
| statements "," statement {$1->push_back($3); $$=$1;}
;

foreach_block : "`foreach" ID "(" foreach_val_list ")" balanced_block "`endfor"
;

// Enter <verbatim_expression> 
// Each expression is recursively expanded.  object macro and
// arithmetic macro are expanded in lexer, function call macro are
// expanded in parser. Eventally, `foreach_val_list' is an array of
// `verbatims' separated by comma.
foreach_val_list : verbatims {$$=new vector<string>; $$->push_back(*$1);}
| foreach_val_list "," verbatims {$1->push_back(*$3); $$=$1;}

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


// Enter <define_block>
define_block : "`define" PURE_ID "\n"
| "`define" PURE_ID verbatims "\n"
| "`define" PURE_ID_OPEN_PARANTHES arg_name_list ")" mix_pure_id_verbatim "\n"
| "`define" PURE_ID_OPEN_PARANTHES arg_name_list opt_arg ")" mix_pure_id_verbatim "\n"
;

arg_name_list : PURE_ID {$$=new vector<string>; $$->push_back($1);}
| arg_name_list "," PURE_ID {$1->push_back($3); $$=$1;}
;


opt_arg : "..." {$$=new string ("__VA_ARG__");}
| PURE_ID "..." {$$=$1;}
;

mix_pure_id_verbatim : {$$=new vector<CMacroBody*>;}
| mix_pure_id_verbatim PURE_ID	// mark argument replace point
| mix_pure_id_verbatim VERBATIM	      // save macro definition literally
| mix_pure_id_verbatim opt_arg_concat // remove ',' if optional arg is nil
| mix_pure_id_verbatim ID	// stringfication
;

// PURE_ID must be existing arg or '__VA_ARGS__'
opt_arg_concat : OPT_COMMA PURE_ID 
{
  $$=new vector<CMacroBody*>; 
  $$->push_back($1); 
  $$->push_back(new CMacroBodyOptArgRef (1) );
}
;

// Enter <const_expression> to reduce value before assignment
let_statement : "`let" statement "\n"
;

constant: NUM   
{ 
  $$ = new CNumber (*$1);
}

| BIN_BASED_NUM 
{
  try{ $$ = new CBasedNum(*$1, 2);}
  catch (string &str) {wrapper.error(@1, str);}
}
    
| DEC_BASED_NUM 
{ 
  try{ $$ = new CBasedNum(*$1, 10);}
  catch (string &str) {wrapper.error(@1, str);}
}

| HEX_BASED_NUM 
{
  try{ $$ = new CBasedNum(*$1, 16);}
  catch (string &str) {wrapper.error(@1, str);}
}
;


// // Enter <verbatim_expression> to produce verbatims list
// macro_func_call : ID "(" macro_func_arg_val_list ")" 
// {
//   $$ = new CString ("");
// }
// ;

// macro_func_arg_val_list : opt_macro_func_arg_val {$$ = new vector<CExpression*>; $$->push_back($1)}
// |  macro_func_arg_val_list "," opt_macro_func_arg_val {$1->push_back($3), $$=$1;}
// ;

// opt_macro_func_arg_val : {$$=NULL;}
// | expression {$$=$1;}			
// ;

// Enter <const_expression>
// because arith_func_call only accept numbers as arguments
arith_func_call : single_arg_func_call 
| two_arg_func_call 
| multi_arg_func_call
;

single_arg_func_call : single_arg_func_name "(" expression ")" 
{
  $$=new CString ("");		// expand func
}
;

single_arg_func_name : K_LOG2  {$$=new string ("log2");}
| K_FLOOR {$$=new string ("floor");}
| K_CEIL {$$=new string ("ceil");}
| K_ABS  {$$=new string ("abs");}
| K_EVEN  {$$=new string ("even");}
| K_ODD   {$$=new string ("odd");}
;

two_arg_func_call : two_arg_func_name "(" expression ")" 
{
  $$ = new CString ("");
}
| two_arg_func_name "(" expression "," expression ")"
{
  $$ = new CString ("");
}
;

two_arg_func_name : K_HEX   {$$=new string("hex");}
| K_DEC {$$=new string ("dec");}
| K_BIN {$$=new string ("bin");}
;

multi_arg_func_call : multi_arg_func_name "(" arith_func_arg_list ")"
{
  $$ = new CString ("");
}
;

multi_arg_func_name : K_MAX    {$$ = new string ("max");}
| K_MIN   {$$ = new string ("min");}
;

arith_func_arg_list : expression  {$$=new vector<CExpression*>; $$->push_back($1);}
| arith_func_arg_list "," expression {$1->push_back($3); $$=$1;}
;



expression : constant
| verbatims {$$=new CString (*$1);}
| ID {$$=new CString (*$1);}
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
