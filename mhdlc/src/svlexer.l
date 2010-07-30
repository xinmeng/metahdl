%option yylineno
%option noyywrap
%option stack
%option debug
%option nounput
%option prefix="sv"
%option outfile="svlexer.flex.cc"

%{
#include <string>
#include <iostream>
#include <stack>

#include "svparser.bison.hh"
#include "MetaHDL.hh"


   std::stack<YY_BUFFER_STATE> SVBufStk;

#define YY_DECL \
  svtokentype svlex(YYSTYPE *yylval, yy::location* yylloc, CSVwrapper &svwrapper)

#define YY_USER_ACTION ECHO; yylloc->columns(svleng);

extern bool CopyVerilogCode;

%}

%x sc_string sc_line_cmt sc_blk_cmt sc_ctrl_line sc_use_string
%x sc_parse_mode
%x sc_function sc_task

 /* SystemVerilog keywords */
K_ALIAS                    "alias"                 
K_ALWAYS                          "always"               
K_ALWAYS_COMB             "always_comb"          
K_ALWAYS_FF               "always_ff"            
K_ALWAYS_LATCH            "always_latch"                 
K_AND                     "and"                  
K_ASSERT                          "assert"               
K_ASSIGN                          "assign"               
K_ASSUME                          "assume"               
K_AUTOMATIC               "automatic"            
K_BEFORE                          "before"               
K_BEGIN                   "begin"                        
K_BIND                    "bind"                         
K_BINS                    "bins"                         
K_BINSOF                          "binsof"               
K_BIT                     "bit"                  
K_BREAK                   "break"                        
K_BUF                     "buf"                  
K_BUFIF0                          "bufif0"               
K_BUFIF1                          "bufif1"               
K_BYTE                    "byte"                         
K_CASE                    "case"                         
K_CASEX                   "casex"                        
K_CASEZ                   "casez"                        
K_CELL                    "cell"                         
K_CHANDLE                 "chandle"              
K_CLASS                   "class"                        
K_CLOCKING                "clocking"             
K_CMOS                    "cmos"                         
K_CONFIG                          "config"               
K_CONST                   "const"                        
K_CONSTRAINT              "constraint"           
K_CONTEXT                 "context"              
K_CONTINUE                "continue"             
K_COVER                   "cover"                        
K_COVERGROUP              "covergroup"           
K_COVERPOINT              "coverpoint"           
K_CROSS                   "cross"                        
K_DEASSIGN                "deassign"             
K_DEFAULT                 "default"              
K_DEFPARAM                "defparam"             
K_DESIGN                          "design"               
K_DISABLE                 "disable"              
K_DIST                    "dist"                         
K_DO                      "do"                   
K_EDGE                    "edge"                         
K_ELSE                    "else"                         
K_END                     "end"                  
K_ENDCASE                 "endcase"              
K_ENDCLASS                "endclass"             
K_ENDCLOCKING             "endclocking"          
K_ENDCONFIG               "endconfig"            
K_ENDFUNCTION             "endfunction"          
K_ENDGENERATE             "endgenerate"          
K_ENDGROUP                "endgroup"             
K_ENDINTERFACE            "endinterface"                 
K_ENDMODULE               "endmodule"            
K_ENDPACKAGE              "endpackage"           
K_ENDPRIMITIVE            "endprimitive"                 
K_ENDPROGRAM              "endprogram"           
K_ENDPROPERTY             "endproperty"          
K_ENDSPECIFY              "endspecify"           
K_ENDSEQUENCE             "endsequence"          
K_ENDTABLE                "endtable"             
K_ENDTASK                 "endtask"              
K_ENUM                    "enum"                         
K_EVENT                   "event"                        
K_EXPECT                          "expect"               
K_EXPORT                          "export"               
K_EXTENDS                 "extends"              
K_EXTERN                          "extern"               
K_FINAL                   "final"                        
K_FIRST_MATCH             "first_match"          
K_FOR                     "for"                  
K_FORCE                   "force"                        
K_FOREACH                 "foreach"              
K_FOREVER                 "forever"              
K_FORK                    "fork"                         
K_FORKJOIN                "forkjoin"             
K_FUNCTION                "function"             
K_GENERATE                "generate"             
K_GENVAR                          "genvar"               
K_HIGHZ0                          "highz0"               
K_HIGHZ1                          "highz1"               
K_IF                      "if"                   
K_IFF                     "iff"                  
K_IFNONE                          "ifnone"               
K_IGNORE_BINS             "ignore_bins"          
K_ILLEGAL_BINS            "illegal_bins"                 
K_IMPORT                          "import"               
K_INCDIR                          "incdir"               
K_INCLUDE                 "include"              
K_INITIAL                 "initial"              
K_INOUT                   "inout"                        
K_INPUT                   "input"                        
K_INSIDE                          "inside"               
K_INSTANCE                "instance"             
K_INT                     "int"                  
K_INTEGER                 "integer"              
K_INTERFACE               "interface"            
K_INTERSECT               "intersect"            
K_JOIN                    "join"                         
K_JOIN_ANY                "join_any"             
K_JOIN_NONE               "join_none"            
K_LARGE                   "large"                        
K_LIBLIST                 "liblist"              
K_LIBRARY                 "library"              
K_LOCAL                   "local"                        
K_LOCALPARAM              "localparam"           
K_LOGIC                   "logic"                        
K_LONGINT                 "longint"              
K_MACROMODULE             "macromodule"          
K_MATCHES                 "matches"              
K_MEDIUM                          "medium"               
K_MODPORT                 "modport"              
K_MODULE                          "module"               
K_NAND                    "nand"                         
K_NEGEDGE                 "negedge"              
K_NEW                     "new"                  
K_NMOS                    "nmos"                         
K_NOR                     "nor"                  
K_NOSHOWCANCELLED         "noshowcancelled"      
K_NOT                     "not"                  
K_NOTIF0                          "notif0"               
K_NOTIF1                          "notif1"               
K_NULL                    "null"                         
K_OR                      "or"                   
K_OUTPUT                          "output"               
K_PACKAGE                 "package"              
K_PACKED                          "packed"               
K_PARAMETER               "parameter"            
K_PMOS                    "pmos"                         
K_POSEDGE                 "posedge"              
K_PRIMITIVE               "primitive"            
K_PRIORITY                "priority"             
K_PROGRAM                 "program"              
K_PROPERTY                "property"             
K_PROTECTED               "protected"            
K_PULL0                   "pull0"                        
K_PULL1                   "pull1"                        
K_PULLDOWN                "pulldown"             
K_PULLUP                          "pullup"               
K_PULSESTYLE_ONEVENT      "pulsestyle_onevent"   
K_PULSESTYLE_ONDETECT     "pulsestyle_ondetect"  
K_PURE                    "pure"                         
K_RAND                    "rand"                         
K_RANDC                   "randc"                        
K_RANDCASE                "randcase"             
K_RANDSEQUENCE            "randsequence"                 
K_RCMOS                   "rcmos"                        
K_REAL                    "real"                         
K_REALTIME                "realtime"             
K_REF                     "ref"                  
K_REG                     "reg"                  
K_RELEASE                 "release"              
K_REPEAT                          "repeat"               
K_RETURN                          "return"               
K_RNMOS                   "rnmos"                        
K_RPMOS                   "rpmos"                        
K_RTRAN                   "rtran"                        
K_RTRANIF0                "rtranif0"             
K_RTRANIF1                "rtranif1"             
K_SCALARED                "scalared"             
K_SEQUENCE                "sequence"             
K_SHORTINT                "shortint"             
K_SHORTREAL               "shortreal"            
K_SHOWCANCELLED           "showcancelled"                
K_SIGNED                          "signed"               
K_SMALL                   "small"                        
K_SOLVE                   "solve"                        
K_SPECIFY                 "specify"              
K_SPECPARAM               "specparam"            
K_STATIC                          "static"               
K_STRING                          "string"               
K_STRONG0                 "strong0"              
K_STRONG1                 "strong1"              
K_STRUCT                          "struct"               
K_SUPER                   "super"                        
K_SUPPLY0                 "supply0"              
K_SUPPLY1                 "supply1"              
K_TABLE                   "table"                        
K_TAGGED                          "tagged"               
K_TASK                    "task"                         
K_THIS                    "this"                         
K_THROUGHOUT              "throughout"           
K_TIME                    "time"                         
K_TIMEPRECISION           "timeprecision"                
K_TIMEUNIT                "timeunit"             
K_TRAN                    "tran"                         
K_TRANIF0                 "tranif0"              
K_TRANIF1                 "tranif1"              
K_TRI                     "tri"                  
K_TRI0                    "tri0"                         
K_TRI1                    "tri1"                         
K_TRIAND                          "triand"               
K_TRIOR                   "trior"                        
K_TRIREG                          "trireg"               
K_TYPE                    "type"                         
K_TYPEDEF                 "typedef"              
K_UNION                   "union"                        
K_UNIQUE                          "unique"               
K_UNSIGNED                "unsigned"             
K_USE                     "use"                  
K_VAR                     "var"                  
K_VECTORED                "vectored"             
K_VIRTUAL                 "virtual"              
K_VOID                    "void"                         
K_WAIT                    "wait"                         
K_WAIT_ORDER              "wait_order"           
K_WAND                    "wand"                         
K_WEAK0                   "weak0"                        
K_WEAK1                   "weak1"                        
K_WHILE                   "while"                        
K_WILDCARD                "wildcard"             
K_WIRE                    "wire"                         
K_WITH                    "with"                         
K_WITHIN                  "within"               
K_WOR                     "wor"                  
K_XNOR                    "xnor"                         
K_XOR                     "xor"                  

 /* MetaHDL keywords */
