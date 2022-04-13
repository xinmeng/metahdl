%option yylineno
%option noyywrap
%option stack
%option debug
%option nounput
%option prefix="mhdl"
%option outfile="mlexer.flex.cc"

%{
#include <string>
#include <iostream>
#include <stack>

#include "mparser.bison.hh"
#include "MetaHDL.hh"


   std::stack<YY_BUFFER_STATE> MHDLBufStk;

   typedef yy::mParser::token mhdl_token;
#define YY_DECL \
   yy::mParser::token::yytokentype mhdllex(yy::mParser::semantic_type *yylval, yy::mParser::location_type *yylloc, CMHDLwrapper &mwrapper)

#define YY_USER_ACTION yylloc->columns(mhdlleng);

%}

%x sc_string sc_use_string
%x sc_line_cmt sc_blk_cmt sc_ctrl_line
%x sc_rawcode sc_function
%x sc_parse sc_message

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

 /* System Calls*/
K_CLOG2			  "$clog2"

 /* MetaHDL keywords */
K_METAHDL       "metahdl"
K_NONPORT       "nonport"
K_FF           "ff"           
K_ENDFF        "endff"        
K_FSM          "fsm"          
K_FSM_NC       "fsm_nc"          
K_ENDFSM       "endfsm"      
K_GOTO         "goto"
K_RAWCODE       "rawcode"
K_ENDRAWCODE    "endrawcode" 
K_MESSAGE "message"
K_PARSE         "parse"


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
PUNC_AT        "@"


 /* control directives */
CTRL_LINE "`line"

 /* other tokens */
ID [[:alpha:]_][[:alnum:]_]*
NUM [0-9]+
FLOAT [0-9]+\.[0-9]*
WS [ \t]+

%%
  static string buf;

