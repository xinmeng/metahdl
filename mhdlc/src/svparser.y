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
  @$.begin.filename = @$.end.filename = &svwrapper.filename;
};
%defines
%define "parser_class_name" "svParser"
 // %name-prefix="sv"
%output="svparser.bison.cc"


%code requires {
#include <string>
#include <iostream>

class CSVwrapper;
#include "MetaHDL.hh"
}

%union {
  string *str;
  vector<string> *str_vct;
  CExpression *expression_ptr;
  CConstant   *constant_ptr;
  CParameter  *param_ptr;
  vector<CExpression*> *exp_vct;
  CConcatenation*  concat_exp_ptr;
  CStatement*      stmt_ptr;
  vector<CStatement*> *stmt_vct;
  vector<CCaseItem*> *case_item_vct;
  CCaseItem         *case_item_ptr;
  tDirection             port_type;
  tType        var_type;
  CCodeBlock   *blk_ptr;
  CFFItem      *ff_item_ptr;
  vector<CFFItem*> *ff_item_vct;
  CStmtBunch     *stmt_bunch_ptr;
  CStateItem     *state_item_ptr;
  vector<CStateItem*> *state_item_vct;
  CBlkFSM             *fsm_blk_ptr;
  CBlkVerbtim         *raw_code_ptr;
  CBlkInst            *inst_blk_ptr;
  vector<pair<string, CExpression*> >  *param_rule_ptr;
}



%parse-param {CSVwrapper &svwrapper}
%lex-param {CSVwrapper &svwrapper}

%{
  extern  yy::svParser::token::yytokentype svlex(yy::svParser::semantic_type *yylval, yy::svParser::location_type *yylloc, CSVwrapper &svwrapper);

#define yylex svlex
#define ECHO_LOC(var, s) cerr << "[" << s << "]" << var << endl;

%}

 /* SystemVerilog keywords */