K_METAHDL       "metahdl"
K_NONPORT       "nonport"
K_CONSTANT        "constant"        
K_ENDCONSTANT    "endconstant"
K_FF           "ff"           
K_ENDFF        "endff"        
K_FSM          "fsm"          
K_ENDFSM               "endfsm"      
K_GOTO         "goto"
K_RAWCODE       "rawcode"
K_ENDRAWCODE    "endrawcode" 


 /* operators */
OR  "|"
AND "&" 
XOR "^"

UNARY_NOT    "~"

BINARY_PLUS  "+"
BINARY_MINUS "-"
BINARY_MULT  "*"
BINARY_DIV   "/"
BINARY_MOD   "%"
BINARY_LSH   "<<"
BINARY_RSH   ">>"

COND_NOT     "!"
COND_AND     "&&"
COND_OR      "||"
COND_LT      "<"
COND_GT      ">"
COND_EQ      "=="
COND_NE      "!="
COND_LE      "<="
COND_GE      ">="


TRI_QUESTION  "?"
TRI_COLON     ":"


 /* punctuations */
PUNC_EQUAL     "="
PUNC_COMMA     ","
PUNC_DOT       "."
PUNC_SEMICOLON ";"
PUNC_LBRACE    "{"
PUNC_RBRACE    "}"
PUNC_LPAREN    "("
PUNC_RPAREN    ")"
PUNC_LBRECT    "["
PUNC_RBRECT    "]"
PUNC_CHARP     "#"


 /* control directives */
