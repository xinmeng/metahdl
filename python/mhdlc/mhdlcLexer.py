#!/usr/bin/python3

import re
import pathlib

from mhdlcException import *
import GreedyLexer
TokenRule          = GreedyLexer.TokenRule
StartCondition     = GreedyLexer.StartCondition
GLexer             = GreedyLexer.GLexer
FileInputBuffer    = GreedyLexer.FileInputBuffer
StringInputBuffer  = GreedyLexer.StringInputBuffer

CORE_TOKEN = []
MACRO_TOKEN = []


MHDL_KEYWORD = ['alias', 'always', 'always_comb', 'always_ff', 
                'always_latch', 'and', 'assert', 'assign', 
                'assume', 'automatic', 'before', 'begin', 
                'bind', 'bins', 'binsof', 'bit', 
                'break', 'buf', 'bufif0', 'bufif1', 
                'byte', 'case', 'casex', 'casez', 
                'cell', 'chandle', 'class', 'clocking', 
                'cmos', 'config', 'const', 'constraint', 
                'context', 'continue', 'cover', 'covergroup', 
                'coverpoint', 'cross', 'deassign', 'default', 
                'defparam', 'design', 'disable', 'dist', 
                'do', 'edge', 'else', 'end', 
                'endcase', 'endclass', 'endclocking', 'endconfig', 
                'endfunction', 'endgenerate', 'endgroup', 'endinterface', 
                'endmodule', 'endpackage', 'endprimitive', 'endprogram', 
                'endproperty', 'endspecify', 'endsequence', 'endtable', 
                'endtask', 'enum', 'event', 'expect', 
                'export', 'extends', 'extern', 'final', 
                'first_match', 'for', 'force', 'foreach', 
                'forever', 'fork', 'forkjoin', 'function', 
                'generate', 'genvar', 'highz0', 'highz1', 
                'if', 'iff', 'ifnone', 'ignore_bins', 
                'illegal_bins', 'import', 'incdir', 'include', 
                'initial', 'inout', 'input', 'inside', 
                'instance', 'int', 'integer', 'interface', 
                'intersect', 'join', 'join_any', 'join_none', 
                'large', 'liblist', 'library', 'local', 
                'localparam', 'logic', 'longint', 'macromodule', 
                'matches', 'medium', 'modport', 'module', 
                'nand', 'negedge', 'new', 'nmos', 
                'nor', 'noshowcancelled', 'not', 'notif0', 
                'notif1', 'null', 'or', 'output', 
                'package', 'packed', 'parameter', 'pmos', 
                'posedge', 'primitive', 'priority', 'program', 
                'property', 'protected', 'pull0', 'pull1', 
                'pulldown', 'pullup', 'pulsestyle_onevent', 'pulsestyle_ondetect', 
                'pure', 'rand', 'randc', 'randcase', 
                'randsequence', 'rcmos', 'real', 'realtime', 
                'ref', 'reg', 'release', 'repeat', 
                'return', 'rnmos', 'rpmos', 'rtran', 
                'rtranif0', 'rtranif1', 'scalared', 'sequence', 
                'shortint', 'shortreal', 'showcancelled', 'signed', 
                'small', 'solve', 'specify', 'specparam', 
                'static', 'string', 'strong0', 'strong1', 
                'struct', 'super', 'supply0', 'supply1', 
                'table', 'tagged', 'task', 'this', 
                'throughout', 'time', 'timeprecision', 'timeunit', 
                'tran', 'tranif0', 'tranif1', 'tri', 
                'tri0', 'tri1', 'triand', 'trior', 
                'trireg', 'type', 'typedef', 'union', 
                'unique', 'unsigned', 'use', 'var', 
                'vectored', 'virtual', 'void', 'wait', 
                'wait_order', 'wand', 'weak0', 'weak1', 
                'while', 'wildcard', 'wire', 'with', 
                'within', 'wor', 'xnor', 'xor', ]

MHDL_KEYWORD += ['metahdl',
                 'nonport',
                 'ff', 'endff', 
                 'fsm', 'fsm_nc',  'endfsm', 'goto', 
                 'rawcode', 'endrawcode', 
                 'message', 'parse']


