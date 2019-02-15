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

   typedef yy::svParser::token sv_token;
#define YY_DECL \
   yy::svParser::token::yytokentype svlex(yy::svParser::semantic_type *yylval, yy::svParser::location_type *yylloc, CSVwrapper &svwrapper)


#define YY_USER_ACTION ECHO; yylloc->columns(svleng);

extern bool CopyVerilogCode;

%}

%x sc_string sc_line_cmt sc_blk_cmt sc_ctrl_line sc_use_string sc_string_out
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
BINARY_PWR   "**"
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


{K_ENDMODULE} return sv_token::K_ENDMODULE;

{K_MODULE} yy_push_state(sc_parse_mode); return sv_token::K_MODULE;
{K_INOUT} yy_push_state(sc_parse_mode); return sv_token::K_INOUT;
{K_INPUT} yy_push_state(sc_parse_mode); return sv_token::K_INPUT;
{K_OUTPUT} yy_push_state(sc_parse_mode); return sv_token::K_OUTPUT;
{K_PARAMETER} yy_push_state(sc_parse_mode); return sv_token::K_PARAMETER;
 /*{K_LOCALPARAM} yy_push_state(sc_parse_mode); return sv_token::K_LOCALPARAM;*/

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

  {K_ALIAS} return sv_token::K_ALIAS;
  {K_ALWAYS} return sv_token::K_ALWAYS;
  {K_ALWAYS_COMB} return sv_token::K_ALWAYS_COMB;
  {K_ALWAYS_FF} return sv_token::K_ALWAYS_FF;
  {K_ALWAYS_LATCH} return sv_token::K_ALWAYS_LATCH;
  {K_AND} return sv_token::K_AND;
  {K_ASSERT} return sv_token::K_ASSERT;
  {K_ASSIGN} return sv_token::K_ASSIGN;
  {K_ASSUME} return sv_token::K_ASSUME;
  {K_AUTOMATIC} return sv_token::K_AUTOMATIC;
  {K_BEFORE} return sv_token::K_BEFORE;
  {K_BEGIN} return sv_token::K_BEGIN;
  {K_BIND} return sv_token::K_BIND;
  {K_BINS} return sv_token::K_BINS;
  {K_BINSOF} return sv_token::K_BINSOF;
  {K_BIT} return sv_token::K_BIT;
  {K_BREAK} return sv_token::K_BREAK;
  {K_BUF} return sv_token::K_BUF;
  {K_BUFIF0} return sv_token::K_BUFIF0;
  {K_BUFIF1} return sv_token::K_BUFIF1;
  {K_BYTE} return sv_token::K_BYTE;
  {K_CASE} return sv_token::K_CASE;
  {K_CASEX} return sv_token::K_CASEX;
  {K_CASEZ} return sv_token::K_CASEZ;
  {K_CELL} return sv_token::K_CELL;
  {K_CHANDLE} return sv_token::K_CHANDLE;
  {K_CLASS} return sv_token::K_CLASS;
  {K_CLOCKING} return sv_token::K_CLOCKING;
  {K_CMOS} return sv_token::K_CMOS;
  {K_CONFIG} return sv_token::K_CONFIG;
  {K_CONST} return sv_token::K_CONST;
  {K_CONSTRAINT} return sv_token::K_CONSTRAINT;
  {K_CONTEXT} return sv_token::K_CONTEXT;
  {K_CONTINUE} return sv_token::K_CONTINUE;
  {K_COVER} return sv_token::K_COVER;
  {K_COVERGROUP} return sv_token::K_COVERGROUP;
  {K_COVERPOINT} return sv_token::K_COVERPOINT;
  {K_CROSS} return sv_token::K_CROSS;
  {K_DEASSIGN} return sv_token::K_DEASSIGN;
  {K_DEFAULT} return sv_token::K_DEFAULT;
  {K_DEFPARAM} return sv_token::K_DEFPARAM;
  {K_DESIGN} return sv_token::K_DESIGN;
  {K_DISABLE} return sv_token::K_DISABLE;
  {K_DIST} return sv_token::K_DIST;
  {K_DO} return sv_token::K_DO;
  {K_EDGE} return sv_token::K_EDGE;
  {K_ELSE} return sv_token::K_ELSE;
  {K_END} return sv_token::K_END;
  {K_ENDCASE} return sv_token::K_ENDCASE;
  {K_ENDCLASS} return sv_token::K_ENDCLASS;
  {K_ENDCLOCKING} return sv_token::K_ENDCLOCKING;
  {K_ENDCONFIG} return sv_token::K_ENDCONFIG;
  {K_ENDFUNCTION} return sv_token::K_ENDFUNCTION;
  {K_ENDGENERATE} return sv_token::K_ENDGENERATE;
  {K_ENDGROUP} return sv_token::K_ENDGROUP;
  {K_ENDINTERFACE} return sv_token::K_ENDINTERFACE;
  {K_ENDPACKAGE} return sv_token::K_ENDPACKAGE;
  {K_ENDPRIMITIVE} return sv_token::K_ENDPRIMITIVE;
  {K_ENDPROGRAM} return sv_token::K_ENDPROGRAM;
  {K_ENDPROPERTY} return sv_token::K_ENDPROPERTY;
  {K_ENDSPECIFY} return sv_token::K_ENDSPECIFY;
  {K_ENDSEQUENCE} return sv_token::K_ENDSEQUENCE;
  {K_ENDTABLE} return sv_token::K_ENDTABLE;
  {K_ENDTASK} return sv_token::K_ENDTASK;
  {K_ENUM} return sv_token::K_ENUM;
  {K_EVENT} return sv_token::K_EVENT;
  {K_EXPECT} return sv_token::K_EXPECT;
  {K_EXPORT} return sv_token::K_EXPORT;
  {K_EXTENDS} return sv_token::K_EXTENDS;
  {K_EXTERN} return sv_token::K_EXTERN;
  {K_FINAL} return sv_token::K_FINAL;
  {K_FIRST_MATCH} return sv_token::K_FIRST_MATCH;
  {K_FOR} return sv_token::K_FOR;
  {K_FORCE} return sv_token::K_FORCE;
  {K_FOREACH} return sv_token::K_FOREACH;
  {K_FOREVER} return sv_token::K_FOREVER;
  {K_FORK} return sv_token::K_FORK;
  {K_FORKJOIN} return sv_token::K_FORKJOIN;
  {K_FUNCTION} return sv_token::K_FUNCTION;
  {K_GENERATE} return sv_token::K_GENERATE;
  {K_GENVAR} return sv_token::K_GENVAR;
  {K_HIGHZ0} return sv_token::K_HIGHZ0;
  {K_HIGHZ1} return sv_token::K_HIGHZ1;
  {K_IF} return sv_token::K_IF;
  {K_IFF} return sv_token::K_IFF;
  {K_IFNONE} return sv_token::K_IFNONE;
  {K_IGNORE_BINS} return sv_token::K_IGNORE_BINS;
  {K_ILLEGAL_BINS} return sv_token::K_ILLEGAL_BINS;
  {K_IMPORT} return sv_token::K_IMPORT;
  {K_INCDIR} return sv_token::K_INCDIR;
  {K_INCLUDE} return sv_token::K_INCLUDE;
  {K_INITIAL} return sv_token::K_INITIAL;
  {K_INOUT} return sv_token::K_INOUT;
  {K_INPUT} return sv_token::K_INPUT;
  {K_INSIDE} return sv_token::K_INSIDE;
  {K_INSTANCE} return sv_token::K_INSTANCE;
  {K_INT} return sv_token::K_INT;
  {K_INTEGER} return sv_token::K_INTEGER;
  {K_INTERFACE} return sv_token::K_INTERFACE;
  {K_INTERSECT} return sv_token::K_INTERSECT;
  {K_JOIN} return sv_token::K_JOIN;
  {K_JOIN_ANY} return sv_token::K_JOIN_ANY;
  {K_JOIN_NONE} return sv_token::K_JOIN_NONE;
  {K_LARGE} return sv_token::K_LARGE;
  {K_LIBLIST} return sv_token::K_LIBLIST;
  {K_LIBRARY} return sv_token::K_LIBRARY;
  {K_LOCAL} return sv_token::K_LOCAL;
  {K_LOCALPARAM} return sv_token::K_LOCALPARAM;
  {K_LOGIC} return sv_token::K_LOGIC;
  {K_LONGINT} return sv_token::K_LONGINT;
  {K_MACROMODULE} return sv_token::K_MACROMODULE;
  {K_MATCHES} return sv_token::K_MATCHES;
  {K_MEDIUM} return sv_token::K_MEDIUM;
  {K_MODPORT} return sv_token::K_MODPORT;
  {K_NAND} return sv_token::K_NAND;
  {K_NEGEDGE} return sv_token::K_NEGEDGE;
  {K_NEW} return sv_token::K_NEW;
  {K_NMOS} return sv_token::K_NMOS;
  {K_NOR} return sv_token::K_NOR;
  {K_NOSHOWCANCELLED} return sv_token::K_NOSHOWCANCELLED;
  {K_NOT} return sv_token::K_NOT;
  {K_NOTIF0} return sv_token::K_NOTIF0;
  {K_NOTIF1} return sv_token::K_NOTIF1;
  {K_NULL} return sv_token::K_NULL;
  {K_OR} return sv_token::K_OR;
  {K_OUTPUT} return sv_token::K_OUTPUT;
  {K_PACKAGE} return sv_token::K_PACKAGE;
  {K_PACKED} return sv_token::K_PACKED;
  {K_PARAMETER} return sv_token::K_PARAMETER;
  {K_PMOS} return sv_token::K_PMOS;
  {K_POSEDGE} return sv_token::K_POSEDGE;
  {K_PRIMITIVE} return sv_token::K_PRIMITIVE;
  {K_PRIORITY} return sv_token::K_PRIORITY;
  {K_PROGRAM} return sv_token::K_PROGRAM;
  {K_PROPERTY} return sv_token::K_PROPERTY;
  {K_PROTECTED} return sv_token::K_PROTECTED;
  {K_PULL0} return sv_token::K_PULL0;
  {K_PULL1} return sv_token::K_PULL1;
  {K_PULLDOWN} return sv_token::K_PULLDOWN;
  {K_PULLUP} return sv_token::K_PULLUP;
  {K_PULSESTYLE_ONEVENT} return sv_token::K_PULSESTYLE_ONEVENT;
  {K_PULSESTYLE_ONDETECT} return sv_token::K_PULSESTYLE_ONDETECT;
  {K_PURE} return sv_token::K_PURE;
  {K_RAND} return sv_token::K_RAND;
  {K_RANDC} return sv_token::K_RANDC;
  {K_RANDCASE} return sv_token::K_RANDCASE;
  {K_RANDSEQUENCE} return sv_token::K_RANDSEQUENCE;
  {K_RCMOS} return sv_token::K_RCMOS;
  {K_REAL} return sv_token::K_REAL;
  {K_REALTIME} return sv_token::K_REALTIME;
  {K_REF} return sv_token::K_REF;
  {K_REG} return sv_token::K_REG;
  {K_RELEASE} return sv_token::K_RELEASE;
  {K_REPEAT} return sv_token::K_REPEAT;
  {K_RETURN} return sv_token::K_RETURN;
  {K_RNMOS} return sv_token::K_RNMOS;
  {K_RPMOS} return sv_token::K_RPMOS;
  {K_RTRAN} return sv_token::K_RTRAN;
  {K_RTRANIF0} return sv_token::K_RTRANIF0;
  {K_RTRANIF1} return sv_token::K_RTRANIF1;
  {K_SCALARED} return sv_token::K_SCALARED;
  {K_SEQUENCE} return sv_token::K_SEQUENCE;
  {K_SHORTINT} return sv_token::K_SHORTINT;
  {K_SHORTREAL} return sv_token::K_SHORTREAL;
  {K_SHOWCANCELLED} return sv_token::K_SHOWCANCELLED;
  {K_SIGNED} return sv_token::K_SIGNED;
  {K_SMALL} return sv_token::K_SMALL;
  {K_SOLVE} return sv_token::K_SOLVE;
  {K_SPECIFY} return sv_token::K_SPECIFY;
  {K_SPECPARAM} return sv_token::K_SPECPARAM;
  {K_STATIC} return sv_token::K_STATIC;
  {K_STRING} return sv_token::K_STRING;
  {K_STRONG0} return sv_token::K_STRONG0;
  {K_STRONG1} return sv_token::K_STRONG1;
  {K_STRUCT} return sv_token::K_STRUCT;
  {K_SUPER} return sv_token::K_SUPER;
  {K_SUPPLY0} return sv_token::K_SUPPLY0;
  {K_SUPPLY1} return sv_token::K_SUPPLY1;
  {K_TABLE} return sv_token::K_TABLE;
  {K_TAGGED} return sv_token::K_TAGGED;
  {K_TASK} return sv_token::K_TASK;
  {K_THIS} return sv_token::K_THIS;
  {K_THROUGHOUT} return sv_token::K_THROUGHOUT;
  {K_TIME} return sv_token::K_TIME;
  {K_TIMEPRECISION} return sv_token::K_TIMEPRECISION;
  {K_TIMEUNIT} return sv_token::K_TIMEUNIT;
  {K_TRAN} return sv_token::K_TRAN;
  {K_TRANIF0} return sv_token::K_TRANIF0;
  {K_TRANIF1} return sv_token::K_TRANIF1;
  {K_TRI} return sv_token::K_TRI;
  {K_TRI0} return sv_token::K_TRI0;
  {K_TRI1} return sv_token::K_TRI1;
  {K_TRIAND} return sv_token::K_TRIAND;
  {K_TRIOR} return sv_token::K_TRIOR;
  {K_TRIREG} return sv_token::K_TRIREG;
  {K_TYPE} return sv_token::K_TYPE;
  {K_TYPEDEF} return sv_token::K_TYPEDEF;
  {K_UNION} return sv_token::K_UNION;
  {K_UNIQUE} return sv_token::K_UNIQUE;
  {K_UNSIGNED} return sv_token::K_UNSIGNED;
  {K_USE} return sv_token::K_USE;
  {K_VAR} return sv_token::K_VAR;
  {K_VECTORED} return sv_token::K_VECTORED;
  {K_VIRTUAL} return sv_token::K_VIRTUAL;
  {K_VOID} return sv_token::K_VOID;
  {K_WAIT} return sv_token::K_WAIT;
  {K_WAIT_ORDER} return sv_token::K_WAIT_ORDER;
  {K_WAND} return sv_token::K_WAND;
  {K_WEAK0} return sv_token::K_WEAK0;
  {K_WEAK1} return sv_token::K_WEAK1;
  {K_WHILE} return sv_token::K_WHILE;
  {K_WILDCARD} return sv_token::K_WILDCARD;
  {K_WIRE} return sv_token::K_WIRE;
  {K_WITH} return sv_token::K_WITH;
  {K_WITHIN} return sv_token::K_WITHIN;
  {K_WOR} return sv_token::K_WOR;
  {K_XNOR} return sv_token::K_XNOR;
  {K_XOR} return sv_token::K_XOR;

  /* operators */
  {OR} return sv_token::OR;
  {AND} return sv_token::AND;
  {XOR} return sv_token::XOR;

  {UNARY_NOT} return sv_token::UNARY_NOT;

  {BINARY_PLUS} return sv_token::BINARY_PLUS;
  {BINARY_MINUS} return sv_token::BINARY_MINUS;
  {BINARY_MULT} return sv_token::BINARY_MULT;
  {BINARY_DIV} return sv_token::BINARY_DIV;
  {BINARY_MOD} return sv_token::BINARY_MOD;
  {BINARY_PWR} return sv_token::BINARY_PWR;
  {BINARY_LSH} return sv_token::BINARY_LSH;
  {BINARY_RSH} return sv_token::BINARY_RSH;

  {COND_NOT} return sv_token::COND_NOT;
  {COND_AND} return sv_token::COND_AND;
  {COND_OR} return sv_token::COND_OR;
  {COND_LT} return sv_token::COND_LT;
  {COND_GT} return sv_token::COND_GT;
  {COND_EQ} return sv_token::COND_EQ;
  {COND_NE} return sv_token::COND_NE;
  {COND_LE} return sv_token::COND_LE;
  {COND_GE} return sv_token::COND_GE;


  {TRI_QUESTION} return sv_token::TRI_QUESTION;
  {TRI_COLON} return sv_token::TRI_COLON;


  /* punctuations */
  {PUNC_EQUAL} return sv_token::PUNC_EQUAL;
  {PUNC_COMMA} return sv_token::PUNC_COMMA;
  {PUNC_DOT} return sv_token::PUNC_DOT;
  {PUNC_LBRACE} return sv_token::PUNC_LBRACE;
  {PUNC_RBRACE} return sv_token::PUNC_RBRACE;
  {PUNC_LPAREN} return sv_token::PUNC_LPAREN;
  {PUNC_RPAREN} return sv_token::PUNC_RPAREN;
  {PUNC_LBRECT} return sv_token::PUNC_LBRECT;
  {PUNC_RBRECT} return sv_token::PUNC_RBRECT;
  {PUNC_CHARP} return sv_token::PUNC_CHARP;
  {PUNC_SEMICOLON} yy_pop_state(); return sv_token::PUNC_SEMICOLON;



  /* other tokens */
  {ID} yylval->str = new string (svtext); return sv_token::ID;
  {NUM} {
    yylval->str = new string (svtext);
    return sv_token::NUM;
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
      return sv_token::BIN_BASED_NUM;
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
      return sv_token::DEC_BASED_NUM;
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
      return sv_token::HEX_BASED_NUM;
    }
    else {
      svwrapper.error(svlineno, "Bad char in HEX number:"+ str.substr(found, 1));
    }
  }


  /* string */
  \" buf = ""; yy_push_state(sc_string);
  <sc_string>{
      \\\" buf += "\"";
      \n svwrapper.error(yylloc->end, "Line break inside string");
      \" {
          yylval->str = new string (buf); 
          buf.erase();
          yy_pop_state(); 
          return sv_token::STRING; 
      }
      <<EOF>> svwrapper.error(yylloc->end, "Unexpected End-of-file inside string.");
      . buf += svtext; 
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

  /* string outside of parsing scope */
\" yy_push_state(sc_string_out);
<sc_string_out>{
    \\\" { } 
    \n svwrapper.error(yylloc->end, "Line break inside string");
    \" yy_pop_state(); 
    <<EOF>> svwrapper.error(yylloc->end, "Unexpected End-of-file inside string.");
    . { } // buf += svtext; 
}


<<EOF>>	return sv_token::END;

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

