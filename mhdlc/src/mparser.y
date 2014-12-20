%require "2.5"
%skeleton "lalr1.cc"
%glr-parser
%verbose
%error-verbose
%debug
%locations
%expect 1
%initial-action
{
  // Initialize the initial location.
  @$.begin.filename = @$.end.filename = &mwrapper.filename;
};
%defines
%define "parser_class_name" "mParser"
 // %name-prefix="mhdl"
%output="mparser.bison.cc"


%code requires{
#include <string>
#include <iostream>

class CMHDLwrapper;
#include "MetaHDL.hh"
extern bool FastDependParse;
extern int DebugMHDLParser;
extern string COMMAND;
extern list<string> PATHS;
extern string WORKDIR;
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
  CCaseType *case_type_ptr;
}



%parse-param {CMHDLwrapper &mwrapper}
%lex-param {CMHDLwrapper &mwrapper}

%{
  extern  yy::mParser::token::yytokentype mhdllex(yy::mParser::semantic_type *yylval, yy::mParser::location_type *yylloc, CMHDLwrapper &mwrapper);

  #define yylex mhdllex

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

 /* MetaHDL keywords */
%token K_METAHDL       "metahdl"
%token K_NONPORT       "nonport"
%token K_FF	       "ff"	      
%token K_ENDFF	       "endff"	      
%token K_FSM	       "fsm"	      
%token K_FSM_NC        "fsm_nc"	      
%token K_ENDFSM	       "endfsm"     
%token K_GOTO          "goto" 
%token K_RAWCODE       "rawcode"
%token K_ENDRAWCODE    "endrawcode" 
%token K_MESSAGE       "message"
%token K_PARSE         "parse"



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
%token PUNC_AT        "@"


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

%type <str> verbtims
%type <str> net_name instance_name
%type <str_vct>  net_names
%type <expression_ptr> expression  net_lval
%type <concat_exp_ptr> concatenation
%type <exp_vct>  net_lvals expressions parameter_num_override
%type <constant_ptr> constant
%type <stmt_ptr> statement balanced_stmt unbalanced_stmt case_statement
%type <stmt_vct> statements
%type <expression_ptr> net
%type <case_type_ptr> case_type
%type <case_item_vct> case_items
%type <case_item_ptr> case_item
%type <port_type> port_direction
%type <var_type> variable_type
%type <blk_ptr> assign_block combinational_block ff_block inst_block legacyff_block
%type <ff_item_ptr> ff_item
%type <ff_item_vct> ff_items
%type <state_item_ptr> fsm_item
%type <state_item_vct> fsm_items
%type <fsm_blk_ptr> fsm_block
%type <raw_code_ptr> rawcode_block
%type <param_rule_ptr> parameter_rule



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


start: {mwrapper.module_location = @$;}
| start port_declaration  {mwrapper.module_location = @$;}
| start parameter_declaration {mwrapper.module_location = @$;}
| start constant_declaration
| start variable_declaration {mwrapper.module_location = @$;}
// | start line_directive {mwrapper.module_location = @$;}
| start assign_block {mwrapper.module_location = @$; mwrapper.code_blocks->push_back($2);}
| start combinational_block {mwrapper.module_location = @$; mwrapper.code_blocks->push_back($2);}
| start legacyff_block {mwrapper.module_location = @$, mwrapper.code_blocks->push_back($2);}
| start ff_block {mwrapper.module_location = @$; mwrapper.code_blocks->push_back($2);}
| start fsm_block {mwrapper.module_location = @$; mwrapper.code_blocks->push_back($2);}
| start inst_block {mwrapper.module_location = @$; mwrapper.code_blocks->push_back($2);}
| start rawcode_block {mwrapper.module_location = @$; mwrapper.code_blocks->push_back($2);}
| start metahdl_constrol {mwrapper.module_location = @$;}
;

/* body: port_declaration  */
/* | parameter_declaration */
/* | constant_declaration */
/* | variable_declaration */
/* | line_directive */
/* | assign_block */
/* | combinational_block */
/* | ff_block */
/* | fsm_block */
/* | inst_block */
/* | rawcode_block */
/* ; */


constant : STRING
{
  $$ = new CString (*$1);
}

| NUM   
{ 
  $$ = new CNumber (*$1);
}

| BIN_BASED_NUM 
{
  try{ $$ = new CBasedNum(*$1, 2);}
  catch (string &str) {mwrapper.error(@1, str);}
}
    
| DEC_BASED_NUM 
{ 
  try{ $$ = new CBasedNum(*$1, 10);}
  catch (string &str) {mwrapper.error(@1, str);}
}

| HEX_BASED_NUM 
{
  try{ $$ = new CBasedNum(*$1, 16);}
  catch (string &str) {mwrapper.error(@1, str);}
}
;



net_name : ID {$$ = $1;}
;



net : net_name "[" expression ":" expression "]" 
{
  CParameter* param = mwrapper.param_table->Exist(*$1);
  if ( param ) {
    mwrapper.error(@$, "segment selection from parameter is not supported.");
  }
  else {
    if ( $3->IsConst() && $5->IsConst() ) {
       $3->Update(INPUT);
       $3->AddRoccure(@3);
       $5->Update(INPUT);
       $5->AddRoccure(@5);

      CSymbol* symb = mwrapper.symbol_table->Insert(*$1);
      if ( $3->Value() >= symb->msb->Value() ) {
	if ( !symb->Update($3) ) {
	  mwrapper.error(@3, "MSB exceed fixed value, check your declaration.");
	}
      }

      if ( $3->Value() < symb->lsb->Value() ) {
	if ( !symb->UpdateLSB($3) ) {
	  mwrapper.error(@3, "LSB exceed fixed value, check your declaration.");
	}
      }

      if ( !LEGACY_VERILOG_MODE ) {
	symb->Update(LOGIC);
      }
      $$ = new CVariable ( symb, $3, $5);
    }
    else {
      mwrapper.error(@$, "non-constant segment selection boundary.");
    }
  }
}

| net_name "[" expression "]" 
{
  CParameter* param = mwrapper.param_table->Exist(*$1);
  if ( param ) {
    mwrapper.error(@$, "bit selection from parameter is not supported.");
  }
  else {
    CSymbol* symb = mwrapper.symbol_table->Insert(*$1);
    if ( $3->IsConst() ) {
      if ( symb->is_2D ) {
	if ( $3->Value() > symb->length_msb->Value() ) {
	  ostringstream msg;
	  msg << symb->name << " "
	      << "First index of 2D array out of range, "
	      << $3->Value() << ">" << symb->length_msb->Value() << ", "
	      << "check your declaration." << endl;
	  mwrapper.error(@3, msg.str());
	}
      }
      else {
	if ( $3->Value() > symb->msb->Value() ) {
	  if ( !symb->Update($3) ) {
	    mwrapper.error(@3, "Bit index out of MSB range, check your declaration.");
	  }
	}
	if ( $3->Value() < symb->lsb->Value() ) {
	  if ( !symb->UpdateLSB($3) ) {
	    mwrapper.error(@3, "Bit index out of LSB range, check your declaration.");
	  }
	}
      }
    }
    else {
      $3->Update(INPUT);
      $3->AddRoccure(@3);

      ulonglong width = $3->Width();
      CNumber *num = new CNumber(Power(2, width)-1);
      if ( symb->is_2D ) {
	if ( num->Value() > symb->length_msb->Value() ) {
	  ostringstream msg;
	  msg << symb->name << " "
	      << "Non-constant first index of 2D array could be out of range, "
	      << num->Value() << ">" << symb->length_msb->Value() << ", "
	      << "check your declaration." << endl;
	  mwrapper.warning(@3, msg.str());
	}
      }
      else {
	if ( num->Value() >= symb->msb->Value() ) {
	  if ( !symb->Update(num) ) {
	    mwrapper.warning(@3, "Bit index could be out of range, confirm with your declaration.");
	  }
	}
      }
    }
    if ( !LEGACY_VERILOG_MODE ) {
      symb->Update(LOGIC);
    }
    $$ = new CVariable ( symb, $3);
  }
}

| net_name "[" expression "]" "[" expression "]"
{
   CSymbol *symb = mwrapper.symbol_table->Insert( *$1 );
   if ( ! symb->is_2D ) {
      mwrapper.error(@$, "2-D array syntax used, but variable is ordinary net." );
   }
   else {
      $3->Update(INPUT);
      $3->AddRoccure(@3);
      $6->Update(INPUT);
      $6->AddRoccure(@6);

      if ( ! $3->IsConst() ) {
	ulonglong width = $3->Width();
	CNumber *num = new CNumber(Power(2, width)-1);
	if ( num->Value() > symb->length_msb->Value()) {
	  ostringstream msg;
	  msg << symb->name
	      << ", Non constant for 1st index in 2-D arrary, could be out of range, " 
	      << num->Value() << " > " << symb->length_msb->Value();
	  
	  mwrapper.warning( @3, msg.str() );
	}
      }
      else {
	 if ( $3->Value() > symb->length_msb->Value() ) {
	    mwrapper.error( @3, "1st index of 2-D arrary out-of-range.");
	 }
      }
      if ( ! $6->IsConst() ) {
	 mwrapper.warning( @6, "Non constant for 2nd index in 2-D arrary, could be out of range." );
      }
      else {
	 if ( $6->Value() > symb->msb->Value() ) {
	    mwrapper.error( @6, "2nd index of 2-D arrary out-of-range.");	    
	 }
      }

      if ( !LEGACY_VERILOG_MODE ) {
	symb->Update(LOGIC);
      }
      $$ = new CVariable (true, symb, $3, $6);
   }
}

//   1      2      3       4   5      6       7      8
| net_name "[" expression "]" "[" expression ":" expression "]"
{
   CSymbol *symb = mwrapper.symbol_table->Insert( *$1 );
   if ( ! symb->is_2D ) {
      mwrapper.error(@$, "2-D array syntax used, but variable is ordinary net." );
   }
   else {
      $3->Update(INPUT);
      $3->AddRoccure(@3);
      $6->Update(INPUT);
      $6->AddRoccure(@6);
      $8->Update(INPUT);
      $8->AddRoccure(@8);

      if ( ! $3->IsConst() ) {
	ulonglong width = $3->Width();
	CNumber *num = new CNumber(Power(2, width)-1);

	if ( num->Value() > symb->length_msb->Value()) {
	  ostringstream msg;
	  msg << symb->name
	      << ", Non constant for 1st index in 2-D arrary, could be out of range, " 
	      << num->Value() << " > " << symb->length_msb->Value();
	  
	  mwrapper.warning( @3, msg.str() );
	}
      }
      else {
	 if ( $3->Value() > symb->length_msb->Value() ) {
	    mwrapper.error( @3, "1st index of 2-D arrary out-of-range.");
	 }
      }

      if ( ! $6->IsConst() ) {
	 mwrapper.error( @6, "Variable segment selection of in 2-D arrary is not allowed." );
      }
      else {
	 if ( $6->Value() > symb->msb->Value() ) {
	    mwrapper.error( @6, "2nd index of 2-D arrary out-of-range.");	    
	 }
      }
      if ( ! $8->IsConst() ) {
	 mwrapper.error( @8, "Variable segment selection of in 2-D arrary is not allowed." );
      }
      else {
	 if ( $8->Value() > symb->msb->Value() ) {
	    mwrapper.error( @8, "2nd index of 2-D arrary out-of-range.");
	 }
      }

      if ( !LEGACY_VERILOG_MODE ) {
	symb->Update(LOGIC);
      }
      $$ = new CVariable (true, symb, $3, $6, $8);
   }
}

| net_name
{  
  CParameter* param = mwrapper.param_table->Exist(*$1);
  if ( param ) {
    $$ = param;
  }
  else {
    CSymbol* symb = mwrapper.symbol_table->Insert(*$1);

    if ( !LEGACY_VERILOG_MODE ) {
      symb->Update(LOGIC);
    }
    $$ = new CVariable ( symb );
  }
}
;


net_lval : net 
{
  $1->Update(OUTPUT);
  $1->AddLoccure(@1);
  $$ = $1;
}

| "{" net_lvals "}" 
{
  $$ = new CConcatenation ($2);
}
;



net_lvals : net 
{
  $1->Update(OUTPUT);
  $1->AddLoccure(@1);
  $$ = new vector<CExpression*>;
  $$->push_back($1);
}

| net_lvals "," net 
{
  $3->Update(OUTPUT);
  $3->AddLoccure(@3);
  $1->push_back($3);
  $$ = $1;
}
;


expression : constant 
{
  $$ = $1;
}

| net 
{
//   $1->Update(INPUT);
//   $1->AddRoccure(@1);
  $$ = $1;
}

| concatenation
{
  $$ = $1;
}

| net_name "(" expressions ")" 
{
   $$ = new CFuncCallExp ( *$1, $3);
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


statement : balanced_stmt 
{
  $$ = $1;
}

| unbalanced_stmt 
{
  $$ = $1;
}
;

balanced_stmt : ";" 
{
   $$ = new CStmtSimple ();
   if (DebugMHDLParser) 
     mwrapper.warning(@$, "Why do you write empty statment? You stupid asshole think it's funny?? I'll tell you, it's totally SHIT!!");
}

//  1    2     3      4      5       6       7      8     9      10     11     12     13
| "for" "(" net_lval "=" expression ";" expression ";" net_lval "=" expression ")" statement
{
  $5->Update(INPUT);
  $5->AddRoccure(@5);
  
  $7->Update(INPUT);
  $7->AddRoccure(@6);

  $11->Update(INPUT);
  $11->AddRoccure(@11);

  $$ = new CStmtFOR( $3, $5, $7, $9, $11, $13);
  // mwrapper.warning(@$, "for-statment is now weakly supported in MetaHDL, better to use proprocessing directive `for.");
}

| "begin" "end" 
{
   $$ = new CStmtSimple ();
   mwrapper.warning(@$, "Why do you write empty statment? You stupid asshole think it's funny?? I'll tell you, it's totally SHIT!!");
}

| net_lval "<=" expression ";" 
{
  $3->Update(INPUT);
  $3->AddRoccure(@3);
  if ( LEGACY_VERILOG_MODE ) {
    $1->Update(REG);
  }

  if ( ! mwrapper.in_sequential ) {
    mwrapper.error(@$, "Nonblocking assignment is NOT allowed in combnational block.");
  }

  if ( $1->Width() < $3->Width() ) {
    mwrapper.warning(@$, "Width mismatch in non-blocking assignment.");
  }
  $$ = new CStmtSimple ($1, $3, false);
}

| net_lval "=" expression ";"
{
  $3->Update(INPUT);
  $3->AddRoccure(@3);
  if ( LEGACY_VERILOG_MODE ) {
    $1->Update(REG);
  }

  if ( mwrapper.in_sequential ) {
    mwrapper.error(@$, "Blocking assignment is NOT allowed in sequential block.");
  }

  if ( $1->Width() < $3->Width() ) {
    mwrapper.warning(@$, "Width mismatch in blocking assignment.");
  }
  $$ = new CStmtSimple ($1, $3);
}

| "begin" statements "end" 
{
    $$ = new CStmtBunch ($2, true);
}

| "begin" ":" ID statements "end" 
{
    $$ = new CStmtBunch ($4, true, *$3);
}

| "if" "(" expression ")" balanced_stmt "else" balanced_stmt
{
  $3->Update(INPUT);
  $3->AddRoccure(@3);

  $$ = new CStmtIF ($3, $5, $7);
}

| case_statement
{
  $$ = $1;
}

| "goto" ID ";" 
{
  if ( !mwrapper.in_fsm ) {
    mwrapper.error(@$, "goto statement can only be used in fsm block.");
  }
  else {
    CSymbol* ns_symb = mwrapper.symbol_table->Exist( mwrapper.fsm_name + "_ns" );
    if ( !ns_symb ) mwrapper.error(@$, "XX_cs and XX_ns variables should be ready now for FSM " + mwrapper.fsm_name );
    
    CVariable* ns_var = new CVariable (ns_symb);
    CSymbol* ns_name  = mwrapper.symbol_table->Insert(*$2);
    $$ = new CStmtSimple(ns_var, new CVariable (ns_name) );
    
    map<string, CStTransition*> *graph = mwrapper.state_graph;
    (*graph)[mwrapper.state_name]->to.insert(*$2);
    if ( graph->count(*$2) == 0 ) (*graph)[*$2] = new CStTransition;
    (*graph)[*$2]->from.insert(mwrapper.state_name);
  }
}
;

unbalanced_stmt : "if" "(" expression ")" statement
{
  $3->Update(INPUT);
  $3->AddRoccure(@3);

  $$ = new CStmtIF ($3, $5);
}

| "if" "(" expression ")" balanced_stmt "else" unbalanced_stmt
{
  $3->Update(INPUT);
  $3->AddRoccure(@3);

  $$ = new CStmtIF ($3, $5, $7);
}
;

statements : statement
{
  $$ = new vector<CStatement*>;
  $$->push_back($1);
}

| statements statement
{
  $1->push_back($2);
  $$ = $1;
}
;

case_statement : case_type "(" expression ")" case_items "endcase" 
{
  $3->Update(INPUT);
  $3->AddRoccure(@3);

  $$ = new CStmtCASE ($1, $3, $5);
}

| case_type "(" expression ")" case_items "default" ":" statement "endcase"
{
  $3->Update(INPUT);
  $3->AddRoccure(@3);

  $$ = new CStmtCASE ($1, $3, $5, $8);
}
;

case_type : "case"   {$$ = new CCaseType (); }
| "casez"            {$$ = new CCaseType ("", true); }
| "unique" "case"    {$$ = new CCaseType ("unique", false); }
| "unique" "casez"   {$$ = new CCaseType ("unique", true); }
| "priority" "case"  {$$ = new CCaseType ("priority", false); }
| "priority" "casez" {$$ = new CCaseType ("priority", true); }
;

case_items : case_item
{
  $$ = new vector<CCaseItem*>;
  $$->push_back($1);
}

| case_items case_item 
{
  $1->push_back($2);
  $$ = $1;
}
;

case_item : expressions ":" statement
{
  for (vector<CExpression*>::iterator iter = $1->begin();
       iter != $1->end(); ++iter) {
    (*iter)->Update(INPUT);
    (*iter)->AddRoccure(@1);
  }

  $$ = new CCaseItem ($1, $3);
}
;

/*******************************
        port_declaration
 *******************************/
port_declaration: port_direction net_names ";" 
{
  for ( vector<string>::iterator iter = $2->begin();
	iter != $2->end(); ++iter) {
    CSymbol* symb = mwrapper.symbol_table->Insert( (*iter) );
    symb->io_fixed  = true;
    symb->direction = $1;
    // symb->width_fixed = true;
    symb->Update( CONST_NUM_0 );

    if ( mwrapper.io_table->Exist((*iter)) ) {
      mwrapper.error(@$, "port " + (*iter) + " has already been declared." );
    }
    else {
      if ( $1 != NONPORT ) {
	mwrapper.io_table->Insert(symb);
      }
    }
  }
}
| port_direction "[" expression ":" expression "]" net_names ";"
{
  if ( ! $3->IsConst() ) {
    mwrapper.error(@3, "non-constant MSB in port declaration.");
  }
  else if ( !$5->IsConst() ) {
    mwrapper.error(@5, "non-constant LSB in port declaration.");
  }
  else {
    if ( $5->Value() != 0 ) {
      mwrapper.warning(@5, "non-zero LSB in port declaration.");
    }

    $3->Update(INPUT);
    $3->AddRoccure(@3);
    $5->Update(INPUT);
    $5->AddRoccure(@5);
    
    for ( vector<string>::iterator iter = $7->begin();
	  iter != $7->end(); ++iter) {
      CSymbol* symb = mwrapper.symbol_table->Insert( (*iter) );
      symb->io_fixed  = true;
      symb->direction = $1;
      if ( !symb->Update( $3 ) ) {
	mwrapper.error(@$, "port " + (*iter) + "'s MSB is smaller than that in code, or MSB is locked.");
      }
      if ( !symb->UpdateLSB( $5 ) ) {
	mwrapper.error(@$, "port " + (*iter) + "'s LSB is larger than that in code, or LSB is fixed.");
      }

      symb->width_fixed = true;

      if ( mwrapper.io_table->Exist((*iter)) ) {
	mwrapper.error(@$, "port " + (*iter) + " has already been declared." );
      }
      else {
	if ( $1 != NONPORT ) {
	  mwrapper.io_table->Insert(symb);
	}
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
parameter_declaration : "parameter" {mwrapper.is_global_param=true;} parameter_assignments ";" 
| "localparam" {mwrapper.is_global_param=false;} parameter_assignments ";"
;

parameter_assignments : parameter_assignment
| parameter_assignments "," parameter_assignment
;

parameter_assignment : ID "=" expression 
{
  if ( mwrapper.param_table->Exist(*$1) ) {
    mwrapper.error(@1, "redefinition of parameter " + *$1);
  }
  else if ( mwrapper.symbol_table->Exist(*$1) ) {
    mwrapper.error(@1, *$1 + " has already been used as variable in your code.");
  }
  else if (!$3->IsConst()) {
    mwrapper.error(@3, "non-constant expression cannot be value of parameter.");
  }
  else {
    $3->Update(INPUT);
    $3->AddRoccure(@3);

    CParameter *param = new CParameter (*$1, $3, mwrapper.is_global_param);
    mwrapper.param_table->Insert(param);
  }
}
;



/*******************************
     constant_declaration
 ******************************/ 
constant_declaration : "const" variable_type net_name "=" expression ";"
{
  if ( ! $5->IsConst() ) {
    mwrapper.error(@5, "non-constant value for const variable.");
  }

  $5->Update(INPUT);
  $5->AddRoccure(@5);

  CSymbol *symb = mwrapper.symbol_table->Insert( (*$3) );
  symb->is_const = true;
  symb->value = $5;
  symb->type = $2;

}

| "const" variable_type "[" expression ":" expression "]" net_name "=" expression ";"
  // 1      2            3   4          5    6         7    8       9   10
{
  if ( !$4->IsConst() ) {
    mwrapper.error(@4, "non-constant value in MSB.");
  }
  if (!$6->IsConst() ) {
    mwrapper.error(@6, "non-constant value in LSB.");
  }
  if ( !$10->IsConst() ) {
    mwrapper.error(@10, "non-constant vlaue for const variable.");
  }
  
  $4->Update(INPUT);
  $4->AddRoccure(@4);
  $6->Update(INPUT);
  $6->AddRoccure(@6);
  $10->Update(INPUT);
  $10->AddRoccure(@10);

  CSymbol *symb = mwrapper.symbol_table->Insert( (*$8) );
  symb->is_const = true;
  symb->value = $10;
  symb->Update($4);
  symb->type = $2;

}
;


/*******************************
    variable_declaration
 ******************************/
variable_declaration : variable_type net_names ";"
{
  for (vector<string>::iterator iter = $2->begin();
       iter != $2->end(); ++iter) {
    CSymbol *symb = mwrapper.symbol_table->Insert( (*iter) );
    symb->type = $1;
    symb->type_fixed = true;
    symb->width_fixed = true;
    symb->msb         = CONST_NUM_0;
  }
}

| variable_type "[" expression ":" expression "]" net_names ";"
{
  if ( ! $3->IsConst() ) {
    mwrapper.error(@3, "non-constant MSB in varialbe declaration.");
  }
  else if ( !$5->IsConst()  ) {
    mwrapper.error(@5, "non-constant or non-zero LSB in variable declaration.");
  }
  else {
    if ( $5->Value() != 0 ) {
      mwrapper.warning(@5, "non-zero LSB in variable declaration.");
    }

    $3->Update(INPUT);
    $3->AddRoccure(@3);
    $5->Update(INPUT);
    $5->AddRoccure(@5);

    for ( vector<string>::iterator iter = $7->begin();
	  iter != $7->end(); ++iter) {
      CSymbol* symb = mwrapper.symbol_table->Insert( (*iter) );
      symb->type = $1;
      symb->type_fixed = true;
      symb->width_fixed = true;
      symb->msb         = $3;
      symb->lsb         = $5;
    }
  }
}

| variable_type net_names "[" expression ":" expression "]" ";"
{
  if ( !$6->IsConst() || $6->Value() != 0 ) {
    mwrapper.error(@6, "non-constant or non-zero LSB in 2D-array declaration.");
  }
  else if ( ! $4->IsConst() ) {
    mwrapper.error(@4, "non-constant MSB in 2D-array declaration.");
  }
  else {
    $4->Update(INPUT);
    $4->AddRoccure(@4);
    $6->Update(INPUT);
    $6->AddRoccure(@6);
    
    for (vector<string>::iterator iter = $2->begin();
	 iter != $2->end(); ++iter) {
      CSymbol *symb = mwrapper.symbol_table->Insert( (*iter) );
      symb->direction = NONPORT;
      symb->io_fixed  = true;
      symb->is_2D = true;
      symb->length_msb = $4;
      symb->type = $1;
      symb->type_fixed = true;
      symb->width_fixed = true;
      symb->msb         = CONST_NUM_0;
    }
  }
}

| variable_type "[" expression ":" expression "]" net_names "[" expression ":" expression "]" ";" 
{
  if ( ! $3->IsConst() ) {
    mwrapper.error(@3, "non-constant MSB in varialbe declaration.");
  }
  else if ( !$5->IsConst()  ) {
    mwrapper.error(@5, "non-zero/non-constant LSB in variable declaration.");
  }
  else if ( ! $9->IsConst() ) {
    mwrapper.error(@9, "non-constant MSB in 2D-array declaration.");
  }
  else if ( !$11->IsConst()  ) {
    mwrapper.error(@11, "non-constant LSB in 2D-array declaration.");
  }
  else if ( $11->Value() != 0 ) {
    mwrapper.error(@11, "non-zero LSB in 2D-array declaration.");
  }
  else {
    if ( $5->Value() != 0 ) {
      mwrapper.warning(@5, "non-zero LSB in variable declaration.");
    }

    $3->Update(INPUT);
    $3->AddRoccure(@3);
    $5->Update(INPUT);
    $5->AddRoccure(@5);
    $9->Update(INPUT);
    $9->AddRoccure(@9);
    $11->Update(INPUT);
    $11->AddRoccure(@11);

    for (vector<string>::iterator iter = $7->begin();
	 iter != $7->end(); ++iter) {
      CSymbol *symb = mwrapper.symbol_table->Insert( (*iter) );
      symb->direction = NONPORT;
      symb->io_fixed  = true;
      symb->is_2D = true;
      symb->length_msb = $9;
      symb->type = $1;
      symb->type_fixed = true;
      symb->width_fixed = true;
      symb->msb         = $3;
      symb->lsb         = $5;
    }
  }
}
;

variable_type : "wire" {$$ = WIRE;}
| "reg" {$$ = REG;}
| "logic"             {$$ = LOGIC;}
| "int"               {$$ = INT;}
| "integer"           {$$ = INTEGER;}
;

/* /\******************************* */
/*        line_directive */
/* ******************************\/ */
/* line_directive: "`line" NUM STRING NL { */
/*   CNumber *num = new CNumber (*$2); */
/*   yylloc.begin.filename = yylloc.end.filename = $3; */
/*   yylloc.end.lines( -yylloc.end.line + num->Value() ); */
/*   yylloc.step(); */
/*  } */
/* ; */


/*******************************
      assign_block
******************************/ 
assign_block : "assign" net_lval "=" expression ";" 
{
  if ( $2->Width() < $4->Width() ) {
    mwrapper.warning(@$, "Width mismatch in assign statement.");
  }

  $4->Update(INPUT);
  $4->AddRoccure(@4);

  $$ = new CBlkAssign (@$, new CStmtSimple ($2, $4));
  $$->GetSymbol();
  $$->SetDriver();
}
;

/*******************************
    legacyff_block
*******************************/
always_keyword : "always" 
| "always_ff"
;

//                     1         2   3      4       5       6     7        8        9    10                              11
legacyff_block : always_keyword "@" "(" "posedge" net_name "or" "negedge" net_name ")" {mwrapper.in_sequential = true;} statement 
{
   CSymbol *clk = mwrapper.symbol_table->Insert( *$5 );
   clk->Update(INPUT);
   clk->roccur.push_back(@5);

   CSymbol *rst = mwrapper.symbol_table->Insert( *$8 );
   rst->Update(INPUT);
   rst->roccur.push_back(@8);

   $$ = new CBlkLegacyFF (@$, clk, rst, $11);
   $$->GetSymbol();
   $$->SetDriver();

   mwrapper.in_sequential = false;
}
//      1         2   3      4        5      6            7                        8
| always_keyword "@" "(" "posedge" net_name ")" {mwrapper.in_sequential = true;} statement
{
   CSymbol *clk = mwrapper.symbol_table->Insert( *$5 );
   clk->Update(INPUT);
   clk->roccur.push_back(@5);

   $$ = new CBlkLegacyFF (@$, clk, $8);
   $$->GetSymbol();
   $$->SetDriver();

   mwrapper.in_sequential =false;
}
;

/*******************************
     combinational_block
******************************/
combinational_block : "always_comb" statement
{
  $$ = new CBlkComb (@$, $2);
  $$->GetSymbol();
  $$->SetDriver();
}
; 


/*******************************
       ff_block
 ******************************/
ff_block : "ff" ID ";" ff_items "endff"
{
  CSymbol *clk = mwrapper.symbol_table->Insert(*$2);
  clk->Update(INPUT);
  if ( !LEGACY_VERILOG_MODE ) clk->Update(LOGIC);
  clk->roccur.push_back(@2);
  $$ = new CBlkFF (@$, clk, $4);

  $$->GetSymbol();
  $$->SetDriver();
}

| "ff" ID "," ID ";" ff_items "endff"
{
  CSymbol *clk = mwrapper.symbol_table->Insert(*$2);
  clk->Update(INPUT);
  if ( !LEGACY_VERILOG_MODE ) clk->Update(LOGIC);
  clk->roccur.push_back(@2);

  CSymbol *rst = mwrapper.symbol_table->Insert(*$4);
  rst->Update(INPUT);
  if ( !LEGACY_VERILOG_MODE ) rst->Update(LOGIC);
  rst->roccur.push_back(@4);

  $$ = new CBlkFF (@$, clk, rst, $6);
  $$->GetSymbol();
  $$->SetDriver();
}

| "ff" ";" ff_items "endff"
{
  CSymbol *clk = mwrapper.symbol_table->Insert(mwrapper.mctrl["clock"]->str);
  clk->Update(INPUT);
  if ( !LEGACY_VERILOG_MODE ) clk->Update(LOGIC);
  clk->roccur.push_back(@1);

  CSymbol *rst = mwrapper.symbol_table->Insert(mwrapper.mctrl["reset"]->str);
  rst->Update(INPUT);
  if ( !LEGACY_VERILOG_MODE ) rst->Update(LOGIC);
  rst->roccur.push_back(@1);
  $$ = new CBlkFF (@$, clk, rst, $3);
  $$->GetSymbol();
  $$->SetDriver();
}
;

ff_items : ff_item 
{
  $$ = new vector<CFFItem*>;
  $$->push_back($1);
}

| ff_items ff_item 
{
  $1->push_back($2);
  $$ = $1;
}
;

ff_item : net_lval "," expression "," expression ";" 
{
  if ( $1->Width() != $3->Width() ) {
    mwrapper.warning(@$, "Width mismatch between FF src and dst.");
  }
  if ( $1->Width() != $5->Width() ) {
    mwrapper.warning(@$, "Width mismatch between FF and reset value.");
  }
  if ( !$5->IsConst() ) {
    mwrapper.error(@5, "non-constant expression as reset value.");
  }
  else {
    $3->Update(INPUT);
    $3->AddRoccure(@3);
    $5->Update(INPUT);
    $5->AddRoccure(@5);
    $1->Update(REG);

    $$ = new CFFItem ($1, $3, $5);
  }
}

| net_lval "," expression ";"
{
  if ( $1->Width() != $3->Width() ) {
    mwrapper.warning(@$, "Width mismatch between FF src and dst.");
  }

  $1->Update(REG);
  $3->Update(INPUT);
  $3->AddRoccure(@3);

  $$ = new CFFItem ($1, $3);
}
;


/*******************************
     fsm_block
 ******************************/
fsm_keyword : "fsm" {mwrapper.fsm_nc = false;}
| "fsm_nc" {mwrapper.fsm_nc = true;}
;

fsm_header : fsm_keyword ID ";"
{
    mwrapper.in_fsm = true; 
    mwrapper.state_graph = new map<string, CStTransition*>;
    mwrapper.fsm_name = *$2;
    mwrapper.fsm_clk_name = mwrapper.mctrl["clock"]->str;
    mwrapper.fsm_clk = mwrapper.symbol_table->Insert(mwrapper.fsm_clk_name);
    mwrapper.fsm_clk->Update(INPUT);
    if ( !LEGACY_VERILOG_MODE ) mwrapper.fsm_clk->Update(LOGIC);
    mwrapper.fsm_clk->roccur.push_back(@2);

    mwrapper.fsm_rst_name = mwrapper.mctrl["reset"]->str;
    mwrapper.fsm_rst = mwrapper.symbol_table->Insert(mwrapper.fsm_rst_name);
    mwrapper.fsm_rst->Update(INPUT);
    if ( !LEGACY_VERILOG_MODE ) mwrapper.fsm_rst->Update(LOGIC);
    mwrapper.fsm_rst->roccur.push_back(@2);
}

| fsm_keyword ID "," ID "," ID ";"
{
    mwrapper.in_fsm = true; 
    mwrapper.state_graph = new map<string, CStTransition*>;
    mwrapper.fsm_name = *$2;
    mwrapper.fsm_clk_name = *$4;
    mwrapper.fsm_clk = mwrapper.symbol_table->Insert(mwrapper.fsm_clk_name);
    mwrapper.fsm_clk->Update(INPUT);
    if ( !LEGACY_VERILOG_MODE ) mwrapper.fsm_clk->Update(LOGIC);
    mwrapper.fsm_clk->roccur.push_back(@4);

    mwrapper.fsm_rst_name = *$6;
    mwrapper.fsm_rst = mwrapper.symbol_table->Insert(mwrapper.fsm_rst_name);
    mwrapper.fsm_rst->Update(INPUT);
    if ( !LEGACY_VERILOG_MODE ) mwrapper.fsm_rst->Update(LOGIC);
    mwrapper.fsm_rst->roccur.push_back(@6);
}
;

fsm_block : fsm_header 
            // 1
{
  CSymbol *symb = mwrapper.symbol_table->Insert( mwrapper.fsm_name + "_cs"); 
  if ( LEGACY_VERILOG_MODE ) {
    symb->Update(REG);
  }
  else {
    symb->Update(LOGIC);
  }
  symb->Update(NONPORT);
  symb->io_fixed = true;

  symb = mwrapper.symbol_table->Insert( mwrapper.fsm_name + "_ns");
  if ( LEGACY_VERILOG_MODE ) {
    symb->Update(REG);
  }
  else {
    symb->Update(LOGIC);
  }
  symb->Update(NONPORT);
  symb->io_fixed = true;
} // 2
statements fsm_items "endfsm" 
// 3         4         5
{
  CStmtBunch *stmts = new CStmtBunch ($3);
  $$ = new CBlkFSM (@$, mwrapper.fsm_name, mwrapper.fsm_nc, 
                    mwrapper.fsm_clk, mwrapper.fsm_rst, 
                    mwrapper.state_graph, stmts, $4);
  try { $$->CheckFSM(); }
  catch (string &str) {
    if ( mwrapper.mctrl["relaxedfsm"]->flag ) 
      mwrapper.warning(@$, str);
    else 
      mwrapper.error(@$, str);
  }

  $$->BuildFSM(mwrapper.symbol_table);

  $$->GetSymbol();
  $$->SetDriver();

  mwrapper.state_graph = NULL;
  mwrapper.in_fsm = false;
}
;

// fsm_block : fsm_keyword ID "," ID "," ID ";" 
// //            1   2   3  4   5  6   7
// {
//   mwrapper.in_fsm = true; 
//   mwrapper.state_graph = new map<string, CStTransition*>;

//   mwrapper.fsm_name=*$2; 
//   CSymbol *symb = mwrapper.symbol_table->Insert( *$2 + "_cs"); 
//   if ( LEGACY_VERILOG_MODE ) {
//     symb->Update(REG);
//   }
//   else {
//     symb->Update(LOGIC);
//   }
//   symb->Update(NONPORT);
//   symb->io_fixed = true;

//   symb = mwrapper.symbol_table->Insert( *$2 + "_ns");
//   if ( LEGACY_VERILOG_MODE ) {
//     symb->Update(REG);
//   }
//   else {
//     symb->Update(LOGIC);
//   }
//   symb->Update(NONPORT);
//   symb->io_fixed = true;
// } // 8
// // 9         10        11
// statements fsm_items "endfsm" 
// {
//   CSymbol *clk = mwrapper.symbol_table->Insert(*$4);
//   clk->Update(INPUT);
//   if ( !LEGACY_VERILOG_MODE ) clk->Update(LOGIC);
//   clk->roccur.push_back(@4);

//   CSymbol *rst = mwrapper.symbol_table->Insert(*$6);
//   rst->Update(INPUT);
//   if ( !LEGACY_VERILOG_MODE ) rst->Update(LOGIC);
//   rst->roccur.push_back(@6);
  
//   CStmtBunch *stmts = new CStmtBunch ($9);
//   $$ = new CBlkFSM (@$, *$2, clk, rst, mwrapper.state_graph, stmts, $10);
//   try { $$->CheckFSM(); }
//   catch (string &str) {
//     if ( mwrapper.mctrl["relaxedfsm"]->flag ) 
//       mwrapper.warning(@$, str);
//     else 
//       mwrapper.error(@$, str);
//   }

//   $$->BuildFSM(mwrapper.symbol_table);

//   $$->GetSymbol();
//   $$->SetDriver();

//   mwrapper.state_graph = NULL;
//   mwrapper.in_fsm = false;
// }

// | fsm_keyword ID ";" 
//   // 1   2  3
// {
//   mwrapper.in_fsm = true; 
//   mwrapper.state_graph = new map<string, CStTransition*>;

//   mwrapper.fsm_name=*$2; 
//   CSymbol *symb = mwrapper.symbol_table->Insert( *$2 + "_cs"); 
//   if ( LEGACY_VERILOG_MODE ) {
//     symb->Update(REG);
//   }
//   else {
//     symb->Update(LOGIC);
//   }
//   symb->Update(NONPORT);
//   symb->io_fixed = true;

//   symb = mwrapper.symbol_table->Insert( *$2 + "_ns");
//   if ( LEGACY_VERILOG_MODE ) {
//     symb->Update(REG);
//   }
//   else {
//     symb->Update(LOGIC);
//   }
//   symb->Update(NONPORT);
//   symb->io_fixed = true;
// } // 4
// // 5         6        7
// statements fsm_items "endfsm" 
// {
//   CSymbol *clk = mwrapper.symbol_table->Insert(mwrapper.mctrl["clock"]->str);
//   clk->Update(INPUT);
//   if ( !LEGACY_VERILOG_MODE ) clk->Update(LOGIC);
//   clk->roccur.push_back(@1);

//   CSymbol *rst = mwrapper.symbol_table->Insert(mwrapper.mctrl["reset"]->str);
//   rst->Update(INPUT);
//   if ( !LEGACY_VERILOG_MODE ) rst->Update(LOGIC);
//   rst->roccur.push_back(@1);
  
//   CStmtBunch *stmts = new CStmtBunch ($5);
//   $$ = new CBlkFSM (@$, *$2, clk, rst, mwrapper.state_graph, stmts, $6);
//   try { $$->CheckFSM(); }
//   catch (string &str) {
//     if ( mwrapper.mctrl["relaxedfsm"]->flag ) 
//       mwrapper.warning(@$, str);
//     else 
//       mwrapper.error(@$, str);
//   }

//   $$->BuildFSM(mwrapper.symbol_table);

//   $$->GetSymbol();
//   $$->SetDriver();

//   mwrapper.state_graph = NULL;
//   mwrapper.in_fsm = false;
// }

// ;


fsm_items : fsm_item 
{
  $$ = new vector<CStateItem*>;
  $$->push_back($1);
}

| fsm_items fsm_item
{
  $1->push_back($2);
  $$ = $1;
}
;

fsm_item : ID 
{
  mwrapper.state_name = *$1;
  mwrapper.symbol_table->Insert( *$1 );
  map<string, CStTransition*> *graph = mwrapper.state_graph;
  if (graph->count(*$1) == 0 ) (*graph)[*$1] = new CStTransition;
}
":" statement 
{


  // build CCaseItem
  // _ID_
  CVariable *st_idx = new CVariable (mwrapper.symbol_table->Insert( "_" + *$1 + "_" ));
  // cs[_ID_]
  CVariable *cs = new CVariable (mwrapper.symbol_table->Exist( mwrapper.fsm_name + "_cs" ), st_idx);
  CCaseItem *case_item = new CCaseItem (cs, $4);
  
  $$ = new CStateItem (@$, *$1, case_item);

}
;


/*******************************
    inst_block
 ******************************/
inst_block :  ID // 1
{
  mwrapper.mod_template = G_ModuleTable.Exist(*$1);
  mwrapper.mod_template_name = *$1;
  if ( !mwrapper.mod_template ) {
    if ( mwrapper.HierDepth() > mwrapper.mctrl["hierachydepth"]->num ) {
      ostringstream tmp;
      tmp << mwrapper.mctrl["hierachydepth"]->num;
      mwrapper.error(@1, "module hierachy deepth limitation (" + tmp.str() + " levels) exceeded, mostly caused by instantiation loop.");
    }
    else {
      char *mhdl_file, *sv_file, *v_file, *file;
      cerr << "\t" << @1 << ", instantiate " << *$1 << ", ";
      cerr << "start depend parsing...";
      if ( file = SearchFile( *$1 + ".mhdl")  ) {
          string *str = new string (file);
          cerr << endl << "\tDepend MHDL parsing " << file << "... " << endl << endl;
          CMHDLwrapper *depwrapper = new CMHDLwrapper ( *str ); 
          depwrapper->DepParse();
      }
      else if ( (file = SearchFile( *$1 + ".sv")) || (file = SearchFile( *$1 + ".v")) )  {
          string *str = new string (file);
          cerr << endl << "\tDepend SV parsing " << file << "... " << endl << endl;
          CSVwrapper *depwrapper = new CSVwrapper (*str);
          depwrapper->Parse();
      }
      else {
          mwrapper.error(@$, "Cannot find definition for module " + *$1);
      }

      // if ( FastDependParse ) {
      //    cerr << "start fast depend parsing...";
      //    if ( file = SearchFile( *$1 + ".mhdl" )  ) {
      //       string *str = new string (file);
      //       cerr << endl << "\tDepend MHDL parsing " << file << "... " << endl << endl;
      //       CMHDLwrapper *depwrapper = new CMHDLwrapper ( *str ); 
      //       depwrapper->DepParse();
      //    }
      //    else if ( (file = SearchFile( *$1 + ".sv" )) || (file = SearchFile( *$1 + ".v" )) )  {
      //       string *str = new string (file);
      //       cerr << endl << "\tDepend SV parsing " << file << "... " << endl << endl;
      //       CSVwrapper *depwrapper = new CSVwrapper (*str);
      //       depwrapper->Parse();
      //    }
      //    else {
      //       mwrapper.error(@$, "Cannot find definition for module " + *$1);
      //    }
      // } 
      // else {
      //    cerr << "start comprehensive dependent parsing..." ;
      //    int flag = 0;

      //    if ( mhdl_file = SearchFile(*$1 + ".mhdl") ) flag |= 1;
      //    if ( sv_file = SearchFile(*$1 + ".sv" ) )    flag |= 2;
      //    if ( v_file = SearchFile(*$1 + ".v" ) )      flag |= 4;

      //    switch (flag ) {
      //       case 0: mwrapper.error(@$, "Cannot find definition for module " + *$1);
      //       case 1: file = mhdl_file; break;
      //       case 2: file = sv_file; break;
      //       case 4: file = v_file; break;
      //       case 3: case 5: case 7: {
      //          string mul_file;
      //          if ( mhdl_file ) mul_file = mhdl_file;
      //          if ( sv_file )   mul_file = mul_file + " " + sv_file;
      //          if ( v_file )    mul_file = mul_file + " " + v_file;
      //          mwrapper.error(@$, "Multiple definition found for module " + *$1 + ", found " + mul_file);
      //       }

      //       default: 
      //          mwrapper.error(@$, "Error flag when during searching instantiated module");
      //    }

      //    string *str = new string (file);
      //    if ( flag == 1 ) {
      //       cerr << endl << "\tDepend MHDL parsing " << file << "... " << endl << endl;
      //       CMHDLwrapper *depwrapper = new CMHDLwrapper ( *str ); 
      //       depwrapper->DepParse();
      //    }
      //    else {
      //       cerr << endl << "\tDepend SV parsing " << file << "... " << endl << endl;
      //       CSVwrapper *depwrapper = new CSVwrapper (*str);
      //       depwrapper->Parse();
      //    }
      // }

      mwrapper.mod_template = G_ModuleTable.Exist(*$1);
      if ( ! mwrapper.mod_template ) {
	mwrapper.error(@$, "still cannot find module definition for " + *$1 );
      }
    }
  }
  else {
    cerr << "\t" << @1 << ", instantiate " << *$1 << ", found in module database (" << mwrapper.mod_template->loc << ")" << endl;
  }
} // 2
// 3             4               5
parameter_rule instance_name connection_spec ";"  
{ 
  map<CSymbol*, CExpression*, CCompareConnection> *connect_map_got = mwrapper.mod_template->io_table->GetIO();
  map<CSymbol*, CExpression*, CCompareConnection> *connect_map = new map<CSymbol*, CExpression*, CCompareConnection>;

  for (map<CSymbol*, CExpression*, CCompareConnection>::iterator iter = connect_map_got->begin(); 
       iter != connect_map_got->end(); ++iter) {
    if ( iter->second && typeid( *(iter->second) ) == typeid( CVariable ) ) {
      CVariable *var = dynamic_cast<CVariable*> (iter->second);
      CSymbol *symb_got = var->Symb();
      if ( mwrapper.symbol_to_remove.count(symb_got->name) ) {
	 CSymbol *original_symb = mwrapper.symbol_table->Insert( symb_got->name );
	 if ( !LEGACY_VERILOG_MODE ) original_symb->Update(LOGIC);
	 original_symb->Update( symb_got->msb );
	 original_symb->Update( iter->first->direction );
	 original_symb->reference = iter->first;
	 original_symb->roccur.insert(original_symb->roccur.end(), symb_got->roccur.begin(), symb_got->roccur.end() );
	 original_symb->loccur.insert(original_symb->loccur.end(), symb_got->loccur.begin(), symb_got->loccur.end() );
	 (*connect_map)[iter->first] = new CVariable (original_symb, var->Msb(), var->Lsb() );
	 mwrapper.symbol_to_remove.erase(symb_got->name);
      }
      else {
	 CSymbol *symb = mwrapper.symbol_table->Insert(symb_got->name);
	 if ( !LEGACY_VERILOG_MODE ) symb->Update(LOGIC);
	 symb->Update(symb_got->msb);
	 //       if ( !symb->Update(iter->second->msb) ) {
	 // 	mwrapper.warning(@$, "net " + symb->name + ": width is fixed by user declaration, cannot apply instantiation inferred value, potential error!!");
	 //       }
	 symb->Update(iter->first->direction);
	 //       if ( !symb->Update(iter->second->direction) ) {
	 // 	mwrapper.warning(@$, "net " + symb->name + ": IO direction is fixed by user declaration, cannot apply instantiation inferred value, potential error!!");
	 //       }
	 symb->reference = iter->first;

	 if ( iter->first->direction == INPUT ) {
	    symb->roccur.push_back( @4 );
	 }
	 else if ( iter->first->direction == OUTPUT  ) {
	    symb->loccur.push_back( @4 );
	 }
	 else if ( iter->first->direction == INOUT ) {
	    symb->loccur.push_back( @4 );
	    symb->roccur.push_back( @4 );
	 }
	 else {
	    mwrapper.error(@$, "port \"" + iter->first->name + "\" has no direction?!");
	 }

	 (*connect_map)[iter->first] = new CVariable (symb, var->Msb(), var->Lsb() );
      }
    }
    else {
       if ( iter->second ) {
	  if ( iter->first->direction == INPUT ) {
	     iter->second->Update(INPUT);
	  }
	  else if ( iter->first->direction == OUTPUT  ) {
	     iter->second->Update(OUTPUT);
	  }
	  else if ( iter->first->direction == INOUT ) {
	     iter->second->Update(INOUT);
	  }
	  else {
	     mwrapper.error(@$, "port \"" + iter->first->name + "\" has no direction?!");
	  }
       }
      (*connect_map)[iter->first] = iter->second;
    }

    if ( iter->second ) {
       if ( iter->first->msb->Value()+1 != iter->second->Width() ) {
	  ostringstream buf;
	  buf << "width mismatch on port \"" + iter->first->name + "\" connection, " 
	      << iter->first->msb->Value()+1 << " vs. " << iter->second->Width();
	  mwrapper.warning(@$, buf.str());
       }
    }
  }

  for ( set<string>::iterator iter = mwrapper.symbol_to_remove.begin(); 
	iter != mwrapper.symbol_to_remove.end(); ++iter) {
    if ( !mwrapper.symbol_table->Remove( (*iter) ) ) {
      mwrapper.error(@$, "Symbol \"" + (*iter) +  "\" has already been removed, ask MENG Xin why.");
    }
  }
  mwrapper.symbol_to_remove.clear();

  $$ = new CBlkInst (@$, *$1, $3, *$4, connect_map);
  $$->GetSymbol();
  $$->SetDriver();

  mwrapper.mod_template->param_table->Reset();
  mwrapper.mod_template->io_table->Reset();
  mwrapper.mod_template = NULL;
}
;

instance_name : {$$ = new string ("x_" + mwrapper.mod_template_name);}
| ID {$$ = $1;}
;

parameter_rule : {$$ = NULL;}
| "#" "(" parameter_override ")" 
{
  $$ = mwrapper.mod_template->param_table->GetParam();
}
;

parameter_override : parameter_num_override
{
  if ( !mwrapper.mod_template->param_table->SetParam($1) ) {
    mwrapper.error(@1, "parameter number mismatch for " + mwrapper.mod_template_name);
  }
}
| parameter_name_override 
;

parameter_num_override : expression 
{
  if ( !$1->IsConst() ) {
    mwrapper.error(@1, "non-constant expression as parameter.");
  }
  else {
    $$ = new vector<CExpression*>;
    $$->push_back($1);
  }
}

| parameter_num_override "," expression 
{
  if ( ! $3->IsConst() ) {
    mwrapper.error(@3, "non-constant expression as parameter.");
  }
  else {
    $1->push_back($3);
    $$ = $1;
  }
}
;

parameter_name_override : "." ID "(" expression ")"
{
  if ( ! $4->IsConst()) {
    mwrapper.error(@4, "non-constant expression as parameter.");
  }
  else if ( !mwrapper.mod_template->param_table->SetParam(*$2, $4) ) {
    mwrapper.error(@2, mwrapper.mod_template_name + " has no public parameter: " + *$2);
  }
}
| parameter_name_override "," "." ID "(" expression ")"
{
  if ( ! $6->IsConst()) {
    mwrapper.error(@6, "non-constant expression as parameter.");
  }
  else if ( !mwrapper.mod_template->param_table->SetParam(*$4, $6) ) {
    mwrapper.error(@4, mwrapper.mod_template_name + " has no public parameter: " + *$4);
  }
}

;

connection_spec :
| "(" connection_rules ")" 
;

connection_rules : connection_rule 
| connection_rules "," connection_rule 
;

connection_rule : "." net_name "(" expression ")" 
{
  if ( typeid( *$4 ) == typeid (CVariable) ) {
    // save symbol for removal
    CVariable *var = dynamic_cast<CVariable*> ( $4 );
    CSymbol *tmp_symb = var->Symb();
    mwrapper.symbol_to_remove.insert(tmp_symb->name);
  }

  CSymbol *port_symb = mwrapper.mod_template->io_table->Connect(*$2, $4);

  if ( ! port_symb ) {
    mwrapper.error(@$, mwrapper.mod_template_name + " has no port \"" + *$2 + "\".");
  }
  else if ( (port_symb->direction == OUTPUT /*|| port_symb->direction == INOUT*/) && typeid( *$4 ) == typeid(CConcatenation) ) {
     CConcatenation *concat_exp = dynamic_cast<CConcatenation*> ($4);
     for ( vector<CExpression*>::iterator iter = concat_exp->List()->begin();
	   iter != concat_exp->List()->end(); ++iter) {
	if ( typeid( **iter ) != typeid( CVariable ) ) {
	   mwrapper.error(@$, "output/inout port \"" + *$2 + "\" connects to RHS concatenation.");
	}
     }
  }
  else if ( (port_symb->direction == OUTPUT /*|| port_symb->direction == INOUT*/) && typeid( *$4 ) != typeid(CVariable) ) {
     mwrapper.error(@$, "output/inout port \"" + *$2 + "\" connects to RHS expression.");
  }
  else if (port_symb->msb->Value() - port_symb->lsb->Value() + 1 != $4->Width()) {
      ostringstream msg;
      msg << "port connection width mis-match: " 
          << port_symb->msb->Value() - port_symb->lsb->Value() + 1 
          << " vs. " 
          << $4->Width();
      mwrapper.warning(@$, "port connection width mis-match" + msg.str());
  }

  if ( port_symb->direction == INPUT ) {
     $4->AddRoccure(@$);
  }
  else if (port_symb->direction == OUTPUT ) {
     $4->AddLoccure(@$);
  }
  else if (port_symb->direction == INOUT ) {
     $4->AddRoccure(@$);
     $4->AddLoccure(@$);
  }
  else {
     mwrapper.error(@2, "port \"" + port_symb->name +"\" is nonport?!");
  }
}

| "." net_name "(" ")" 
{
  if ( !mwrapper.mod_template->io_table->Connect(*$2, NULL) ) {
    mwrapper.error(@2, mwrapper.mod_template_name + " has no port: " + *$2);
  }
}

| STRING 
{
  mwrapper.mod_template->io_table->Connect(*$1);
}

| "+" ID 
{
  mwrapper.mod_template->io_table->Connect(SUFFIX, *$2);
}

| ID "+" 
{
  mwrapper.mod_template->io_table->Connect(PREFIX, *$1);
}
;


/*******************************
    rawcode_block
 ******************************/
rawcode_block : "rawcode" verbtims "endrawcode" 
{
  $$ = new CBlkVerbtim (@$, *$2);
}

| "function" verbtims "endfunction"
{
  $$ = new CBlkVerbtim (@$, "function " + *$2 + "endfunction\n" );
}
;

verbtims : VERBTIM {$$ = new string (*$1); }
| verbtims VERBTIM {*$$ = *$1 + *$2; }
;


/*******************************
    metahdl_constrol
 ******************************/
metahdl_constrol : "metahdl" ID ";" 
{
  if ( *$2 == "exit") {
    cerr << "\033[00;31m[M-Exit]" << @$ << "\033[00m" << endl;
    exit(1);
  }
  else {
    mwrapper.warning(@2, "nothing is done for " + *$2);
  }
}

| "metahdl" "+" ID ";"
{
  if ( !mwrapper.SetCtrl( *$3, true ) ) {
    mwrapper.warning(@3, "no such boolean contorl variable:" + *$3);
  }
}

| "metahdl" "-" ID ";"
{
  if ( !mwrapper.SetCtrl( *$3, false ) ) {
    mwrapper.warning(@3, "no such boolean contorl variable:" + *$3);
  }
}

| "metahdl" ID "=" NUM ";"
{
  CNumber *num = new CNumber (*$4);
  if ( !mwrapper.SetCtrl(*$2, num->Value() ) ) {
    mwrapper.warning(@2, "no such numeric contorl variable:" + *$2);
  }
}

| "metahdl" ID "=" ID ";" 
{
  if ( !mwrapper.SetCtrl(*$2, *$4) ) {
    mwrapper.warning(@2, "no such string contorl variable:" + *$2);
  }
}

| "metahdl" "message" verbtims ";" {cerr << "\033[00;32m[M-MSG: " << *$3 << "]" << @$ << "\033[00m" << endl;}

| "metahdl" "parse" verbtims ";"
{
  string cmd_line = COMMAND;
  if ( LEGACY_VERILOG_MODE )
    cmd_line = cmd_line + " -verilog ";

  if (FORCE_WIDTH_OUTPUT) 
    cmd_line = cmd_line + " --force-width-output";

  switch (CASE_MODIFY_STYLE)
    {
    case PROPAGATE:
      cmd_line = cmd_line + " --propagate-case-modifier";
      break;
  
    case MACRO:
      cmd_line = cmd_line + " --macro-case-modifier";
      break;

    case ELIMINATE:
      cmd_line = cmd_line + " --eliminate-case-modifier";
      break;
    }

  for (list<string>::iterator iter = PATHS.begin(); 
       iter!=PATHS.end(); ++iter)
    cmd_line = cmd_line + " -I " + *iter ;

  cmd_line = cmd_line + " -o " + V_BASE + *$3 ;


  cerr << endl << "\tParsing on demand: " << cmd_line << endl << endl;

  if ( system(cmd_line.c_str()) ) mwrapper.error(@$, "Parsing on demand failed.");

}
;


%%


void 
yy::mParser::error(const yy::location &l, const string &s)
{
  mwrapper.error(l, s);
}