%token K_ALIAS                    "alias"             	   
%token K_ALWAYS			  "always"		 
%token K_ALWAYS_COMB		  "always_comb"	  	 
%token K_ALWAYS_FF		  "always_ff"	  	 
%token K_ALWAYS_LATCH		  "always_latch"	  	 
%token K_AND			  "and"		  	 
%token K_ASSERT			  "assert"		 
%token K_ASSIGN			  "assign"		 
%token K_ASSUME			  "assume"		 
%token K_AUTOMATIC		  "automatic"	  	 
%token K_BEFORE			  "before"		 
%token K_BEGIN			  "begin"		  	 
%token K_BIND			  "bind"		  	 
%token K_BINS			  "bins"		  	 
%token K_BINSOF			  "binsof"		 
%token K_BIT			  "bit"		  	 
%token K_BREAK			  "break"		  	 
%token K_BUF			  "buf"		  	 
%token K_BUFIF0			  "bufif0"		 
%token K_BUFIF1			  "bufif1"		 
%token K_BYTE			  "byte"		  	 
%token K_CASE			  "case"		  	 
%token K_CASEX			  "casex"		  	 
%token K_CASEZ			  "casez"		  	 
%token K_CELL			  "cell"		  	 
%token K_CHANDLE		  "chandle"		 
%token K_CLASS			  "class"		  	 
%token K_CLOCKING		  "clocking"	  	 
%token K_CMOS			  "cmos"		  	 
%token K_CONFIG			  "config"		 
%token K_CONST			  "const"		  	 
%token K_CONSTRAINT		  "constraint"	  	 
%token K_CONTEXT		  "context"		 
%token K_CONTINUE		  "continue"	  	 
%token K_COVER			  "cover"		  	 
%token K_COVERGROUP		  "covergroup"	  	 
%token K_COVERPOINT		  "coverpoint"	  	 
%token K_CROSS			  "cross"		  	 
%token K_DEASSIGN		  "deassign"	  	 
%token K_DEFAULT		  "default"		 
%token K_DEFPARAM		  "defparam"	  	 
%token K_DESIGN			  "design"		 
%token K_DISABLE		  "disable"		 
%token K_DIST			  "dist"		  	 
%token K_DO			  "do"		  	 
%token K_EDGE			  "edge"		  	 
%token K_ELSE			  "else"		  	 
%token K_END			  "end"		  	 
%token K_ENDCASE		  "endcase"		 
%token K_ENDCLASS		  "endclass"	  	 
%token K_ENDCLOCKING		  "endclocking"	  	 
%token K_ENDCONFIG		  "endconfig"	  	 
%token K_ENDFUNCTION		  "endfunction"	  	 
%token K_ENDGENERATE		  "endgenerate"	  	 
%token K_ENDGROUP		  "endgroup"	  	 
%token K_ENDINTERFACE		  "endinterface"	  	 
%token K_ENDMODULE		  "endmodule"	  	 
%token K_ENDPACKAGE		  "endpackage"	  	 
%token K_ENDPRIMITIVE		  "endprimitive"	  	 
%token K_ENDPROGRAM		  "endprogram"	  	 
%token K_ENDPROPERTY		  "endproperty"	  	 
%token K_ENDSPECIFY		  "endspecify"	  	 
%token K_ENDSEQUENCE		  "endsequence"	  	 
%token K_ENDTABLE		  "endtable"	  	 
%token K_ENDTASK		  "endtask"		 
%token K_ENUM			  "enum"		  	 
%token K_EVENT			  "event"		  	 
%token K_EXPECT			  "expect"		 
%token K_EXPORT			  "export"		 
%token K_EXTENDS		  "extends"		 
%token K_EXTERN			  "extern"		 
%token K_FINAL			  "final"		  	 
%token K_FIRST_MATCH		  "first_match"	  	 
%token K_FOR			  "for"		  	 
%token K_FORCE			  "force"		  	 
%token K_FOREACH		  "foreach"		 
%token K_FOREVER		  "forever"		 
%token K_FORK			  "fork"		  	 
%token K_FORKJOIN		  "forkjoin"	  	 
%token K_FUNCTION		  "function"	  	 
%token K_GENERATE		  "generate"	  	 
%token K_GENVAR			  "genvar"		 
%token K_HIGHZ0			  "highz0"		 
%token K_HIGHZ1			  "highz1"		 
%token K_IF			  "if"		  	 
%token K_IFF			  "iff"		  	 
%token K_IFNONE			  "ifnone"		 
%token K_IGNORE_BINS		  "ignore_bins"	  	 
%token K_ILLEGAL_BINS		  "illegal_bins"	  	 
%token K_IMPORT			  "import"		 
%token K_INCDIR			  "incdir"		 
%token K_INCLUDE		  "include"		 
%token K_INITIAL		  "initial"		 
%token K_INOUT			  "inout"		  	 
%token K_INPUT			  "input"		  	 
%token K_INSIDE			  "inside"		 
%token K_INSTANCE		  "instance"	  	 
%token K_INT			  "int"		  	 
%token K_INTEGER		  "integer"		 
%token K_INTERFACE		  "interface"	  	 
%token K_INTERSECT		  "intersect"	  	 
%token K_JOIN			  "join"		  	 
%token K_JOIN_ANY		  "join_any"	  	 
%token K_JOIN_NONE		  "join_none"	  	 
%token K_LARGE			  "large"		  	 
%token K_LIBLIST		  "liblist"		 
%token K_LIBRARY		  "library"		 
%token K_LOCAL			  "local"		  	 
%token K_LOCALPARAM		  "localparam"	  	 
%token K_LOGIC			  "logic"		  	 
%token K_LONGINT		  "longint"		 
%token K_MACROMODULE		  "macromodule"	  	 
%token K_MATCHES		  "matches"		 
%token K_MEDIUM			  "medium"		 
%token K_MODPORT		  "modport"		 
%token K_MODULE			  "module"		 
%token K_NAND			  "nand"		  	 
%token K_NEGEDGE		  "negedge"		 
%token K_NEW			  "new"		  	 
%token K_NMOS			  "nmos"		  	 
%token K_NOR			  "nor"		  	 
%token K_NOSHOWCANCELLED	  "noshowcancelled"	 
%token K_NOT			  "not"		  	 
%token K_NOTIF0			  "notif0"		 
%token K_NOTIF1			  "notif1"		 
%token K_NULL			  "null"		  	 
%token K_OR			  "or"		  	 
%token K_OUTPUT			  "output"		 
%token K_PACKAGE		  "package"		 
%token K_PACKED			  "packed"		 
%token K_PARAMETER		  "parameter"	  	 
%token K_PMOS			  "pmos"		  	 
%token K_POSEDGE		  "posedge"		 
%token K_PRIMITIVE		  "primitive"	  	 
%token K_PRIORITY		  "priority"	  	 
%token K_PROGRAM		  "program"		 
%token K_PROPERTY		  "property"	  	 
%token K_PROTECTED		  "protected"	  	 
%token K_PULL0			  "pull0"		  	 
%token K_PULL1			  "pull1"		  	 
%token K_PULLDOWN		  "pulldown"	  	 
%token K_PULLUP			  "pullup"		 
%token K_PULSESTYLE_ONEVENT	  "pulsestyle_onevent"	 
%token K_PULSESTYLE_ONDETECT	  "pulsestyle_ondetect"	 
%token K_PURE			  "pure"		  	 
%token K_RAND			  "rand"		  	 
%token K_RANDC			  "randc"		  	 
%token K_RANDCASE		  "randcase"	  	 
%token K_RANDSEQUENCE		  "randsequence"	  	 
%token K_RCMOS			  "rcmos"		  	 
%token K_REAL			  "real"		  	 
%token K_REALTIME		  "realtime"	  	 
%token K_REF			  "ref"		  	 
%token K_REG			  "reg"		  	 
%token K_RELEASE		  "release"		 
%token K_REPEAT			  "repeat"		 
%token K_RETURN			  "return"		 
%token K_RNMOS			  "rnmos"		  	 
%token K_RPMOS			  "rpmos"		  	 
%token K_RTRAN			  "rtran"		  	 
%token K_RTRANIF0		  "rtranif0"	  	 
%token K_RTRANIF1		  "rtranif1"	  	 
%token K_SCALARED		  "scalared"	  	 
%token K_SEQUENCE		  "sequence"	  	 
%token K_SHORTINT		  "shortint"	  	 
%token K_SHORTREAL		  "shortreal"	  	 
%token K_SHOWCANCELLED		  "showcancelled"	  	 
%token K_SIGNED			  "signed"		 
%token K_SMALL			  "small"		  	 
%token K_SOLVE			  "solve"		  	 
%token K_SPECIFY		  "specify"		 
%token K_SPECPARAM		  "specparam"	  	 
%token K_STATIC			  "static"		 
%token K_STRING			  "string"		 
%token K_STRONG0		  "strong0"		 
%token K_STRONG1		  "strong1"		 
%token K_STRUCT			  "struct"		 
%token K_SUPER			  "super"		  	 
%token K_SUPPLY0		  "supply0"		 
%token K_SUPPLY1		  "supply1"		 
%token K_TABLE			  "table"		  	 
%token K_TAGGED			  "tagged"		 
%token K_TASK			  "task"		  	 
%token K_THIS			  "this"		  	 
%token K_THROUGHOUT		  "throughout"	  	 
%token K_TIME			  "time"		  	 
%token K_TIMEPRECISION		  "timeprecision"	  	 
%token K_TIMEUNIT		  "timeunit"	  	 
%token K_TRAN			  "tran"		  	 
%token K_TRANIF0		  "tranif0"		 
%token K_TRANIF1		  "tranif1"		 
%token K_TRI			  "tri"		  	 
%token K_TRI0			  "tri0"		  	 
%token K_TRI1			  "tri1"		  	 
%token K_TRIAND			  "triand"		 
%token K_TRIOR			  "trior"		  	 
%token K_TRIREG			  "trireg"		 
%token K_TYPE			  "type"		  	 
%token K_TYPEDEF		  "typedef"		 
%token K_UNION			  "union"		  	 
%token K_UNIQUE			  "unique"		 
%token K_UNSIGNED		  "unsigned"	  	 
%token K_USE			  "use"		  	 
%token K_VAR			  "var"		  	 
%token K_VECTORED		  "vectored"	  	 
%token K_VIRTUAL		  "virtual"		 
%token K_VOID			  "void"		  	 
%token K_WAIT			  "wait"		  	 
%token K_WAIT_ORDER		  "wait_order"	  	 
%token K_WAND			  "wand"		  	 
%token K_WEAK0			  "weak0"		  	 
%token K_WEAK1			  "weak1"		  	 
%token K_WHILE			  "while"		  	 
%token K_WILDCARD		  "wildcard"	  	 
%token K_WIRE			  "wire"		  	 
%token K_WITH			  "with"		  	 
%token K_WITHIN			  "within"		 
%token K_WOR			  "wor"		  	 
%token K_XNOR			  "xnor"		  	 
%token K_XOR			  "xor"		         


 /* operators */
