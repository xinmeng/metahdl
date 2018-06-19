#include "mparser.bison.hh"
#include "MetaHDL.hh"


void
CMHDLwrapper::Parse()
{
  cout << "Before RunPP()" << endl;
  RunPP();
  cout << "After RunPP()" << endl;


  yy::mParser *mparser = new yy::mParser (*this);
  OpenIO();
  mparser->set_debug_level(DebugMHDLParser);
  mparser->parse();
  CloseIO();
  delete mparser;


  GenSV();
  RemovePostPPFile();  
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
  RemovePostPPFile();  
}

