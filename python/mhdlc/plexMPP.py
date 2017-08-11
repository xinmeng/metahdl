#!/usr/bin/python3

import ply.lex 

from plexBase import BaseLexer

class MPPLexer(BaseLexer):
    id_re      = r'[_A-Za-z][_A-Za-z0-9]*'
    func_id_re = id_re + r'(?=\()'
    macro_re   = r'`' + id_re

    keywords = (
        'if', 'ifdef', 'ifndef', 
        'else', 'elseif', 'elseifdef', 'elseifndef', 'endif', 
        'for', 'endfor', 
        'define', 'let',
        # 'include',
        'line', 
    )

    tokens = BaseLexer.tokens
    tokens += [x.upper() for x in keywords]
    tokens += ['MACRO_ID', 'FUNC_ID', 'TEXT', 'NEWLINE']

    states = (
        ('mpp', 'exclusive'),
        ('string', 'exclusive'),
        ('line', 'exclusive'),
        ('comment', 'exclusive'),
        ('define', 'exclusive'),
        ('definefunc', 'exclusive'),
        ('definestring', 'exclusive'),
        ('defcond', 'exclusive'),
        ('ifcond', 'exclusive'),
    )

    # ----------------------------------------
    # class method
    # ----------------------------------------
    def __init__(self, mhdlc):
        self.mhdlc = mhdlc
        self.log = mhdlc.logging.getLogger("MPPLexer"+mhdlc.namesuffix)
        self.lexer = ply.lex.lex(module=self, debuglog=self.log,
                                 debug=mhdlc.args.debug_mpp_lex)
        self.lexer.begin('mpp')
        BaseLexer.__init__(self)
        self.lexer.mhdlc = mhdlc
        self.lexer.log   = log
        
    def UpdatePosition(self, t):
        t.start  = Position(self.pos)
        self.pos = self.pos + t
        t.end    = Position(self.pos)
        return t

    # ----------------------------------------
    # MPP default start condition
    # ----------------------------------------
    @ply.lex.TOKEN(macro_re)
    def t_mpp_MACRO_ID(self, t):
        t.value = t.value[1:]
        if t.value in MPPLexer.keywords:
            t.type = t.value.upper()
            if t.value in ('line'):
                t.lexer.push_state('line')
            elif t.value in ('ifdef', 'ifndef', 'elseifdef', 'elseifndef'):
                t.lexer.push_state('defcond')
            elif t.value in ('if', 'elseif'):
                # recoganize expression
                t.lexer.push_state('INITIAL')
            elif t.value == 'define':
                t.lexer.push_state('define')
        else:
            t.type = 'ID'
        return t
            
    def t_mpp_SPACE(self, t):
        r'[ \t]+'
        pass

    def t_mpp_NEWLINE(self, t):
        r'\n'
        return t

    def t_mpp_TEXT(self, t):
        r'[^ \t\n]+'
        return t
    
    def t_mpp_error(self, t):
        pass

    # ----------------------------------------
    # include
    # ----------------------------------------
    def t_line_DOUBLE_QUOTE(self, t):
        r'"'
        t.lexer.push_state('string')

    def t_line_NUMBER(self, t):
        r'[0-9]+'
        t.value = int(t.value)
        return t

    def t_line_NEWLINE(self, t):
        r'\n'
        t.lexer.pop_state()

    # ----------------------------------------
    # string
    # ----------------------------------------
    def t_string_DOUBLE_QUOTE(self, t):
        r'"'
        t.lexer.pop_state()

    def t_string_TEXT(self, t):
        r'[^"]+'
        t.type = 'STRING'
        return t
        

    # ----------------------------------------
    # defcond
    # ifdef/ifndef/elseifdef/elseifndef condition
    # ----------------------------------------
    @ply.lex.TOKEN(id_re)
    def t_defcond_ID(self, t):
        if t.value in MPPLexer.keywords:
            t.type = t.value.upper()
        else:
            t.type = 'ID'
        return t

    def t_defcond_SPACE(self, t):
        r'[ \t]+'
        pass

    def t_defcond_NEWLINE(self, t):
        r'\n+'
        t.lexer.pop_state()


    # ----------------------------------------
    # ifcond
    # if/elseif condition
    # ----------------------------------------
    @ply.lex.TOKEN(macro_re)
    def t_ifcond_ID(self, t):
        if t.value in MPPLexer.keywords:
            t.type = t.value.upper()
        else:
            t.type = 'ID'
        t.lexer.push_state('INITIAL')
        return t


        
    # ----------------------------------------
    # define
    # ----------------------------------------
    @ply.lex.TOKEN(func_id_re)
    def t_define_FUNC_ID(self, t):
        t.lexer.push_state('definefunc')
        return t

    @ply.lex.TOKEN(id_re)
    def t_define_ID(self, t):
        return t

    @ply.lex.TOKEN(macro_re)
    def t_define_MACRO_ID(self, t):
        t.value = t.value[1:]
        if t.value in MPPLexer.keywords:
            # return as literal
            t.value = '`' + t.value
            t.type  = 'TEXT'
        else:
            t.type = 'MACRO_ID'

    def t_define_APOS(self, t):
        r'``'
        pass

    def t_define_SPACE(self, t):
        r'([ \t]|(\\n))+'
        pass


    def t_define_DOUBLE_QUOTE(self, t):
        r'`"'
        t.value = '"'
        t.type  = 'TEXT'
        t.lexer.push_state('definestring')
        return t

    def t_define_NEWLINE(self, t):
        r'\n|\\n'
        if len(t.value) == 2:
            t.value = '\n'
            t.type  = 'TEXT'
        else:
            t.value = '\n'
            t.type  = 'NEWLINE'
        return t

    def t_define_eof(self, t):
        t.type = 'EOF'
        return t

    def t_define_TEXT(self, t):
        r'.'
        return t


    def t_definefunc_L_PAREN(self, t):
        r'\('
        return t

    def t_definefunc_R_PAREN(self, t):
        r'\)'
        t.lexer.pop_state()
        return t

    @ply.lex.TOKEN(id_re)
    def t_definefunc_ID(self, t):
        return t

    def t_definefunc_COMMA(self, t):
        r','
        return t

    def t_definefunc_SPACE(self, t):
        r'[ \t]+'
        pass

    def t_definefunc_NEWLINE(self, t):
        r'\n'
        return t

    def t_definefunc_eof(self, t):
        t.type = 'EOF'
        return t

    def t_definefunc_TEXT(self, t):
        r'.'
        return t


    def t_definestring_ESCAPED_DOUBLE_QUOTE(self, t):
        r'\"'
        t.type = 'TEXT'
        return t

    @ply.lex.TOKEN(id_re)
    def t_definestring_ID(self, t):
        return t

    @ply.lex.TOKEN(macro_re)
    def t_definestring_MACRO_ID(self, t):
        if t.value[1:] in plexMPP.keywords:
            t.type = 'TEXT'
        else:
            t.value = t.value[1:]
            t.type  = 'MACRO_ID'
        return t

    def t_definestring_DOUBLE_QUOTE(self, t):
        r'"'
        t.type = 'TEXT'
        t.lexer.pop_state()
        return t

    
            
    



    # ----------------------------------------
    # INITIAL
    # ----------------------------------------
    @ply.lex.TOKEN(id_re)
    def t_ID(self,t):
        if t.value in MPPLexer.keywords:
            t.type = t.value.upper()
        else:
            t.type = 'ID'
        return t

    def t_NEWLINE(self, t):
        r'\n+'
        return t

    def t_comment_ID(self, t):
        r'.+'
        return t

    def t_comment_NEWLINE(self, t):
        r'\n'
        return t




if __name__ == '__main__':
    import teelog
    import mhdlcOpt
    args = mhdlcOpt.AP.parse_args()
    teelog.Setup(args)

    pl = MPPLexer(log=teelog.logging.getLogger("MPPLexer"), mhdlc=None)
    
    text = open(args.files[0]).read()
    pl.test(text)
