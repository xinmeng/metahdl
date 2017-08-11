#!/usr/bin/python3

class Lexer:
    def __init__(self, _mhdlc):
        self.mhdlc = _mhdlc
        self.log   = self.mhdlc.logging.getLogger("SVLexer" + self.mhdlc.namesuffix)
