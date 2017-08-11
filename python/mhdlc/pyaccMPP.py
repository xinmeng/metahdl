#!/usr/bin/python3

import pdb
import ply.yacc

from plexMPP import MPPLexer
from pyaccBase import BaseParser

class MPPParser (BaseParser):
    precedence = BaseParser.precedence
    tokens = MPPLexer.tokens
    
    def Parse(self, text):
        if self.mhdlc.args.debug_mpp_yacc:
            return self.parser.parse(text, lexer=self.lexer, debug=self.log)
        else:
            return self.parser.parse(text, lexer=self.lexer)

    def __init__(self, mhdlc, lexer):
        self.mhdlc  = mhdlc
        self.log    = mhdlc.logging.getLogger("MPPParser" + mhdlc.namesuffix)
        self.lexer  = lexer
        self.parser = ply.yacc.yacc(module=self, start='start',
                                    debug=mhdlc.args.debug_mpp_yacc)
        self.parser.log   = self.log
        self.parser.mhdlc = mhdlc

    def p_start(self, p):
        '''start : statements'''
        pass

    def p_statements(self, p):
        '''statements : empty
                      | statements statement'''
        pass

    def p_statement(self, p):
        '''statement : line_statement
                     | if_statement
                     | define_statement
                     | literals'''
                     # | for_statement 
                     # | let_statement
                     # | literals
                     # | macro_reference'''
        pass

    def p_include_statement(self, p):
        '''line_statement : LINE STRING NUMBER'''
        pass

    def p_literals(self, p):
        '''literals : literal
                    | literals literal'''
        pass

    def p_literal(self, p):
        '''literal : SPACE 
                   | TEXT
                   | NEWLINE'''
        pass 
        

    def p_if_statement(self, p):
        '''if_statement : if_condition statements else_statements else_clause ENDIF
                        | if_condition statements else_clause ENDIF
                        | if_condition statements else_statements ENDIF
                        | if_condition statements ENDIF'''
        pass

    def p_if_condition(self, p):
        '''if_condition : ifdef_condition
                        | ifndef_condition
                        | if_condition'''
        pass

    def p_ifdef_condition(self, p):
        '''ifdef_condition : IFDEF ID'''
        pass
    
    def p_ifndef_condition(self, p):
        '''ifndef_condition : IFNDEF ID'''
        pass

    def p_if_condition(self, p):
        '''if_condition : IF expression'''
        pass


    def p_else_statements(self, p):
        '''else_statements : else_statement 
                           | else_statements else_statement'''
        pass

    def p_else_statement(self, p):
        '''else_statement : else_condition statements'''
        pass

    def p_else_condition(self, p):
        '''else_condition : elseif_condition
                          | elseifdef_condition
                          | elseifndef_condition'''
        pass

    def p_elseif_condition(self, p):
        '''elseif_condition : ELSEIF expression'''
        pass
    
    def p_elseifdef_condition(self, p):
        '''elseifdef_condition : ELSEIFDEF ID'''
        pass

    def p_elseifndef_condition(self, p):
        '''elseifndef_condition : ELSEIFNDEF ID'''
        pass

    def p_else_clause(self, p):
        '''else_clause : ELSE statements'''
        pass

    def p_define_statement(self, p):
        '''define_statement : variable_definition
                            | function_definition'''
        pass

    def p_variable_definition(self, p):
        '''variable_definition : DEFINE ID macro_body endef'''
        pass

    def p_function_definition(self, p):
        '''function_definition : DEFINE FUNC_ID L_PAREN argument_declarations R_PAREN macro_body endef'''
        pass

    def p_argument_declarations(self, p):
        '''argument_declarations : argument_declaration
                                 | argument_declarations COMMA argument_declaration'''
        pass

    def p_argument_declaration(self, p):
        '''argument_declaration : ID
                                | ID EQ TEXT'''
        pass
        

    def p_macro_body(self, p):
        '''macro_body : empty
                      | macro_body macro_body_element'''
        pass

    def p_macro_body_element(self, p):
        '''macro_body_element : ID
                              | macro_reference
                              | TEXT'''
        pass
        # space, punctuations, and escaped newline are
        # all treated as TEXT

    def p_endef(self, p):
        '''endef : EOF
                 | NEWLINE'''
        pass

    def p_macro_reference(self, p):
        '''macro_reference : MACRO_ID'''
        pass


if __name__ == '__main__':
    import teelog
    import mhdlcOpt
    args = mhdlcOpt.AP.parse_args()
    teelog.Setup(args)
    
    mpp_lexer = MPPLexer(log=teelog.logging.getLogger("MPPLexer"), mhdlc=None,
                         lexdebug=args.debug_mpp_lex)
    mpp_parser = MPPParser(lexer=mpp_lexer, mhdlc=None,
                           log=teelog.logging.getLogger("MPPParser"),
                           yaccdebug=args.debug_mpp_yacc)

    text = open(args.files[0]).read()
    #pdb.set_trace()
    mpp_parser.Parse(text, args.debug_mpp_yacc)
    
