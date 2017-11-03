#!/usr/bin/python3

# ==================================================
#  GreedyLexer Exceptions
# ==================================================
class BadTokenMerge(Exception): pass
class NoTokenRuleMatched(Exception): pass
class LexerRTError(Exception): pass

# ==================================================
#  Syntax Error
# ==================================================
class SyntaxError(Exception):
    def __init__(self, msg):
        Exception.__init__(self, "syntax error [{}]:{}".format(self.__class__.__name__,
                                                               msg))

class RangeDimensionCantBeInDeclaration(SyntaxError):
    def __init__(self, msg):
        SyntaxError.__init__(self, msg)



# ==================================================
#  Semantic Error
# ==================================================
class SemanticError(Exception):
    def __init__(self, msg):
        Exception.__init__(self, "semantic error [{}]:{}".format(self.__class__.__name__,
                                                                 msg))
class ZeroWidthInRange(SemanticError):
    def __init__(self, msg):
        SemanticError.__init__(self, msg)

class EvaluateNonConst(SemanticError):
    def __init__(self, msg):
        SemanticError.__init__(self, msg)
                           
class DimensionSubWithOther(SemanticError):
    def __init__(self, msg):
        SemanticError.__init__(self, msg)
        
class DimensionSubUnderflow(SemanticError):
    def __init__(self, msg):
        SemanticError.__init__(self, msg)
        
class OnlyLeastSignificantLevelSupportRange(SemanticError):
    def __init__(self, msg):
        SemanticError.__init__(self, msg)



if __name__ == '__main__':
    try:
        raise ZeroWidthInRange("ahah")
    except ZeroWidthInRange as err:
        print(err)