{K_ALIAS} return mhdl_token::K_ALIAS;
{K_ALWAYS} return mhdl_token::K_ALWAYS;
{K_ALWAYS_COMB} return mhdl_token::K_ALWAYS_COMB;
{K_ALWAYS_FF} return mhdl_token::K_ALWAYS_FF;
{K_ALWAYS_LATCH} return mhdl_token::K_ALWAYS_LATCH;
{K_AND} return mhdl_token::K_AND;
{K_ASSERT} return mhdl_token::K_ASSERT;
{K_ASSIGN} return mhdl_token::K_ASSIGN;
{K_ASSUME} return mhdl_token::K_ASSUME;
{K_AUTOMATIC} return mhdl_token::K_AUTOMATIC;
{K_BEFORE} return mhdl_token::K_BEFORE;
{K_BEGIN} return mhdl_token::K_BEGIN;
{K_BIND} return mhdl_token::K_BIND;
{K_BINS} return mhdl_token::K_BINS;
{K_BINSOF} return mhdl_token::K_BINSOF;
{K_BIT} return mhdl_token::K_BIT;
{K_BREAK} return mhdl_token::K_BREAK;
{K_BUF} return mhdl_token::K_BUF;
{K_BUFIF0} return mhdl_token::K_BUFIF0;
{K_BUFIF1} return mhdl_token::K_BUFIF1;
{K_BYTE} return mhdl_token::K_BYTE;
{K_CASE} return mhdl_token::K_CASE;
{K_CASEX} return mhdl_token::K_CASEX;
{K_CASEZ} return mhdl_token::K_CASEZ;
{K_CELL} return mhdl_token::K_CELL;
{K_CHANDLE} return mhdl_token::K_CHANDLE;
{K_CLASS} return mhdl_token::K_CLASS;
{K_CLOCKING} return mhdl_token::K_CLOCKING;
{K_CMOS} return mhdl_token::K_CMOS;
{K_CONFIG} return mhdl_token::K_CONFIG;
{K_CONST} return mhdl_token::K_CONST;
{K_CONSTRAINT} return mhdl_token::K_CONSTRAINT;
{K_CONTEXT} return mhdl_token::K_CONTEXT;
{K_CONTINUE} return mhdl_token::K_CONTINUE;
{K_COVER} return mhdl_token::K_COVER;
{K_COVERGROUP} return mhdl_token::K_COVERGROUP;
{K_COVERPOINT} return mhdl_token::K_COVERPOINT;
{K_CROSS} return mhdl_token::K_CROSS;
{K_DEASSIGN} return mhdl_token::K_DEASSIGN;
{K_DEFAULT} return mhdl_token::K_DEFAULT;
{K_DEFPARAM} return mhdl_token::K_DEFPARAM;
{K_DESIGN} return mhdl_token::K_DESIGN;
{K_DISABLE} return mhdl_token::K_DISABLE;
{K_DIST} return mhdl_token::K_DIST;
{K_DO} return mhdl_token::K_DO;
{K_EDGE} return mhdl_token::K_EDGE;
{K_ELSE} return mhdl_token::K_ELSE;
{K_END} return mhdl_token::K_END;
{K_ENDCASE} return mhdl_token::K_ENDCASE;
{K_ENDCLASS} return mhdl_token::K_ENDCLASS;
{K_ENDCLOCKING} return mhdl_token::K_ENDCLOCKING;
{K_ENDCONFIG} return mhdl_token::K_ENDCONFIG;  
{K_ENDFUNCTION} return mhdl_token::K_ENDFUNCTION; 
{K_ENDGENERATE} return mhdl_token::K_ENDGENERATE;
{K_ENDGROUP} return mhdl_token::K_ENDGROUP;
{K_ENDINTERFACE} return mhdl_token::K_ENDINTERFACE;
{K_ENDMODULE} return mhdl_token::K_ENDMODULE;
{K_ENDPACKAGE} return mhdl_token::K_ENDPACKAGE;
{K_ENDPRIMITIVE} return mhdl_token::K_ENDPRIMITIVE;
{K_ENDPROGRAM} return mhdl_token::K_ENDPROGRAM;
{K_ENDPROPERTY} return mhdl_token::K_ENDPROPERTY;
{K_ENDSPECIFY} return mhdl_token::K_ENDSPECIFY;
{K_ENDSEQUENCE} return mhdl_token::K_ENDSEQUENCE;
{K_ENDTABLE} return mhdl_token::K_ENDTABLE;
{K_ENDTASK} return mhdl_token::K_ENDTASK;
{K_ENUM} return mhdl_token::K_ENUM;
{K_EVENT} return mhdl_token::K_EVENT;
{K_EXPECT} return mhdl_token::K_EXPECT;
{K_EXPORT} return mhdl_token::K_EXPORT;
{K_EXTENDS} return mhdl_token::K_EXTENDS;
{K_EXTERN} return mhdl_token::K_EXTERN;
{K_FINAL} return mhdl_token::K_FINAL;
{K_FIRST_MATCH} return mhdl_token::K_FIRST_MATCH;
{K_FOR} return mhdl_token::K_FOR;
{K_FORCE} return mhdl_token::K_FORCE;
{K_FOREACH} return mhdl_token::K_FOREACH;
{K_FOREVER} return mhdl_token::K_FOREVER;
{K_FORK} return mhdl_token::K_FORK;
{K_FORKJOIN} return mhdl_token::K_FORKJOIN;
{K_FUNCTION} yylloc->step(); yy_push_state(sc_function); return mhdl_token::K_FUNCTION;
{K_GENERATE} return mhdl_token::K_GENERATE;
{K_GENVAR} return mhdl_token::K_GENVAR;
{K_HIGHZ0} return mhdl_token::K_HIGHZ0;
{K_HIGHZ1} return mhdl_token::K_HIGHZ1;
{K_IF} return mhdl_token::K_IF;
{K_IFF} return mhdl_token::K_IFF;
{K_IFNONE} return mhdl_token::K_IFNONE;
{K_IGNORE_BINS} return mhdl_token::K_IGNORE_BINS;
{K_ILLEGAL_BINS} return mhdl_token::K_ILLEGAL_BINS;
{K_IMPORT} return mhdl_token::K_IMPORT;
{K_INCDIR} return mhdl_token::K_INCDIR;
{K_INCLUDE} return mhdl_token::K_INCLUDE;
{K_INITIAL} return mhdl_token::K_INITIAL;
{K_INOUT} return mhdl_token::K_INOUT;
{K_INPUT} return mhdl_token::K_INPUT;
{K_INSIDE} return mhdl_token::K_INSIDE;
{K_INSTANCE} return mhdl_token::K_INSTANCE;
{K_INT} return mhdl_token::K_INT;
{K_INTEGER} return mhdl_token::K_INTEGER;
{K_INTERFACE} return mhdl_token::K_INTERFACE;
{K_INTERSECT} return mhdl_token::K_INTERSECT;
{K_JOIN} return mhdl_token::K_JOIN;
{K_JOIN_ANY} return mhdl_token::K_JOIN_ANY;
{K_JOIN_NONE} return mhdl_token::K_JOIN_NONE;
{K_LARGE} return mhdl_token::K_LARGE;
{K_LIBLIST} return mhdl_token::K_LIBLIST;
{K_LIBRARY} return mhdl_token::K_LIBRARY;
{K_LOCAL} return mhdl_token::K_LOCAL;
{K_LOCALPARAM} return mhdl_token::K_LOCALPARAM;
{K_LOGIC} return mhdl_token::K_LOGIC;
{K_LONGINT} return mhdl_token::K_LONGINT;
{K_MACROMODULE} return mhdl_token::K_MACROMODULE;
{K_MATCHES} return mhdl_token::K_MATCHES;
{K_MEDIUM} return mhdl_token::K_MEDIUM;
{K_MODPORT} return mhdl_token::K_MODPORT;
{K_MODULE} return mhdl_token::K_MODULE;
{K_NAND} return mhdl_token::K_NAND;
{K_NEGEDGE} return mhdl_token::K_NEGEDGE;
{K_NEW} return mhdl_token::K_NEW;
{K_NMOS} return mhdl_token::K_NMOS;
{K_NOR} return mhdl_token::K_NOR;
{K_NOSHOWCANCELLED} return mhdl_token::K_NOSHOWCANCELLED;
{K_NOT} return mhdl_token::K_NOT;
{K_NOTIF0} return mhdl_token::K_NOTIF0;
{K_NOTIF1} return mhdl_token::K_NOTIF1;
{K_NULL} return mhdl_token::K_NULL;
{K_OR} return mhdl_token::K_OR;
{K_OUTPUT} return mhdl_token::K_OUTPUT;
{K_PACKAGE} return mhdl_token::K_PACKAGE;
{K_PACKED} return mhdl_token::K_PACKED;
{K_PARAMETER} return mhdl_token::K_PARAMETER;
{K_PMOS} return mhdl_token::K_PMOS;
{K_POSEDGE} return mhdl_token::K_POSEDGE;
{K_PRIMITIVE} return mhdl_token::K_PRIMITIVE;
{K_PRIORITY} return mhdl_token::K_PRIORITY;
{K_PROGRAM} return mhdl_token::K_PROGRAM;
{K_PROPERTY} return mhdl_token::K_PROPERTY;
{K_PROTECTED} return mhdl_token::K_PROTECTED;
{K_PULL0} return mhdl_token::K_PULL0;
{K_PULL1} return mhdl_token::K_PULL1;
{K_PULLDOWN} return mhdl_token::K_PULLDOWN;
{K_PULLUP} return mhdl_token::K_PULLUP;
{K_PULSESTYLE_ONEVENT} return mhdl_token::K_PULSESTYLE_ONEVENT;
{K_PULSESTYLE_ONDETECT} return mhdl_token::K_PULSESTYLE_ONDETECT;
{K_PURE} return mhdl_token::K_PURE;
{K_RAND} return mhdl_token::K_RAND;
{K_RANDC} return mhdl_token::K_RANDC;
{K_RANDCASE} return mhdl_token::K_RANDCASE;
{K_RANDSEQUENCE} return mhdl_token::K_RANDSEQUENCE;
{K_RCMOS} return mhdl_token::K_RCMOS;
{K_REAL} return mhdl_token::K_REAL;
{K_REALTIME} return mhdl_token::K_REALTIME;
{K_REF} return mhdl_token::K_REF;
{K_REG} return mhdl_token::K_REG;
{K_RELEASE} return mhdl_token::K_RELEASE;
{K_REPEAT} return mhdl_token::K_REPEAT;
{K_RETURN} return mhdl_token::K_RETURN;
{K_RNMOS} return mhdl_token::K_RNMOS;
{K_RPMOS} return mhdl_token::K_RPMOS;
{K_RTRAN} return mhdl_token::K_RTRAN;
{K_RTRANIF0} return mhdl_token::K_RTRANIF0;
{K_RTRANIF1} return mhdl_token::K_RTRANIF1;
{K_SCALARED} return mhdl_token::K_SCALARED;
{K_SEQUENCE} return mhdl_token::K_SEQUENCE;
{K_SHORTINT} return mhdl_token::K_SHORTINT;
{K_SHORTREAL} return mhdl_token::K_SHORTREAL;
{K_SHOWCANCELLED} return mhdl_token::K_SHOWCANCELLED;
{K_SIGNED} return mhdl_token::K_SIGNED;
{K_SMALL} return mhdl_token::K_SMALL;
{K_SOLVE} return mhdl_token::K_SOLVE;
{K_SPECIFY} return mhdl_token::K_SPECIFY;
{K_SPECPARAM} return mhdl_token::K_SPECPARAM;
{K_STATIC} return mhdl_token::K_STATIC;
{K_STRING} return mhdl_token::K_STRING;
{K_STRONG0} return mhdl_token::K_STRONG0;
{K_STRONG1} return mhdl_token::K_STRONG1;
{K_STRUCT} return mhdl_token::K_STRUCT;
{K_SUPER} return mhdl_token::K_SUPER;
{K_SUPPLY0} return mhdl_token::K_SUPPLY0;
{K_SUPPLY1} return mhdl_token::K_SUPPLY1;
{K_TABLE} return mhdl_token::K_TABLE;
{K_TAGGED} return mhdl_token::K_TAGGED;
{K_TASK} return mhdl_token::K_TASK;
{K_THIS} return mhdl_token::K_THIS;
{K_THROUGHOUT} return mhdl_token::K_THROUGHOUT;
{K_TIME} return mhdl_token::K_TIME;
{K_TIMEPRECISION} return mhdl_token::K_TIMEPRECISION;
{K_TIMEUNIT} return mhdl_token::K_TIMEUNIT;
{K_TRAN} return mhdl_token::K_TRAN;
{K_TRANIF0} return mhdl_token::K_TRANIF0;
{K_TRANIF1} return mhdl_token::K_TRANIF1;
{K_TRI} return mhdl_token::K_TRI;
{K_TRI0} return mhdl_token::K_TRI0;
{K_TRI1} return mhdl_token::K_TRI1;
{K_TRIAND} return mhdl_token::K_TRIAND;
{K_TRIOR} return mhdl_token::K_TRIOR;
{K_TRIREG} return mhdl_token::K_TRIREG;
{K_TYPE} return mhdl_token::K_TYPE;
{K_TYPEDEF} return mhdl_token::K_TYPEDEF;
{K_UNION} return mhdl_token::K_UNION;
{K_UNIQUE} return mhdl_token::K_UNIQUE;
{K_UNSIGNED} return mhdl_token::K_UNSIGNED;
{K_USE} return mhdl_token::K_USE;
{K_VAR} return mhdl_token::K_VAR;
{K_VECTORED} return mhdl_token::K_VECTORED;
{K_VIRTUAL} return mhdl_token::K_VIRTUAL;
{K_VOID} return mhdl_token::K_VOID;
{K_WAIT} return mhdl_token::K_WAIT;
{K_WAIT_ORDER} return mhdl_token::K_WAIT_ORDER;
{K_WAND} return mhdl_token::K_WAND;
{K_WEAK0} return mhdl_token::K_WEAK0;
{K_WEAK1} return mhdl_token::K_WEAK1;
{K_WHILE} return mhdl_token::K_WHILE;
{K_WILDCARD} return mhdl_token::K_WILDCARD;
{K_WIRE} return mhdl_token::K_WIRE;
{K_WITH} return mhdl_token::K_WITH;
{K_WITHIN} return mhdl_token::K_WITHIN;
{K_WOR} return mhdl_token::K_WOR;
{K_XNOR} return mhdl_token::K_XNOR;
{K_XOR} return mhdl_token::K_XOR;

  /* System Call */
  {K_CLOG2} return mhdl_token::K_CLOG2;

 /* MetaHDL keywords */
{K_METAHDL} return mhdl_token::K_METAHDL;
{K_NONPORT} return mhdl_token::K_NONPORT;
{K_FF} return mhdl_token::K_FF;
{K_ENDFF} return mhdl_token::K_ENDFF;
{K_GOTO} return mhdl_token::K_GOTO;
{K_FSM} return mhdl_token::K_FSM;
{K_FSM_NC} return mhdl_token::K_FSM_NC;
{K_ENDFSM} return mhdl_token::K_ENDFSM;

 /* sc_message */
{K_MESSAGE} yylloc->step(); yy_push_state(sc_message); return mhdl_token::K_MESSAGE;
<sc_message>{
  {PUNC_SEMICOLON} yy_pop_state(); return mhdl_token::PUNC_SEMICOLON;
  \n mwrapper.error(yylloc->end, "Unexpected new line inside parse statement.");
  <<EOF>> mwrapper.error(yylloc->end, "Unexpected End-of-file inside parse statement.");
  . yylval->str = new string (mhdltext); return mhdl_token::VERBTIM;
}

 /* sc_parse */ 
{K_PARSE} yylloc->step(); yy_push_state(sc_parse); return mhdl_token::K_PARSE;
<sc_parse>{
  {PUNC_SEMICOLON} yy_pop_state(); return mhdl_token::PUNC_SEMICOLON;
  \n mwrapper.error(yylloc->end, "Unexpected new line inside parse statement.");
  <<EOF>> mwrapper.error(yylloc->end, "Unexpected End-of-file inside parse statement.");
  . yylval->str = new string (mhdltext); return mhdl_token::VERBTIM;
}



 /* operators */
{OR} return mhdl_token::OR;
{AND} return mhdl_token::AND;
{XOR} return mhdl_token::XOR;

