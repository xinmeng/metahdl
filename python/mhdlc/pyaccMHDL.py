#!/usr/bin/python3

import plexMHDL
import plexSV

class Parser:
    def __init__(self, _mhdlc, _language='mhdl'):
        if _language == 'mhdl':
            self.lexer  = plexMHDL.Lexer(_mhdlc);
            self.parser = 'parser with mhdlc start symbol'
        else :
            self.lexer  = plexSV.Lexer(_mhdlc);
            self.parser = 'parser with SV start symbol'