%token OR  "|"
%token AND "&" 
%token XOR "^"

%token UNARY_NOT    "~"

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
%token PUNC_DOT       "."
%token PUNC_SEMICOLON ";"
%token PUNC_LBRACE    "{"
%token PUNC_RBRACE    "}"
%token PUNC_LPAREN    "("
%token PUNC_RPAREN    ")"
%token PUNC_LBRECT    "["
%token PUNC_RBRECT    "]"
%token PUNC_CHARP     "#"


 /* control directives */
%token CTRL_LINE "`line"

 /* other tokens */
%token       NL
%token <str> ID
%token <str> STRING
%token <str> NUM
%token <str> BIN_BASED_NUM
%token <str> DEC_BASED_NUM
%token <str> HEX_BASED_NUM
%token <str> VERBTIM
%token       END 0 "end of file"

%type <str> net_name
%type <str_vct>  net_names
%type <expression_ptr> expression
%type <concat_exp_ptr> concatenation
%type <exp_vct>   expressions
%type <constant_ptr> constant
%type <expression_ptr> net
%type <port_type> port_direction



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




%%


start: 
| start line_directive
| start module_definition
;


module_definition : "module"  ID "("
{
  svwrapper.io_table = new CIOTab;
  svwrapper.param_table = new CParamTab;
  svwrapper.symbol_table = new CSymbolTab;
}
port_list ")" ";" body "endmodule" 
{
  svwrapper.module_name = *$2;
  svwrapper.module_location = @$;
  svwrapper.BuildModule();
  svwrapper.io_table->Reset();
}

