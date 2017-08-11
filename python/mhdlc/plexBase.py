#!/usr/bin/python3
import ply.lex 


class BaseLexer(object):
    '''
    Base Lexer class that encapsulate shared lex rules for 
    MPP, MHDL and SV. All shared rules are enabled in INITIAL 
    start condition. 
    '''
    tokens = [
        'ID',

        'EOF', 'SPACE',

        'INT_NUMBER', 'BASED_NUMBER', 'FLOAT_NUMBER', 'STRING',

        'BINARY_ADD', 'BINARY_SUB', 'BINARY_MUL', 'BINARY_DIV', 'BINARY_MOD',
        'SHIFT_LEFT', 'SHIFT_RIGHT',

        'COND_NOT',
        'COND_AND',
        'COND_OR',
        'COND_LT',
        'COND_GT',
        'COND_EQ',
        'COND_NE',
        'COND_LE',
        'COND_GE',

        'LOGIC_AND', 'LOGIC_OR', 'LOGIC_XOR', 'LOGIC_NOT', 

        'L_PAREN', 'R_PAREN',
        'L_BRACE', 'R_BRACE',
        'L_BRACKET', 'R_BRACKET', 

        'QUESTION_MARK', 'COLON', 'COMMA', 'SEMI_COLON',
        'DOLLAR', 'POUND', 'AT', 'DOT', 'EQ', 'APOS',
        'SINGLE_QUOTE', 'DOUBLE_QUOTE',

        # token used to hold ad-hoc rule
        'ESCAPED_DOUBLE_QUOTE',
    ]

    def __init__(self):
        self.token = self.lexer.token
        self.input = self.lexer.input

    def t_eof(self, t):
        t.type  = 'EOF'
        t.value = 'eof'
        return t
        
    def t_SPACE(self, t):
        r'[ \t]+'
        return t

    def t_NUMBER(self, t):
        r'[0-9]+'
        t.value = int(t.value)
        return t

    def t_COND_AND(self, t):
        r'&&'
        return t

    def t_COND_OR(self, t):
        r'\|\|'
        return t

    def t_COND_LE(self, t):
        r'<='
        return t

    def t_COND_GE(self, t):
        r'>='
        return t

    def t_COND_EQ(self, t):
        r'=='
        return t

    def t_COND_NE(self, t):
        r'!='
        return t

    t_COND_NOT = r'!'
    t_COND_LT  = r'<'
    t_COND_GT  = r'>'

    t_LOGIC_AND = r'&'
    t_LOGIC_OR  = r'\|'
    t_LOGIC_XOR = r'\^'
    t_LOGIC_NOT = r'~'

    t_BINARY_ADD  = r'\+'
    t_BINARY_SUB  = r'-' 
    t_BINARY_MUL  = r'\*'
    t_BINARY_DIV  = r'/' 
    t_BINARY_MOD  = r'%' 
    t_SHIFT_LEFT  = r'<<'
    t_SHIFT_RIGHT = r'>>'

    t_L_PAREN   = r'\('
    t_R_PAREN   = r'\)'
    t_L_BRACE   = r'\{'
    t_R_BRACE   = r'\}'
    t_L_BRACKET = r'\['
    t_R_BRACKET = r'\]'

    t_QUESTION_MARK = r'\?'
    t_COLON         = r':'
    t_COMMA         = r','
    t_SEMI_COLON    = r';'
    t_DOLLAR        = r'\$'
    t_POUND         = r'[#]'
    t_AT            = r'@'
    t_DOT           = r'\.'
    t_EQ            = r'='
    t_SINGLE_QUOTE  = r'\''
    t_DOUBLE_QUOTE  = r'"'

