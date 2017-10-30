#!/usr/bin/env python3

import logging

class Width:
    def __init__(self, width, level=1):
        self.width = width
        self.level = level

    def __str__(self):
        if self.level == 1:
            s = "{}".format(self.width)
        else:
            s = "{}:{}".format(self.level,
                               self.width)

    def __lt__(self, x):
        if type(self) == type(x):
            if self.level == x.level and self.width < x.width:
                return True
            else:
                return False
        else:
            if 

class DimensionElement:
    def __init__(self, msb, lsb=None):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.msb = msb
        self.lsb = lsb

    def __str__(self):
        s = "[{}".format(self.msb)
        if self.lsb is not None:
            s += " : {}]".format(self.lsb)
        else:
            s += "]"
        return s

    def IsBitIndex(self):
        if self.lsb is None:
            return True
        else:
            return False

    def IsRange(self):
        return not self.IsBitIndex()


class Dimension:
    '''
    DimensionElement are place from left to right as in code, 
    [0] is the most-significant level
    '''
    def __init__(self, de_array):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.des    = de_array

    def __str__(self):
        de_str = ["{}".format(de) for de in self.des]
        s = ' '.join(de_str)
        return s

    def __iter__(self):
        return iter(self.des)

    def __getitem__(self, index):
        return self.des[index]

    def __sub__(self, x):
        '''
        Use to determine dimension of symbol reference, e.g., 
        wire [3:0][4:0][5:0] a;

        width of a[1][2] is [3:0][4:0][5:0] - [1][2]
        '''
        
        if type(self) != type(x):
            raise DimensionSubWithOther
        elif self.Levels() < x.Levels():
            raise DimensionSubUnderflow
        elif self.Levels() == x.Levels():
            if x.LegalRangeSel():
                return self.des[-1:]
            else:
                raise OnlyLSLSupportRangeSel
        else:
            if x.LegalRangeSel():
                return self.des[x.Levels():]
            else:
                raise OnlyLSLSupportRangeSel
            

    def append(self, de):
        self.des.append(de)

    def LegalRangeSel(self):
        for d in self.des[:-1]:
            if d.IsRange():
                return False
        else:
            return True
            

    def Levels(self):
        return len(self.des)
        

    def InterpretSVDeclaration(self):
        '''
        In SystemVerilog, Single-value unpacked dimension are allowed in 
        declaration, e.g., 
        
        wire [4][5][6] a; 

        is identical to 

        wire [3:0][4:0][5:0] a;
        '''

        for d in self.des:
            if d.lsb is None:
                d.msb = d.msb - 1
                d.lsb = 0
                
            