| "module"  ID 
{
  svwrapper.io_table = new CIOTab;
  svwrapper.param_table = new CParamTab;
  svwrapper.symbol_table = new CSymbolTab;
}
"#" "(" module_parameter_port_list ")" 
"(" port_list ")" ";" body "endmodule" 
{
  svwrapper.module_name = *$2;
  svwrapper.module_location = @$;
  svwrapper.BuildModule();
  svwrapper.io_table->Reset();
} 

| "module"  ID ";" 
{
  svwrapper.warning(@$, "Module " + *$2 + " has no IO." );
  svwrapper.io_table = new CIOTab;
  svwrapper.param_table = new CParamTab;
  svwrapper.symbol_table = new CSymbolTab;
}
body "endmodule" 
{
  svwrapper.module_name = *$2;
  svwrapper.module_location = @$;
  svwrapper.BuildModule();
  svwrapper.io_table->Reset();
} 
;


module_parameter_port_list : module_parameter_assignment
| module_parameter_port_list "," module_parameter_assignment
;

module_parameter_assignment : parameter_keywords parameter_assignment
;


body: 
| body port_declaration
| body parameter_declaration
/* | body constant_declaration */
/* | body variable_declaration */
| body line_directive
/* | body assign_block */
/* | body combinational_block */
;


constant: NUM   
{ 
  $$ = new CNumber (*$1);
}

| BIN_BASED_NUM 
{
  try{ $$ = new CBasedNum(*$1, 2);}
  catch (string &str) {svwrapper.error(@1, str);}
}
    
| DEC_BASED_NUM 
{ 
  try{ $$ = new CBasedNum(*$1, 10);}
  catch (string &str) {svwrapper.error(@1, str);}
}

| HEX_BASED_NUM 
{
  try{ $$ = new CBasedNum(*$1, 16);}
  catch (string &str) {svwrapper.error(@1, str);}
}
;



net_name : ID {$$ = $1;}
;



net : net_name "[" expression ":" expression "]" 
{
  CParameter* param = svwrapper.param_table->Exist(*$1);
  if ( param ) {
    svwrapper.error(@$, "segment selection from parameter is not supported.");
  }
  else {
    if ( $3->IsConst() && $5->IsConst() ) {
      CSymbol* symb = svwrapper.symbol_table->Insert(*$1);
      symb->Update($3);
      $$ = new CVariable ( symb, $3, $5);
    }
    else {
      svwrapper.error(@$, "non-constant segment selection boundary.");
    }
  }
}

| net_name "[" expression "]" 
{
  CParameter* param = svwrapper.param_table->Exist(*$1);
  if ( param ) {
    svwrapper.error(@$, "bit selection from parameter is not supported.");
  }
  else {
    CSymbol* symb = svwrapper.symbol_table->Insert(*$1);
    if ( $3->IsConst() ) {
      symb->Update($3);
    }
    else {
      ulonglong width = $3->Width();
      CNumber *num = new CNumber(Power(2, width)-1);
      symb->Update(num);
    }
    $$ = new CVariable ( symb, $3);
  }
}

