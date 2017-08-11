#!/usr/bin/python3

import collections
import re


class VToken:
    def __init__(self, type, value, length):
        self.type   = type
        self.value  = value
        self.length = length
        
    def __str__(self):
        return "(%s, '%s', %d)" % (self.type, self.value, self.length)

class Lexer:
    def __init__(self):
        self.rules = [
            ('ID', r'[_A-Za-z][_A-Za-z0-9]*'),
            ('NEWLINE', r'\n'),
            ('SPACES', r'[ \t]'),
            ('ASSIGN', r'='),
            ('EQ', r'=='),
            ('FEQ', r'==='),            
        ]
        self.regexps = []
        for (name,regexp) in self.rules:
            self.regexps.append('(?P<%s>%s)' % (name, regexp))

    def get_token(self, text):
        token = None
        for regexp in self.regexps:
            mo = re.match(regexp, text)
            if mo:
                mo_length = mo.end() - mo.start()
                if not token or token.length < mo_length:
                    token = VToken(mo.lastgroup, mo.group(0), mo_length)
                elif token.length == mo_length:
                    print("Same length match")
        if token:
            text = text[mo_length:]
            return(token,text)
        else:
            print("Unrecoganized char: '%s'" % text[0])
            raise RuntimeError

    



Token = collections.namedtuple('Token', ['typ', 'value', 'line', 'column'])

def tokenize(code):
    keywords = {'IF', 'THEN', 'ENDIF', 'FOR', 'NEXT', 'GOSUB', 'RETURN'}
    token_specification = [
        ('eq_comp',  r'=='),  # Integer or decimal number
        ('eq_assign',  r'='),  # Integer or decimal number
        ('NUMBER',  r'\d+(\.\d*)?'),  # Integer or decimal number
        ('ASSIGN',  r':='),           # Assignment operator
        ('END',     r';'),            # Statement terminator
        ('ID',      r'[A-Za-z]+'),    # Identifiers
        ('OP',      r'[+\-*/]'),      # Arithmetic operators
        ('NEWLINE', r'\n'),           # Line endings
        ('SKIP',    r'[ \t]+'),       # Skip over spaces and tabs
        ('MISMATCH',r'.'),            # Any other character
    ]
    tok_regex = '|'.join('(?P<%s>%s)' % pair for pair in token_specification)
    line_num = 1
    line_start = 0
    for mo in re.finditer(tok_regex, code):
        kind = mo.lastgroup
        value = mo.group(kind)
        if kind == 'NEWLINE':
            line_start = mo.end()
            line_num += 1
        elif kind == 'SKIP':
            pass
        elif kind == 'MISMATCH':
            raise RuntimeError('%r unexpected on line %d' % (value, line_num))
        else:
            if kind == 'ID' and value in keywords:
                kind = value
            column = mo.start() - line_start
            yield Token(kind, value, line_num, column)

if __name__ == '__main__':
    # statements = '''
    # ==
    # '''
    # for token in tokenize(statements):
    #     print(token)

    text = '== ==='
    lexer = Lexer()
    (token, text) = lexer.get_token(text)
    print(token)

    (token, text) = lexer.get_token(text)
    print(token)

    (token, text) = lexer.get_token(text)
    print(token)