CTRL_LINE "`line"

 /* other tokens */
ID [[:alpha:]_][[:alnum:]_]*
NUM [0-9]+
WS [ \t]+

%%
  static string buf;


{K_ENDMODULE} return K_ENDMODULE;

{K_MODULE} yy_push_state(sc_parse_mode); return K_MODULE;
{K_INOUT} yy_push_state(sc_parse_mode); return K_INOUT;
{K_INPUT} yy_push_state(sc_parse_mode); return K_INPUT;
{K_OUTPUT} yy_push_state(sc_parse_mode); return K_OUTPUT;
{K_PARAMETER} yy_push_state(sc_parse_mode); return K_PARAMETER;

{K_FUNCTION} yy_push_state(sc_function);
{K_TASK} yy_push_state(sc_task);

{ID} /* zap */

 /* line comment */
\/\/ yy_push_state(sc_line_cmt);
    
 /* block comment */
"/*" yy_push_state(sc_blk_cmt);


 /* control directives */
{CTRL_LINE} yy_push_state(sc_ctrl_line); 
<sc_ctrl_line>{
  {WS} 
  {NUM} yylloc->lines(-yylloc->end.line + atoi(svtext)); 
  "\""  buf.erase(); yy_push_state(sc_use_string);
  \n {
    yylloc->begin.filename = yylloc->end.filename = new string (buf); 
    buf.erase();
    yylloc->lines(0); yylloc->step(); yy_pop_state(); 
  }
  .  svwrapper.error(yylloc->end, (string)"Unexpected char in `line directive:"+svtext);
}