MHDL_KEYWORD_TOKEN = list()
for k in MHDL_KEYWORD:
    MHDL_KEYWORD_TOKEN.append('K_' + k.upper())


MACRO_KEYWORD = ['if', 'ifdef', 'ifndef', 
                 'else', 'elseif', 'elseifdef', 'elseifndef', 'endif', 
                 'define', 
                 'for', 'endfor', 'let',
                 'include', 'line', ]

MACRO_KEYWORD_TOKEN = list()
for k in MACRO_KEYWORD:
    MACRO_KEYWORD_TOKEN.append('K_MACRO_' + k.upper())



CORE_TOKEN += MHDL_KEYWORD_TOKEN
CORE_TOKEN += ['EOF', 'LITERAL', 'SPACE', 'NEWLINE', 'ID']
class t_LITERAL(TokenRule):
    def __init__(self, sc):
        self.pattern = r'.'
        self.type    = 'LITERAL'
        TokenRule.__init__(self, sc)


class t_SPACE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'[ \t]+'
        self.type    = 'SPACE'
        TokenRule.__init__(self, sc)


class t_NEWLINE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\n'
        self.type    = 'NEWLINE'
        TokenRule.__init__(self, sc)

class t_ID(TokenRule):
    def __init__(self, sc):
        self.pattern = r'[_A-Z][_A-Z0-9]*'
        self.type    = 'ID'
        TokenRule.__init__(self, sc, re.I)

    def PostAction(self, token):
        if token.value in MHDL_KEYWORD:
            token.type = 'K_' + token.value.upper()
        return token

CORE_TOKEN += ['INTEGER', 'FLOAT', 'BASED_NUMBER', 'STRING']
class t_INTEGER(TokenRule):
    def __init__(self, sc):
        self.pattern = r'[0-9]+'
        self.type    = 'INTEGER'
        TokenRule.__init__(self, sc)

    def PostAction(self, token):
        token.value = int(token.value)
        return token

class t_FLOAT(TokenRule):
    def __init__(self, sc):
        self.pattern = r'[0-9]+\.[0-9]*|[0-9]*\.[0-9]+|[0-9]+\.[0-9]+'
        self.type    = 'FLOAT'
        TokenRule.__init__(self, sc)

    def PostAction(self, token):
        token.value = float(token.value)
        return token

class t_BASED_NUMBER(TokenRule):
    def __init__(self, sc):
        self.pattern = r"[0-9]+'(b[01_]+|d[0-9_]+|h[0-9a-f_]+)"
        self.type    = 'BASED_NUMBER'
        TokenRule.__init__(self, sc, re.I)

        
