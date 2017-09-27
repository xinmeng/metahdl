#!/usr/bin/python3

import argparse
import logging
import re

from mhdlcException import *

AP = argparse.ArgumentParser(add_help=False)
AP.add_argument('--enable-gl-debug', action='store_true', default=False,
                dest='enable_gl_debug',
                help='When enabled, regex patterns can be used')
AP.add_argument('--debug-gl-token-rule', '--debug-gl-tr', '--dgltr', action='append',
                dest='dbg_tr', default=[],
                help='List regex pattern of token rule names to show debug infomation')

AP.add_argument('--debug-gl-start-condition', '--debug-gl-sc', '--dglsc', action='append',
                dest='dbg_sc', default=[],
                help='List regex pattern of start condition names to show debug information')

AP.add_argument('--debug-gl-input-buffer', '--debug-gl-ib', '--dglib', action='append',
                dest='dbg_ib', default=[],
                help='List regex pattern of input buffer names to show debug infomation')

AP.add_argument('--debug-gl-lexer', '--dgll', action='append',
                dest='dbg_lexer', default=[],
                help='List regex pattern of lexer names to show debug information')


ENABLE_GL_DEBUG = False
DBG_TR    = []
DBG_SC    = []
DBG_LEXER = []            
DBG_IB    = []

def Setup(args):
    global ENABLE_GL_DEBUG
    global DBG_TR
    global DBG_SC
    global DBG_LEXER
    global DBG_IB
    ENABLE_GL_DEBUG = args.enable_gl_debug
    DBG_TR    = args.dbg_tr
    DBG_SC    = args.dbg_sc
    DBG_LEXER = args.dbg_lexer
    DBG_IB    = args.dbg_ib

def DebugEnabled(name, name_patterns):
    if ENABLE_GL_DEBUG:
        for p in name_patterns:
            mo = re.search(p, name, re.I)
            if mo:
                return True
        else:
            return False
    else:
        return False


# ==================================================
#  Base classes
# ==================================================
class Position:
    def __init__(self, filename, lineno, column):
        self.filename = filename
        self.lineno   = lineno
        self.column   = column
        
    def __add__(self, width):
        return Position(self.filename, self.lineno, self.column+width)

    def __str__(self):
        return "{}:{},{}".format(self.filename, self.lineno, self.column)

    def __eq__(self, other):
        if self.filename == other.filename and \
           self.lineno == other.lineno and \
           self.column == other.column:
            return True
        else:
            return False


class Location:
    def __init__(self, start, end=None):
        self.start = start
        self.end   = start if end is None else end

    def __add__(self, location):
        return Location(self.start, location.end)

    def __str__(self):
        return "{}-{}".format(self.start, self.end)


class InputLine():
    def __init__(self, text, name, lineno, column, EOF=False):
        self.text = text
        self.EOF  = EOF
        self.pos  = Position(name, lineno, column)
        
    def __str__(self):
        if self.EOF:
            return "{}:<<EOF>>".format(self.pos)
        else:
            return "{}:'{}'".format(self.pos, self.text)


class InputBuffer:
    def __init__(self, name, contents=(iter([]))):
        self.name     = name
        self.logger   = logging.getLogger(self.name)
        self.lineno   = 0
        self.column   = 1
        self.curr_pos = Position(self.name, self.lineno, self.column)
        self.contents = contents
        self.text     = ''
        self.EOF      = False

    def __str__(self):
        return "{}".format(self.name)

    def GetLine(self):
        if not self.text:
            try:
                self.text = next(self.contents)
            except StopIteration:
                self.text = ''
                self.EOF  = True
            else:
                self.lineno += 1
                self.column  = 1
        return InputLine(self.text,
                         self.name, self.lineno, self.column,
                         self.EOF)

    def Step(self, length):
        text_prev = self.text.replace('\n', r'\n')
        col_prev  = self.column
        self.text   = self.text[length:]
        self.column += length

        msg = "step {}, column:{}->{}, text:'{}' -> '{}'"
        if DebugEnabled(self.name, DBG_IB):
            self.logger.debug(msg.format(length,
                                         col_prev,  self.column,
                                         text_prev, self.text.replace('\n', r'\n')))


    def ReachEOF(self):
        pass



class FileInputBuffer(InputBuffer):
    def __init__(self, path):
        self.path   = path
        self.fh     = self.path.open()
        InputBuffer.__init__(self, "FIB:"+str(self.path), iter(self.fh))

    def ReachEOF(self):
        pass


class StringInputBuffer(InputBuffer):
    def __init__(self, name, text):
        self.name  = name
        self.lines = text.splitlines()
        InputBuffer.__init__(self, 'SIB:'+name, iter(self.lines))


class Token:
    def __init__(self, type=None, value='', length=0, location=None):
        self.type     = type
        self.value    = value
        self.length   = length
        self.location = location

    def AddPaddingSpace(self, space):
        '''
        Attach any white space or comment text to the token, 
        so as to keep the original shape in the generated code. 
        '''
        self.space = space

    def __str__(self):
        if self.length:
            return "({0.type}, {0.length}) '{0.value}' @{0.location}".format(self)
        else:
            return "<NO_TOKEN>"

    def __add__(self, token):
        if self.type is None:
            return Token(token.type,
                         token.value,
                         token.length,
                         token.location)
        else:
            if self.type == token.type:
                if self.location.end + 1 == token.location.start:
                    return Token(self.type,
                                 self.value+token.value,
                                 self.length+token.length,
                                 self.location+token.location)
                else:
                    msg = 'gap between token {} and {}'
                    self.logger.error(msg.format(self.location,
                                                 token.location))
                    raise BadTokenMerge()
            else:
                msg = "token type '{}' can't be merged with '{}'"
                self.logger.error(msg.format(self.type, token.type))
                raise BadTokenMerge()
        