{UNARY_NOT} return mhdl_token::UNARY_NOT;

{BINARY_PLUS} return mhdl_token::BINARY_PLUS;
{BINARY_MINUS} return mhdl_token::BINARY_MINUS;
{BINARY_MULT} return mhdl_token::BINARY_MULT;
{BINARY_DIV} return mhdl_token::BINARY_DIV;
{BINARY_MOD} return mhdl_token::BINARY_MOD;
{BINARY_PWR} return mhdl_token::BINARY_PWR;
{BINARY_LSH} return mhdl_token::BINARY_LSH;
{BINARY_RSH} return mhdl_token::BINARY_RSH;

{COND_NOT} return mhdl_token::COND_NOT;
{COND_AND} return mhdl_token::COND_AND;
{COND_OR} return mhdl_token::COND_OR;
{COND_LT} return mhdl_token::COND_LT;
{COND_GT} return mhdl_token::COND_GT;
{COND_EQ} return mhdl_token::COND_EQ;
{COND_NE} return mhdl_token::COND_NE;
{COND_LE} return mhdl_token::COND_LE;
{COND_GE} return mhdl_token::COND_GE;


{TRI_QUESTION} return mhdl_token::TRI_QUESTION;
{TRI_COLON} return mhdl_token::TRI_COLON;


 /* punctuations */
{PUNC_EQUAL} return mhdl_token::PUNC_EQUAL;
{PUNC_COMMA} return mhdl_token::PUNC_COMMA;
{PUNC_DOT} return mhdl_token::PUNC_DOT;
{PUNC_SEMICOLON} return mhdl_token::PUNC_SEMICOLON;
{PUNC_LBRACE} return mhdl_token::PUNC_LBRACE;
{PUNC_RBRACE} return mhdl_token::PUNC_RBRACE;
{PUNC_LPAREN} return mhdl_token::PUNC_LPAREN;
{PUNC_RPAREN} return mhdl_token::PUNC_RPAREN;
{PUNC_LBRECT} return mhdl_token::PUNC_LBRECT;
{PUNC_RBRECT} return mhdl_token::PUNC_RBRECT;
{PUNC_CHARP} return mhdl_token::PUNC_CHARP;
{PUNC_AT} return mhdl_token::PUNC_AT;


 /* sc_rawcode */ 
{K_RAWCODE} yylloc->step(); yy_push_state(sc_rawcode); return mhdl_token::K_RAWCODE;
<sc_rawcode>{
  {K_ENDRAWCODE}  yy_pop_state(); return mhdl_token::K_ENDRAWCODE;
  \n yylloc->lines(1); yylval->str = new string (mhdltext); return mhdl_token::VERBTIM;
  <<EOF>> mwrapper.error(yylloc->end, "Unexpected End-of-file inside rawcode.");
  . yylval->str = new string (mhdltext); return mhdl_token::VERBTIM;
}

 /* sc_function */