| net_name
{  
  CParameter* param = svwrapper.param_table->Exist(*$1);
  if ( param ) {
    $$ = param;
  }
  else {
    CSymbol* symb = svwrapper.symbol_table->Insert(*$1);
    $$ = new CVariable ( symb );
  }
}
;


// net_lval : net 
// {
//   $1->Update(OUTPUT);
//   $$ = $1;
// }

// | "{" net_lvals "}" 
// {
//   $$ = new CConcatenation ($2);
// }
// ;



// net_lvals : net 
// {
//   $1->Update(OUTPUT);
//   $$ = new vector<CExpression*>;
//   $$->push_back($1);
// }

// | net_lvals "," net 
// {
//   $3->Update(OUTPUT);
//   $1->push_back($3);
//   $$ = $1;
// }
// ;


expression : constant 
{
  $$ = $1;
}

| net 
{
  $1->Update(INPUT);
  $$ = $1;
}

| concatenation
{
  $$ = $1;
}

| "{" expression concatenation "}"
{
  $$ = new CDupConcat ($2, $3);
}

| "(" expression ")" 
{
  $$ = new CParenthExp ($2);
}

| "|" expression %prec UNARY_OR
{
  $$ = new CUnaryExpOR ($2);
}

| "&" expression %prec UNARY_AND
{
  $$ = new CUnaryExpAND ($2);
}

| "^" expression %prec UNARY_XOR
{
  $$ = new CUnaryExpXOR ($2);
}

| "~" expression
{
  $$ = new CUnaryExpNOT ($2);
}

| expression "|" expression 
{
  $$ = new CBinExpOR ($1, $3);
}

| expression "&" expression 
{
  $$ = new CBinExpAND ($1, $3);
}

| expression "^" expression
{
  $$ = new CBinExpXOR ($1, $3);
}

| expression "+" expression
{
  $$ = new CBinExpADD ($1, $3);
}

| expression "-" expression 
{
  $$ = new CBinExpSUB ($1, $3);
}

| expression "*" expression
{
  $$ = new CBinExpMUL ($1, $3);
}

| expression "/" expression
{
  $$ = new CBinExpDIV ($1, $3);
}

| expression "%" expression
{
  $$ = new CBinExpMOD ($1, $3);
}

| expression "<<" expression 
{
  $$ = new CBinExpLSHFT ($1, $3);
}

| expression ">>" expression 
{
  $$ = new CBinExpRSHFT ($1, $3);
}

| expression "?" expression ":" expression 
{
  $$ = new CTrinaryExp ($1, $3, $5);
}

| "!" expression 
{
  $$ = new CCondExpNOT ($2);
}

| expression "||" expression 
{
  $$ = new CCondExpOR ($1, $3);
}

| expression "&&" expression
{
  $$ = new CCondExpAND ($1, $3);
}

| expression "<" expression
{
  $$ = new CCondExpLT ($1, $3);
}

| expression ">" expression
{
  $$ = new CCondExpGT ($1, $3);
}

| expression "==" expression 
{
  $$ = new CCondExpEQ ($1, $3);
}

| expression "!=" expression
{
  $$ = new CCondExpNE ($1, $3);
}

| expression ">=" expression
{
  $$ = new CCondExpGE ($1, $3);
}

| expression "<=" expression
{
  $$ = new CCondExpLE ($1, $3);
}
;

concatenation : "{" expressions "}"
{
  $$ = new CConcatenation ($2);
}
;

expressions : expression 
{
  $$ = new vector<CExpression*>;
  $$->push_back($1);
}

| expressions "," expression
{
  $1->push_back($3);
  $$ = $1;
}
;


/*******************************
   port_list
*******************************/
port_list : net_names 
| ansi_port_declarations
;


ansi_port_declarations : ansi_port_declaration
| ansi_port_declarations "," ansi_port_declaration
;