<sc_parse_mode>{
     /* control directives */
  {CTRL_LINE} yy_push_state(sc_ctrl_line); 

  {K_ALIAS} return K_ALIAS;
  {K_ALWAYS} return K_ALWAYS;
  {K_ALWAYS_COMB} return K_ALWAYS_COMB;
  {K_ALWAYS_FF} return K_ALWAYS_FF;
  {K_ALWAYS_LATCH} return K_ALWAYS_LATCH;
  {K_AND} return K_AND;
  {K_ASSERT} return K_ASSERT;
  {K_ASSIGN} return K_ASSIGN;
  {K_ASSUME} return K_ASSUME;
  {K_AUTOMATIC} return K_AUTOMATIC;
  {K_BEFORE} return K_BEFORE;
  {K_BEGIN} return K_BEGIN;
  {K_BIND} return K_BIND;
  {K_BINS} return K_BINS;
  {K_BINSOF} return K_BINSOF;
  {K_BIT} return K_BIT;
  {K_BREAK} return K_BREAK;
  {K_BUF} return K_BUF;
  {K_BUFIF0} return K_BUFIF0;
  {K_BUFIF1} return K_BUFIF1;
  {K_BYTE} return K_BYTE;
  {K_CASE} return K_CASE;
  {K_CASEX} return K_CASEX;
  {K_CASEZ} return K_CASEZ;
  {K_CELL} return K_CELL;
  {K_CHANDLE} return K_CHANDLE;
  {K_CLASS} return K_CLASS;
  {K_CLOCKING} return K_CLOCKING;
  {K_CMOS} return K_CMOS;
  {K_CONFIG} return K_CONFIG;
  {K_CONST} return K_CONST;
  {K_CONSTRAINT} return K_CONSTRAINT;
  {K_CONTEXT} return K_CONTEXT;
  {K_CONTINUE} return K_CONTINUE;
  {K_COVER} return K_COVER;
  {K_COVERGROUP} return K_COVERGROUP;
  {K_COVERPOINT} return K_COVERPOINT;
  {K_CROSS} return K_CROSS;
  {K_DEASSIGN} return K_DEASSIGN;
  {K_DEFAULT} return K_DEFAULT;
  {K_DEFPARAM} return K_DEFPARAM;
  {K_DESIGN} return K_DESIGN;
  {K_DISABLE} return K_DISABLE;
  {K_DIST} return K_DIST;
  {K_DO} return K_DO;
  {K_EDGE} return K_EDGE;
  {K_ELSE} return K_ELSE;
  {K_END} return K_END;
  {K_ENDCASE} return K_ENDCASE;
  {K_ENDCLASS} return K_ENDCLASS;
  {K_ENDCLOCKING} return K_ENDCLOCKING;
  {K_ENDCONFIG} return K_ENDCONFIG;
  {K_ENDFUNCTION} return K_ENDFUNCTION;
  {K_ENDGENERATE} return K_ENDGENERATE;
  {K_ENDGROUP} return K_ENDGROUP;
  {K_ENDINTERFACE} return K_ENDINTERFACE;
  {K_ENDPACKAGE} return K_ENDPACKAGE;
  {K_ENDPRIMITIVE} return K_ENDPRIMITIVE;
  {K_ENDPROGRAM} return K_ENDPROGRAM;
  {K_ENDPROPERTY} return K_ENDPROPERTY;
  {K_ENDSPECIFY} return K_ENDSPECIFY;
  {K_ENDSEQUENCE} return K_ENDSEQUENCE;
  {K_ENDTABLE} return K_ENDTABLE;
  {K_ENDTASK} return K_ENDTASK;
  {K_ENUM} return K_ENUM;
  {K_EVENT} return K_EVENT;
  {K_EXPECT} return K_EXPECT;
  {K_EXPORT} return K_EXPORT;
  {K_EXTENDS} return K_EXTENDS;
  {K_EXTERN} return K_EXTERN;
  {K_FINAL} return K_FINAL;
  {K_FIRST_MATCH} return K_FIRST_MATCH;
  {K_FOR} return K_FOR;
  {K_FORCE} return K_FORCE;
  {K_FOREACH} return K_FOREACH;
  {K_FOREVER} return K_FOREVER;
  {K_FORK} return K_FORK;
  {K_FORKJOIN} return K_FORKJOIN;
  {K_FUNCTION} return K_FUNCTION;
  {K_GENERATE} return K_GENERATE;
  {K_GENVAR} return K_GENVAR;
  {K_HIGHZ0} return K_HIGHZ0;
  {K_HIGHZ1} return K_HIGHZ1;
  {K_IF} return K_IF;
  {K_IFF} return K_IFF;
  {K_IFNONE} return K_IFNONE;
  {K_IGNORE_BINS} return K_IGNORE_BINS;
  {K_ILLEGAL_BINS} return K_ILLEGAL_BINS;
  {K_IMPORT} return K_IMPORT;
  {K_INCDIR} return K_INCDIR;
  {K_INCLUDE} return K_INCLUDE;
  {K_INITIAL} return K_INITIAL;
  {K_INOUT} return K_INOUT;
  {K_INPUT} return K_INPUT;
  {K_INSIDE} return K_INSIDE;
  {K_INSTANCE} return K_INSTANCE;
  {K_INT} return K_INT;
  {K_INTEGER} return K_INTEGER;
  {K_INTERFACE} return K_INTERFACE;
  {K_INTERSECT} return K_INTERSECT;
  {K_JOIN} return K_JOIN;
  {K_JOIN_ANY} return K_JOIN_ANY;
  {K_JOIN_NONE} return K_JOIN_NONE;
  {K_LARGE} return K_LARGE;
  {K_LIBLIST} return K_LIBLIST;
  {K_LIBRARY} return K_LIBRARY;
  {K_LOCAL} return K_LOCAL;
  {K_LOCALPARAM} return K_LOCALPARAM;
  {K_LOGIC} return K_LOGIC;
  {K_LONGINT} return K_LONGINT;
  {K_MACROMODULE} return K_MACROMODULE;
  {K_MATCHES} return K_MATCHES;
  {K_MEDIUM} return K_MEDIUM;
  {K_MODPORT} return K_MODPORT;
  {K_NAND} return K_NAND;
  {K_NEGEDGE} return K_NEGEDGE;
  {K_NEW} return K_NEW;
  {K_NMOS} return K_NMOS;
  {K_NOR} return K_NOR;
  {K_NOSHOWCANCELLED} return K_NOSHOWCANCELLED;
  {K_NOT} return K_NOT;
  {K_NOTIF0} return K_NOTIF0;
  {K_NOTIF1} return K_NOTIF1;
  {K_NULL} return K_NULL;
  {K_OR} return K_OR;
  {K_OUTPUT} return K_OUTPUT;
  {K_PACKAGE} return K_PACKAGE;
  {K_PACKED} return K_PACKED;
  {K_PMOS} return K_PMOS;
  {K_POSEDGE} return K_POSEDGE;
  {K_PRIMITIVE} return K_PRIMITIVE;
  {K_PRIORITY} return K_PRIORITY;
  {K_PROGRAM} return K_PROGRAM;
  {K_PROPERTY} return K_PROPERTY;
  {K_PROTECTED} return K_PROTECTED;
  {K_PULL0} return K_PULL0;
  {K_PULL1} return K_PULL1;
  {K_PULLDOWN} return K_PULLDOWN;
  {K_PULLUP} return K_PULLUP;
  {K_PULSESTYLE_ONEVENT} return K_PULSESTYLE_ONEVENT;
  {K_PULSESTYLE_ONDETECT} return K_PULSESTYLE_ONDETECT;
  {K_PURE} return K_PURE;
  {K_RAND} return K_RAND;
  {K_RANDC} return K_RANDC;
  {K_RANDCASE} return K_RANDCASE;
  {K_RANDSEQUENCE} return K_RANDSEQUENCE;
  {K_RCMOS} return K_RCMOS;
  {K_REAL} return K_REAL;
  {K_REALTIME} return K_REALTIME;
  {K_REF} return K_REF;
  {K_REG} return K_REG;
  {K_RELEASE} return K_RELEASE;
  {K_REPEAT} return K_REPEAT;
  {K_RETURN} return K_RETURN;
  {K_RNMOS} return K_RNMOS;
  {K_RPMOS} return K_RPMOS;
  {K_RTRAN} return K_RTRAN;
  {K_RTRANIF0} return K_RTRANIF0;
  {K_RTRANIF1} return K_RTRANIF1;
  {K_SCALARED} return K_SCALARED;
  {K_SEQUENCE} return K_SEQUENCE;
  {K_SHORTINT} return K_SHORTINT;
  {K_SHORTREAL} return K_SHORTREAL;
  {K_SHOWCANCELLED} return K_SHOWCANCELLED;
  {K_SIGNED} return K_SIGNED;
  {K_SMALL} return K_SMALL;
  {K_SOLVE} return K_SOLVE;
  {K_SPECIFY} return K_SPECIFY;
  {K_SPECPARAM} return K_SPECPARAM;
  {K_STATIC} return K_STATIC;
  {K_STRING} return K_STRING;
  {K_STRONG0} return K_STRONG0;
  {K_STRONG1} return K_STRONG1;
  {K_STRUCT} return K_STRUCT;
  {K_SUPER} return K_SUPER;
  {K_SUPPLY0} return K_SUPPLY0;
  {K_SUPPLY1} return K_SUPPLY1;
  {K_TABLE} return K_TABLE;
  {K_TAGGED} return K_TAGGED;
  {K_TASK} return K_TASK;
  {K_THIS} return K_THIS;
  {K_THROUGHOUT} return K_THROUGHOUT;
  {K_TIME} return K_TIME;
  {K_TIMEPRECISION} return K_TIMEPRECISION;
  {K_TIMEUNIT} return K_TIMEUNIT;
  {K_TRAN} return K_TRAN;
  {K_TRANIF0} return K_TRANIF0;
  {K_TRANIF1} return K_TRANIF1;
  {K_TRI} return K_TRI;
  {K_TRI0} return K_TRI0;
  {K_TRI1} return K_TRI1;
  {K_TRIAND} return K_TRIAND;
  {K_TRIOR} return K_TRIOR;
  {K_TRIREG} return K_TRIREG;
  {K_TYPE} return K_TYPE;
  {K_TYPEDEF} return K_TYPEDEF;
  {K_UNION} return K_UNION;
  {K_UNIQUE} return K_UNIQUE;
  {K_UNSIGNED} return K_UNSIGNED;
  {K_USE} return K_USE;
  {K_VAR} return K_VAR;
  {K_VECTORED} return K_VECTORED;
  {K_VIRTUAL} return K_VIRTUAL;
  {K_VOID} return K_VOID;
  {K_WAIT} return K_WAIT;
  {K_WAIT_ORDER} return K_WAIT_ORDER;
  {K_WAND} return K_WAND;
  {K_WEAK0} return K_WEAK0;
  {K_WEAK1} return K_WEAK1;
  {K_WHILE} return K_WHILE;
  {K_WILDCARD} return K_WILDCARD;
  {K_WIRE} return K_WIRE;
  {K_WITH} return K_WITH;
  {K_WITHIN} return K_WITHIN;
  {K_WOR} return K_WOR;
  {K_XNOR} return K_XNOR;
  {K_XOR} return K_XOR;

  /* operators */
  {OR} return OR;
  {AND} return AND;
  {XOR} return XOR;

  {UNARY_NOT} return UNARY_NOT;

  {BINARY_PLUS} return BINARY_PLUS;
  {BINARY_MINUS} return BINARY_MINUS;
  {BINARY_MULT} return BINARY_MULT;
  {BINARY_DIV} return BINARY_DIV;
  {BINARY_MOD} return BINARY_MOD;
  {BINARY_LSH} return BINARY_LSH;
  {BINARY_RSH} return BINARY_RSH;

  {COND_NOT} return COND_NOT;
  {COND_AND} return COND_AND;
  {COND_OR} return COND_OR;
  {COND_LT} return COND_LT;
  {COND_GT} return COND_GT;
  {COND_EQ} return COND_EQ;
  {COND_NE} return COND_NE;
  {COND_LE} return COND_LE;
  {COND_GE} return COND_GE;


  {TRI_QUESTION} return TRI_QUESTION;
  {TRI_COLON} return TRI_COLON;


  /* punctuations */
  {PUNC_EQUAL} return PUNC_EQUAL;
  {PUNC_COMMA} return PUNC_COMMA;
  {PUNC_DOT} return PUNC_DOT;
  {PUNC_LBRACE} return PUNC_LBRACE;
  {PUNC_RBRACE} return PUNC_RBRACE;
  {PUNC_LPAREN} return PUNC_LPAREN;
  {PUNC_RPAREN} return PUNC_RPAREN;
  {PUNC_LBRECT} return PUNC_LBRECT;
  {PUNC_RBRECT} return PUNC_RBRECT;
  {PUNC_CHARP} return PUNC_CHARP;
  {PUNC_SEMICOLON} yy_pop_state(); return PUNC_SEMICOLON;



  /* other tokens */
  {ID} yylval->str = new string (svtext); return ID;
  {NUM} {
    yylval->str = new string (svtext);
    return NUM;
  }

  {WS} yylloc->step();
  \n  yylloc->lines(1); yylloc->step();


  /* based number */ 
  {NUM}\'[bB][[:alnum:]_\?]+ {
    string str = svtext;
    size_t q_pos = str.find_first_of("'");
    size_t found = str.find_first_not_of("01_?xXzZ", q_pos + 2);
    if ( found == string::npos ) {
      yylval->str = new string (svtext);
      return BIN_BASED_NUM;
    }
    else {
      svwrapper.error(svlineno, "Bad char in BIN number:"+ str.substr(found, 1));
    }
  }

  {NUM}\'[dD][[:alnum:]_\?]+ {
    string str = svtext;
    size_t q_pos = str.find_first_of("'");
    size_t found = str.find_first_not_of("0123456789_?xXzZ", q_pos + 2);
    if ( found == string::npos ) {
      yylval->str = new string (svtext);
      return DEC_BASED_NUM;
    }
    else {
      svwrapper.error(svlineno, "Bad char in DEC number:"+ str.substr(found, 1));
    }
  }

  {NUM}\'[hH][[:alnum:]_\?]+ {
    string str = svtext;
    size_t q_pos = str.find_first_of("'");
    size_t found = str.find_first_not_of("0123456789abcdefABCDEF_?xXzZ", q_pos + 2);
    if ( found == string::npos ) {
      yylval->str = new string (svtext);
      return HEX_BASED_NUM;
    }
    else {
      svwrapper.error(svlineno, "Bad char in HEX number:"+ str.substr(found, 1));
    }
  }


  /* line comment */
  \/\/ yy_push_state(sc_line_cmt);
    
  /* block comment */
  "/*" yy_push_state(sc_blk_cmt);

}