<sc_function>{
  {K_ENDFUNCTION} yy_pop_state(); return mhdl_token::K_ENDFUNCTION;
  \n yylloc->lines(1); yylval->str = new string (mhdltext); return mhdl_token::VERBTIM;
  <<EOF>> mwrapper.error(yylloc->end, "Unexpected End-of-file inside function definition.");
  . yylval->str = new string (mhdltext); return mhdl_token::VERBTIM;
}


 /* other tokens */
{ID} yylval->str = new string (mhdltext); return mhdl_token::ID;
{NUM} {
  yylval->str = new string (mhdltext);
  return mhdl_token::NUM;
}

{FLOAT} {
  yylval->str = new string (mhdltext);
  return mhdl_token::FLOAT;
}

{WS} yylloc->step();
\n   yylloc->lines(1); yylloc->step();


 /* control directives */
{CTRL_LINE} yy_push_state(sc_ctrl_line); 
<sc_ctrl_line>{
  {WS} 
  {NUM} yylloc->lines(-yylloc->end.line + atoi(mhdltext)); 
  "\""  buf.erase(); yy_push_state(sc_use_string);
  \n {
    yylloc->begin.filename = yylloc->end.filename = new string (buf); 
    buf.erase();
    yylloc->lines(0); yylloc->step(); yy_pop_state(); 
  }
  .  mwrapper.error(yylloc->end, (string)"Unexpected char in `line directive:"+mhdltext);
}
  

 /* string */ 