PUNC_TOKEN = ['OR', 'AND', 'XOR', 'NOT',]
class t_OR(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\|'
        self.type    = 'OR'
        TokenRule.__init__(self, sc)

class t_AND(TokenRule):
    def __init__(self, sc):
        self.pattern = r'&'
        self.type    = 'AND'
        TokenRule.__init__(self, sc)
        
class t_XOR(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\^'
        self.type    = 'XOR'
        TokenRule.__init__(self, sc)

class t_NOT(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\~'
        self.type    = 'NOT'
        TokenRule.__init__(self, sc)


PUNC_TOKEN += ['ADD', 'SUB', 'MUL', 'DIV', 'PWR', 'MOD', 'LSH', 'RSH']
class t_ADD(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\+'
        self.type    = 'ADD'
        TokenRule.__init__(self, sc)

class t_SUB(TokenRule):
    def __init__(self, sc):
        self.pattern = r'-'
        self.type    = 'SUB'
        TokenRule.__init__(self, sc)

class t_MUL(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\*'
        self.type    = 'MUL'
        TokenRule.__init__(self, sc)

class t_DIV(TokenRule):
    def __init__(self, sc):
        self.pattern = r'/'
        self.type    = 'DIV'
        TokenRule.__init__(self, sc)

class t_PWR(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\*\*'
        self.type    = 'PWR'
        TokenRule.__init__(self, sc)

class t_MOD(TokenRule):
    def __init__(self, sc):
        self.pattern = r'%'
        self.type    = 'MOD'
        TokenRule.__init__(self, sc)

class t_LSH(TokenRule):
    def __init__(self, sc):
        self.pattern = r'<<'
        self.type    = 'LSH'
        TokenRule.__init__(self, sc)

class t_RSH(TokenRule):
    def __init__(self, sc):
        self.pattern = r'>>'
        self.type    = 'RSH'
        TokenRule.__init__(self, sc)


PUNC_TOKEN += ['COND_NOT', 'COND_AND', 'COND_OR',
               'COND_LT', 'COND_GT', 'COND_EQ', 'COND_NE', 'COND_LE', 'COND_GE']
class t_COND_NOT(TokenRule):
    def __init__(self, sc):
        self.pattern = r'!'
        self.type    = 'COND_NE'
        TokenRule.__init__(self, sc)

class t_COND_AND(TokenRule):
    def __init__(self, sc):
        self.pattern = r'&&'
        self.type    = 'COND_AND'
        TokenRule.__init__(self, sc)
        
class t_COND_OR(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\|\|'
        self.type    = 'COND_OR'
        TokenRule.__init__(self, sc)

class t_COND_LT(TokenRule):
    def __init__(self, sc):
        self.pattern = r'<'
        self.type    = 'COND_LT'
        TokenRule.__init__(self, sc)

class t_COND_GT(TokenRule):
    def __init__(self, sc):
        self.pattern = r'>'
        self.type    = 'COND_GT'
        TokenRule.__init__(self, sc)

class t_COND_EQ(TokenRule):
    def __init__(self, sc):
        self.pattern = r'=='
        self.type    = 'COND_EQ'
        TokenRule.__init__(self, sc)

class t_COND_NE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'!='
        self.type    = 'COND_NE'
        TokenRule.__init__(self, sc)

class t_COND_LE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'<='
        self.type    = 'COND_LE'
        TokenRule.__init__(self, sc)

class t_COND_GE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'>='
        self.type    = 'COND_GE'
        TokenRule.__init__(self, sc)


PUNC_TOKEN += ['QUESTION_MARK', 'COLON']
class t_QUESTION_MARK(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\?'
        self.type    = 'QUESTION_MARK'
        TokenRule.__init__(self, sc)

class t_COLON(TokenRule):
    def __init__(self, sc):
        self.pattern = r':'
        self.type    = 'COLON'
        TokenRule.__init__(self, sc)


PUNC_TOKEN += ['EQUAL', 'COMMA', 'DOT', 'SEMICOLON',
               'CHARP', 'AT',
               'DOUBLE_QUOTE', 'SINGLE_QUOTE',]
class t_EQUAL(TokenRule):
    def __init__(self, sc):
        self.pattern = r'='
        self.type    = 'EQUAL'
        TokenRule.__init__(self, sc)

class t_COMMA(TokenRule):
    def __init__(self, sc):
        self.pattern = r','
        self.type    = 'COMMA'
        TokenRule.__init__(self, sc)
 
class t_DOT(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\.'
        self.type    = 'DOT'
        TokenRule.__init__(self, sc)

class t_SEMICOLON(TokenRule):
    def __init__(self, sc):
        self.pattern = r';'
        self.type    = 'SEMICOLON'
        TokenRule.__init__(self, sc)

class t_CHARP(TokenRule):
    def __init__(self, sc):
        self.pattern = r'#'
        self.type    = 'CHARP'
        TokenRule.__init__(self, sc)

class t_AT(TokenRule):
    def __init__(self, sc):
        self.pattern = r'@'
        self.type    = 'AT'
        TokenRule.__init__(self, sc)

class t_DOUBLE_QUOTE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'"'
        self.type    = 'DOUBLE_QUOTE'
        TokenRule.__init__(self, sc)

class t_SINGLE_QUOTE(TokenRule):
    def __init__(self, sc):
        self.pattern = r"'"
        self.type    = 'SINGLE_QUOTE'
        TokenRule.__init__(self, sc)
        

PUNC_TOKEN += ['LBRACE', 'RBRACE', 'LPAREN', 'RPAREN', 'LBRACKET', 'RBRACKET']
class t_LBRACE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\{'
        self.type    = 'LBRACE'
        TokenRule.__init__(self, sc)

class t_RBRACE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\}'
        self.type    = 'AND'
        TokenRule.__init__(self, sc)

class t_LPAREN(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\('
        self.type    = 'LPAREN'
        TokenRule.__init__(self, sc)

class t_RPAREN(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\)'
        self.type    = 'RPAREN'
        TokenRule.__init__(self, sc)

class t_LBRACKET(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\['
        self.type    = 'LBRACKET'
        TokenRule.__init__(self, sc)

class t_RBRACKET(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\]'
        self.type    = 'RBRACKET'
        TokenRule.__init__(self, sc)


PUNC_TOKEN += ['MACRO_DOUBLE_QUOTE', 'MACRO_SEP']
class t_MACRO_DOUBLE_QUOTE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'`"'
        self.type    = 'MACRO_DOUBLE_QUOTE'
        TokenRule.__init__(self, sc)

class t_MACRO_SEP(TokenRule):
    def __init__(self, sc):
        self.pattern = r'``'
        self.type    = 'MACRO_SEP'
        TokenRule.__init__(self, sc)

PUNC_TOKEN += ['ESCAPED_DOUBLE_QUOTE', ]
class t_ESCAPED_DOUBLE_QUOTE(TokenRule):
    def __init__(self, sc):
        self.pattern = r'\\"'
        self.type    = 'ESCAPED_DOUBLE_QUOTE'
        TokenRule.__init__(self, sc)



CORE_TOKEN += PUNC_TOKEN


MACRO_TOKEN += MACRO_KEYWORD_TOKEN
MACRO_TOKEN += ['MACRO_ID', ]
class t_MACRO_ID(TokenRule):
    def __init__(self, sc):
        self.pattern = r'`[_A-Z][_A-Z0-9]*'
        self.type    = 'MACRO_ID'
        TokenRule.__init__(self, sc, re.I)

    def PostAction(self, token):
        token.value = token.value[1:]
        if token.value in MACRO_KEYWORD:
            token.type = 'K_MACRO_' + token.value.upper()
        return token
        



# ==================================================
#  Start Condidtions
# ==================================================
class sc_string(StartCondition):
    def __init__(self, lexer):
        self.name       = 'sc_string'
        self.tr_classes = [t_ESCAPED_DOUBLE_QUOTE,
                           t_DOUBLE_QUOTE,
                           t_NEWLINE,
                           t_LITERAL]
        StartCondition.__init__(self, lexer)

    def PostTokenAction(self, token):
        if token.type == "DOUBLE_QUOTE":
            self.lexer.PopSC()
            token = self.merged_token['LITERAL']
            token.type = 'STRING'
            self.ResetMergedToken('LITERAL')
        elif token.type == 'ESCAPED_DOUBLE_QUOTE':
            token.type = 'LITERAL'
            token = self.MergeToken(token)
        elif token.type == 'NEWLINE':
            msg = "newline is not allowed inside string:{}"
            self.logger.error(msg.format(token))
            raise SyntaxError()
        else:
            token = self.MergeToken(token)
        return token


class sc_default(StartCondition):
    def __init__(self, lexer):
        self.name       = 'sc_default'
        self.tr_classes = [t_SPACE, t_NEWLINE, t_ID, t_MACRO_ID, t_DOUBLE_QUOTE]
        StartCondition.__init__(self, lexer)


    def PostTokenAction(self, token):
        if token.type == "DOUBLE_QUOTE":
            self.lexer.PushSC('sc_string')
        else:
            return token

class MPPLexer(GLexer):
    def __init__(self):
        sc = [sc_default, sc_string]
        GLexer.__init__(self, 'MPPLexer', sc)


if __name__ == '__main__':
    import argparse
    import teelog
    AP = argparse.ArgumentParser(parents=[teelog.AP, GreedyLexer.AP])
    args = AP.parse_args()
    teelog.Setup(args)
    GreedyLexer.Setup(args)
    
    gl = MPPLexer()
    gl.SetSC('sc_default')

    path = pathlib.Path('a.mhdl')
    fi = FileInputBuffer(path)

    gl.PushInput(fi)
    print(gl)

    import sys
    while True:
        try:
            x = gl.token()
        except Exception as err:
            exit()
