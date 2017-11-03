#!/usr/bin/env python3

import logging

class Dimension:
    def __init__(self):
        self.logger = logging.getLogger(self.__class__.__name__)


class DimensionBounded(Dimension):
    def __init__(self, msb, lsb):
        Dimension.__init__(self)
        self.msb = msb
        self.lsb = lsb
        
    def __str__(self):
        s = "[{0.msb} : {0.lsb}]".format(self)
        return s

    def IsBitIndex(self):
        return False

    def IsRange(self):
        return True

    def InterpretSVDeclaration(self):
        return self



class DimensionBitIndex(Dimension):
    def __init__(self, index):
        Dimension.__init__(self):
        self.index = index

    def __str__(self):
        s = "[{}]".format(self.index)
        return s

    def IsBitIndex(self):
        return True

    def IsRange(self):
        return False

    def InterpretSVDeclaration(self):
        return DimensionBounded(self.index -1, 0)

class DimensionRange(Dimension):
    def __init__(self, base, width):
        Dimension.__init__(self):
        self.base  = base
        self.width = width
        if self.width < 0:
            self.lsb = self.base - self.width + 1
            self.msb = self.base
        elif self.width > 0:
            self.lsb = self.base
            self.msb = self.base + self.width - 1
        else:
            raise ZeroWidthInRange()

    def __str__(self):
        s = "[{}".format(self.base)
        if self.width < 0:
            s += " -: {}]".format(abs(self.width))
        else:
            s += " +: {}]".format(abs(self.width))
        return s

    def IsBitIndex(self):
        return False

    def IsRange(self):
        return True

    def InterpretSVDeclaration(self):
        raise RangeDimensionCantBeInDeclaration("")
    



class MultipleDimension:
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
        else:
            if x.IllegalRangeSel():
                raise OnlyLeastSignificantLevelSupportRange()

            if self.Levels() < x.Levels():
                raise DimensionSubUnderflow
            elif self.Levels() == x.Levels():
                return self.des[-1]
            else:
                return self.des[x.Levels():]

            

    def append(self, de):
        self.des.append(de)

    def IllegalRangeSel(self):
        for d in self.des[:-1]:
            if d.IsRange():
                return True
        else:
            return False
            

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
            d.InterpretSVDeclaration()
                
            