<sc_line_cmt>{
  \n yylloc->lines(1); yy_pop_state();
  . /* zap comment */;
}

<sc_blk_cmt>{
  \n yylloc->lines(1);
  "*/" yy_pop_state();
  . 
}

<sc_function>{
    /* control directives */
   {CTRL_LINE} yy_push_state(sc_ctrl_line); 

   \n yylloc->lines(1); yylloc->step();
   {WS} yylloc->step();
   {K_ENDFUNCTION} yy_pop_state();
   <<EOF>> svwrapper.error(yylloc->end, "Unexpected End-of-file inside function definition.");
   . /* zap */ ;
}

<sc_task>{
    /* control directives */
   {CTRL_LINE} yy_push_state(sc_ctrl_line); 

   \n yylloc->lines(1); yylloc->step();
   {WS} yylloc->step();
   {K_ENDTASK} yy_pop_state();
   <<EOF>> svwrapper.error(yylloc->end, "Unexpected End-of-file inside task definition.");
   . /* zap */ ;
}


 /* use string */ 
<sc_use_string>{
  \\\" buf += "\"";
  \n svwrapper.error(yylloc->end, "Line break inside string");
  \" yy_pop_state();
  <<EOF>> svwrapper.error(yylloc->end, "Unexpected End-of-file inside string.");
  . buf += svtext;
}


{WS} yylloc->step();
\n yylloc->lines(1); yylloc->step();

<<EOF>>	return END;

. {  }



%%



void
CSVwrapper::OpenIO()
{
  // string post_pp_file = GetPostPPFileName(filename);
  
  string gen_file_path_name;

  svin = fopen(post_pp_file.c_str(), "r");

  if ( CopyVerilogCode ) {
     gen_file_path_name = GetGenFileName();
  }
  else {
     gen_file_path_name = "/dev/null";
  }
  svout = fopen(gen_file_path_name.c_str(), "w");

  if ( !svin ) {
     cerr << "\033[00;31m\n**" 
	  << "SV Lexer ERROR:\"" << filename << "\" pass PP, but temp file is losted." 
	  << "\033[00m" << endl;
     exit(1);
  }
  else if ( !svout ) {
     cerr << "\033[00;31m\n**" 
	  << "SV Lexer ERROR:\"" << gen_file_path_name << "\" cannot be opened for write."
	  << "\033[00m" << endl;
     exit(1);
  }

}

void
CSVwrapper::CloseIO()
{
  fclose(svin);
  fclose(svout);
}