class TokenRule:
    def __init__(self, sc, flags=0):
        self.sc      = sc
        self.flags   = flags
        self.lexer   = sc.lexer
        self.name    = str(self)
        self.logger  = sc.logger.getChild(self.name)

    def __str__(self):
        s = "({0.type} r'{0.pattern}'"
        if self.flags:
            s += " {0.flags})"
        else:
            s += ")"
        return s.format(self)
            

    def GetToken(self, line):
        mo = re.match(self.pattern, line.text, self.flags)
        if mo:
            length = len(mo.group(0))
            end_pos = line.pos + (length -1) # not inclusive
            location = Location(line.pos, end_pos)
            token = Token(self.type, mo.group(0), length, location)
            token = self.PostAction(token)
            if DebugEnabled(self.name, DBG_TR):
                self.logger.debug("'{}' -> '{}'".format(mo.group(0), token.value))
        else:
            token = Token()
        return token

    def PostAction(self, token):
        return token


class StartCondition:
    def __init__(self, lexer):
        self.lexer        = lexer
        self.logger       = lexer.logger.getChild("<{}>".format(self.name))
        self.merged_token = dict()
        self.token_rules  = list()
        for tr in self.tr_classes:
            self.token_rules.append(tr(self))

    def __str__(self):
        return self.name

    def AddTokenRule(self, tok_rule):
        self.token_rules.append(tok_rule())

    def MergeToken(self, token, keep_return=False):
        if token.type in self.merged_token:
            orig = self.merged_token[token.type]
        else:
            orig = Token()
        self.merged_token[token.type] = orig + token
        self.logger.debug("merge:{} -> {}".format(orig, self.merged_token[token.type]))
        if keep_return:
            token = token
        else:
            token = None
        return token
            
    def ResetMergedToken(self, type):
        self.merged_token[type] = Token()


    def GetToken(self, line):
        token = Token()
        for rule in self.token_rules:
            new_token = rule.GetToken(line)
            if new_token.length > token.length:
                token = new_token 
        if token.type is None:
            self.logger.error("No token rule matched at {}".format(line))
            raise NoTokenRuleMatched()
        else:
            if DebugEnabled(self.name, DBG_SC):
                self.logger.debug('winner token:{}'.format(token))
            return token

    def PostTokenAction(self, token):
        return token

class GLexer:
    def __init__(self, name, start_conditions=[]):
        self.logger      = logging.getLogger(name)
        self.name        = name
        self.sc_stack    = []
        self.curr_sc     = None
        self.input_stack = [];
        self.curr_input  = None
        self.space       = Token()
        self.all_sc      = dict()
        for sc in start_conditions:
            sc_inst = sc(self)
            self.all_sc[sc_inst.name] = sc_inst

    def __str__(self):
        return "{}-{} on {}".format(self.name, self.curr_sc, self.curr_input)

    def AddSC(self, start_conditions):
        for sc in start_conditions:
            sc_inst = sc()
            self.all_sc[sc_inst.name] = sc_inst

    def SetSC(self, sc_name):
        self.curr_sc = self.all_sc[sc_name]

    def PushSC(self, sc_name):
        if self.curr_sc is None:
            self.logger.error("Push None sc")
            raise LexerRTError
        sc_name_prev = self.curr_sc.name
        self.sc_stack.append(self.curr_sc)
        self.curr_sc = self.all_sc[sc_name]
        if DebugEnabled(self.name, DBG_LEXER):
            self.logger.debug("push <{}>, switch to <{}>".format(sc_name_prev, sc_name))

    def PopSC(self):
        sc_name_prev = self.curr_sc.name
        self.curr_sc = self.sc_stack.pop()
        if DebugEnabled(self.name, DBG_LEXER):
            self.logger.debug("pop <{}>, switch to <{}>".format(sc_name_prev, self.curr_sc.name))

    def SetInput(self, input_buffer):
        self.curr_input = input_buffer

    def PushInput(self, input_buffer):
        if self.curr_input is not None:
            self.input_stack.append(self.curr_input)
            if DebugEnabled(self.name, DBG_LEXER):
                self.logger.debug("push current ib:{}".format(self.curr_input))
        self.curr_input = input_buffer
        if DebugEnabled(self.name, DBG_LEXER):
            self.logger.debug("switch to ib:{}".format(input_buffer))

    def PopInput(self):
        self.curr_input = self.input_stack.pop()
        
    def token(self):
        token = Token()
        while True:
            line  = self.curr_input.GetLine()
            if line.EOF:
                self.curr_input.ReachEOF()
                if self.curr_input.__class__.__name__ == 'FileInputBuffer':
                    # return EOF for file input to
                    # check some file boundary corssing condition
                    token = Token('EOF', '', 0, Location(line.pos))
                    break
                else:
                    # otherwise, for StringInputBuffer, directly pop
                    # input buffer and switch to next buffer
                    self.curr_input = self.input_stack.pop()
            elif not line.EOF:
                token = self.curr_sc.GetToken(line)
                self.curr_input.Step(token.length)
                token = self.curr_sc.PostTokenAction(token)
                break
        if token is not None and DebugEnabled(self.name, DBG_LEXER):
            self.logger.debug("return token:{}".format(token))
        return token


if __name__ == '__main__':
    args = AP.parse_args()
    Setup(args)
    
    p = Position("test.txt", 3, 5)
    p1 = p + 6

    l = Location(p, p1)

    print(l)