ansi_port_declaration : port_direction var_type_opt net_name
{
   CSymbol* symb = svwrapper.symbol_table->Insert( (*$3) );
   symb->io_fixed  = true;
   symb->direction = $1;
   symb->width_fixed = true;
   symb->msb         = CONST_NUM_0;

   if ( svwrapper.io_table->Exist((*$3)) ) {
      svwrapper.error(@$, "port " + (*$3) + " has already been declared." );
   }
   else {
      svwrapper.io_table->Insert(symb);
   }
}
| port_direction var_type_opt "[" expression ":" expression "]" net_name
{
  if ( !$6->IsConst() ) {
    svwrapper.error(@6, "non-constant LSB in port declaration.");
  }
  else if ( $6->Value() != 0 ) {
    svwrapper.warning(@5, "non-zero LSB can only confuse others, nothing more!");
  }
  else if ( ! $4->IsConst() ) {
     svwrapper.error(@4, "non-constant MSB in port declaration.");
  }
  else {
     CSymbol* symb = svwrapper.symbol_table->Insert( (*$8) );
     symb->io_fixed  = true;
     symb->direction = $1;
     symb->width_fixed = true;
     symb->msb         = $4;
     symb->lsb         = $6;

     if ( svwrapper.io_table->Exist((*$8)) ) {
	svwrapper.error(@$, "port " + (*$8) + " has already been declared." );
     }
     else {
	svwrapper.io_table->Insert(symb);
     }
  }
  
}
;

var_type_opt : 
| "reg"
| "wire"
;
 

/*******************************
        port_declaration
 *******************************/
port_declaration: port_direction var_type_opt net_names ";" 
{
  for ( vector<string>::iterator iter = $3->begin();
	iter != $3->end(); ++iter) {
    CSymbol* symb = svwrapper.symbol_table->Insert( (*iter) );
    symb->io_fixed  = true;
    symb->direction = $1;
    symb->width_fixed = true;
    symb->msb         = CONST_NUM_0;

    if ( svwrapper.io_table->Exist((*iter)) ) {
      svwrapper.error(@$, "port " + (*iter) + " has already been declared." );
    }
    else {
      svwrapper.io_table->Insert(symb);
    }
  }
}
| port_direction var_type_opt "[" expression ":" expression "]" net_names ";"
{
  if ( !$6->IsConst() ) {
    svwrapper.error(@6, "non-constant LSB in port declaration.");
  }
  else if ( $6->Value() != 0 ) {
     svwrapper.warning(@6, "non-zero LSB can only confuse others, nothing more!");
  }
  else if ( ! $4->IsConst() ) {
    svwrapper.error(@4, "non-constant MSB in port declaration.");
  }
  else {
    for ( vector<string>::iterator iter = $8->begin();
	  iter != $8->end(); ++iter) {
      CSymbol* symb = svwrapper.symbol_table->Insert( (*iter) );
      symb->io_fixed  = true;
      symb->direction = $1;
      symb->width_fixed = true;
      symb->msb         = $4;

      if ( svwrapper.io_table->Exist((*iter)) ) {
	svwrapper.error(@$, "port " + (*iter) + " has already been declared." );
      }
      else {
	svwrapper.io_table->Insert(symb);
      }
    }
  }
}
; 

net_names : net_name 
{
  $$ = new vector<string>;
  $$->push_back(*$1);
}
| net_names "," net_name
{
  $1->push_back(*$3);
  $$ = $1;
}
;


port_direction: "input" {$$ = INPUT;}
| "output"              {$$ = OUTPUT;}
| "inout"               {$$ = INOUT;}
| "nonport"             {$$ = NONPORT;}
;


/*******************************
     parameter_declaration
 ******************************/ 
parameter_keywords : "parameter"
{svwrapper.is_global_param = true;}

| "localparam"
{svwrapper.is_global_param = false;}
;


parameter_declaration : parameter_keywords parameter_assignments ";" 
| parameter_keywords "[" expression ":" expression "]" parameter_assignments ";" 
;

parameter_assignments : parameter_assignment
| parameter_assignments "," parameter_assignment
;

parameter_assignment : ID "=" expression 
{
  if ( svwrapper.param_table->Exist(*$1) ) {
    svwrapper.error(@1, "redefinition of parameter " + *$1);
  }
  else if ( svwrapper.symbol_table->Exist(*$1) ) {
    svwrapper.error(@1, *$1 + " has already been used as variable in your code.");
  }
  else if (!$3->IsConst()) {
    svwrapper.error(@3, "non-constant expression cannot be value of parameter.");
  }
  else {
    CParameter *param = new CParameter (*$1, $3, svwrapper.is_global_param);
    svwrapper.param_table->Insert(param);
  }
}
;



/*******************************
       line_directive
******************************/
line_directive: "`line" NUM STRING NL {
  CNumber *num = new CNumber (*$2);
  yylloc.begin.filename = yylloc.end.filename = $3;
  yylloc.end.lines( -yylloc.end.line + num->Value() );
  yylloc.step();
 }
;



%%


void 
yy::svParser::error(const yy::location &l, const string &s)
{
  svwrapper.error(l, s);
}
