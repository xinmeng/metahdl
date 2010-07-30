#include "mparser.bison.hh"
#include "MetaHDL.hh"


void
CMHDLwrapper::Parse()
{
  RunPP();

  yy::mParser *mparser = new yy::mParser (*this);
  OpenIO();
  mparser->set_debug_level(DebugMHDLParser);
  mparser->parse();
  CloseIO();
  delete mparser;


  GenSV();
}

void
CMHDLwrapper::DepParse()
{
  RunPP();

  yy::mParser *mparser = new yy::mParser (*this);
  SwitchLexerSrc();
  mparser->set_debug_level(DebugMHDLParser);
  mparser->parse();
  RestoreLexerSrc();
  delete mparser;

  GenSV();
}