\" buf = ""; yy_push_state(sc_string);
<sc_string>{
  \\\" buf += "\"";
  \n mwrapper.error(yylloc->end, "Line break inside string");
  \" {
    yylval->str = new string (buf); 
    buf.erase();
    yy_pop_state(); 
    return mhdl_token::STRING; 
  }
  <<EOF>> mwrapper.error(yylloc->end, "Unexpected End-of-file inside string.");
  . buf += mhdltext; 
}

 /* use string */ 
<sc_use_string>{
  \\\" buf += "\"";
  \n mwrapper.error(yylloc->end, "Line break inside string");
  \" yy_pop_state();
  <<EOF>> mwrapper.error(yylloc->end, "Unexpected End-of-file inside string.");
  . buf += mhdltext;
}
    


 /* line comment */
\/\/ yy_push_state(sc_line_cmt);
<sc_line_cmt>{
  \n yylloc->lines(1); yylloc->step(); yy_pop_state();
  . 
}
    
 /* block comment */
"/*" yy_push_state(sc_blk_cmt);
<sc_blk_cmt>{
  \n yylloc->lines(1); yylloc->step(); 
  "*/" yy_pop_state(); yylloc->step(); 
  <<EOF>> mwrapper.error(yylloc->end, "Unexpected End-of-file in block comment.");
  . /* zap */
  
}


 /* based number */ 
{NUM}\'[bB][[:alnum:]_\?]+ {
  string str = mhdltext;
  size_t q_pos = str.find_first_of("'");
  size_t found = str.find_first_not_of("01_?xXzZ", q_pos + 2);
  if ( found == string::npos ) {
    yylval->str = new string (mhdltext);
    return mhdl_token::BIN_BASED_NUM;
  }
  else {
    mwrapper.error(yylloc->end.line, "Bad char in BIN number:"+ str.substr(found, 1));
  }
}

