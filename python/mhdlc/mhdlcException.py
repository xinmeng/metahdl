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
        Exception.__init__(self, msg)
