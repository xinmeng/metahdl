#!/usr/bin/python3

import plexMPP
import pyaccMPP
import plexMHDL
import plexSV
import pyaccMHDL

def CreateMPPParser(mhdlc):
    mpp_lexer  = plexMPP(mhdlc)
    mpp_parser = pyaccMPP(mhdlc, mpp_lexer)
    return mpp_parser

def CreateMHDLParser(mhdlc):
    pass

# class MHDLparser:
#     def __init__(self, _mhdlc):
#         self.mhdlc = _mhdlc
#         self.log   = self.mhdlc.logging.getLogger("MHDLparser" + self.mhdlc.namesuffix)
#         if self.mhdlc.args.debug_mhdl_lex:
#             self.lexlog = self.mhdlc.logging.getLogger("MHDLlex" + self.mhdlc.namesuffix)
#         else:
#             self.lexlog = None
#         self.lexer = ply.lex.lex(module=plexMHDL, 
#                                  debug=self.mhdlc.args.debug_mhdl_lex, 
#                                  debuglog=self.lexlog)
#         if self.mhdlc.args.debug_mhdl_yacc:
#             self.yacclog = self.mhdlc.logging.getLogger("MHDLyacc" + self.mhdlc.namesuffix)
#         else:
#             self.yacclog = None
#         self.parser  = ply.yacc.yacc(module=pyaccMHDL, start='mhdl_start',
#                                      tabmodule='MHDLyacc_table', debugfile='MHDLyacc.out', 
#                                      debug=self.mhdlc.args.debug_mhdl_yacc, 
#                                      debuglog=self.yacclog)
        
#     def Parse(self, text):
#         debuglog = self.yacclog if self.mhdlc.args.debug_mhdl_yacc else None
#         return self.parser.parse(lexer=self.lexer, debug=debuglog)

def CreateSVParser(mhdlc):
    pass

# class SVparser:
#     def __int__(self, _mhdlc):
#         self.mhdlc = _mhdlc
#         self.log   = self.mhdlc.logging.getLogger("SVparser" + self.mhdlc.namesuffix)
#         if self.mhdlc.args.debug_sv_lex:
#             self.lexlog = self.mhdlc.logging.getLogger("SVlex" + self.mhdlc.namesuffix)
#         else:
#             self.lexlog = None
#         self.lexer = ply.lex.lex(module=plexSV, 
#                                  debug=self.mhdlc.args.debug_sv_lex, 
#                                  debuglog=self.lexlog)
#         if self.mhdlc.args.debug_sv_yacc:
#             self.yacclog = self.mhdlc.logging.getLogger("SVyacc" + self.mhdlc.namesuffix)
#         else:
#             self.yacclog = None
#         self.parser  = ply.yacc.yacc(module=pyaccMHDL, start='sv_start',
#                                      tabmodule='SVyacc_table', debugfile='SVyacc.out', 
#                                      debug=self.mhdlc.args.debug_sv_yacc, 
#                                      debuglog=self.yacclog)