{NUM}\'[dD][[:alnum:]_\?]+ {
  string str = mhdltext;
  size_t q_pos = str.find_first_of("'");
  size_t found = str.find_first_not_of("0123456789_?xXzZ", q_pos + 2);
  if ( found == string::npos ) {
    yylval->str = new string (mhdltext);
    return mhdl_token::DEC_BASED_NUM;
  }
  else {
    mwrapper.error(yylloc->end.line, "Bad char in DEC number:"+ str.substr(found, 1));
  }
}

{NUM}\'[hH][[:alnum:]_\?]+ {
  string str = mhdltext;
  size_t q_pos = str.find_first_of("'");
  size_t found = str.find_first_not_of("0123456789abcdefABCDEF_?xXzZ", q_pos + 2);
  if ( found == string::npos ) {
    yylval->str = new string (mhdltext);
    return mhdl_token::HEX_BASED_NUM;
  }
  else {
    mwrapper.error(yylloc->end.line, "Bad char in HEX number:"+ str.substr(found, 1));
  }
}



<<EOF>>	return mhdl_token::END;

. {
  string msg = "unexpected char:"; 
  msg += mhdltext; 
  mwrapper.error(yylloc->end, msg);
  }



%%


int
CMHDLwrapper::HierDepth()
{
  return MHDLBufStk.size();
}

void 
CMHDLwrapper::SwitchLexerSrc()
{
  // string post_pp_file = GetPostPPFileName(filename);

  MHDLBufStk.push(YY_CURRENT_BUFFER);
  
  mhdlin = fopen(post_pp_file.c_str(), "r");
  mhdl_switch_to_buffer(mhdl_create_buffer(mhdlin, YY_BUF_SIZE));

}

void
CMHDLwrapper::RestoreLexerSrc(void)
{
  mhdl_switch_to_buffer(MHDLBufStk.top());
  MHDLBufStk.pop();
}

void
CMHDLwrapper::OpenIO()
{
  // string post_pp_file = GetPostPPFileName(filename);
  
  mhdlin = fopen(post_pp_file.c_str(), "r");
  if ( !mhdlin ) {
    cerr << "*Mwrapper Err: \"" << filename << "\" pass PP, but temp file is losted." << endl;
    exit(1);
  }

}

void
CMHDLwrapper::CloseIO()
{
  fclose(mhdlin);
}

